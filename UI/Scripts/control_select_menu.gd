extends MarginContainer

@onready var cards: Dictionary[int, PanelContainer] = {
	-1: $Margin/Content/Row/CardP1,
	0: $Margin/Content/Row/CardUnassigned,
	1: $Margin/Content/Row/CardP2}
@onready var columns: Dictionary[int, VBoxContainer] = {
	-1: $Margin/Content/Row/CardP1/Column/Scroll/DevicesP1,
	0: $Margin/Content/Row/CardUnassigned/Column/Scroll/DevicesUnassigned,
	1: $Margin/Content/Row/CardP2/Column/Scroll/DevicesP2}
@onready var statuses: Dictionary[int, Label] = {
	-1: $Margin/Content/Row/CardP1/Column/StatusP1,
	0: $Margin/Content/Row/CardUnassigned/Column/StatusUnassigned,
	1: $Margin/Content/Row/CardP2/Column/StatusP2}
@onready var start_button: Button = $Margin/Content/Footer/Start
@onready var hint: Label = $Margin/Content/Hint

const PLAYER_COLORS := [Color("79bffa"), Color("f5b477")]
const MUTED := Color("a6b1c2")
const DeviceTile := preload("res://UI/Scenes/device_tile.tscn")
var controllerMap: Dictionary[int, int] = {}
var stick_held: Dictionary[int, bool] = {}

func _ready() -> void:
	controllerMap[-1] = 0
	for device in Input.get_connected_joypads():
		controllerMap[device] = 0
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_update_status()

func _label(parent: Node, text: String, font_size: int, color: Color = Color.WHITE) -> Label:
	var label := Label.new()
	parent.add_child(label)
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return
	if event is InputEventJoypadMotion:
		if event.axis != JOY_AXIS_LEFT_X:
			return
		if absf(event.axis_value) < 0.3:
			stick_held[event.device] = false
		elif absf(event.axis_value) > 0.65 and not stick_held.get(event.device, false):
			stick_held[event.device] = true
			_move_device(event.device, -1 if event.axis_value < 0 else 1)
			get_viewport().set_input_as_handled()
		return
	if not (event is InputEventKey or event is InputEventJoypadButton) or not event.is_pressed():
		return
	var device: int = -1 if event is InputEventKey else event.device
	var direction := 0
	if event is InputEventKey:
		if event.keycode in [KEY_A, KEY_LEFT]:
			direction = -1
		elif event.keycode in [KEY_D, KEY_RIGHT]:
			direction = 1
		elif event.keycode == KEY_ESCAPE:
			_on_back_pressed()
			get_viewport().set_input_as_handled()
			return
	else:
		if event.button_index == JOY_BUTTON_DPAD_LEFT:
			direction = -1
		elif event.button_index == JOY_BUTTON_DPAD_RIGHT:
			direction = 1
	if direction != 0:
		_move_device(device, direction)
		get_viewport().set_input_as_handled()
	elif (event is InputEventKey and event.keycode in [KEY_ENTER, KEY_KP_ENTER]) or (event is InputEventJoypadButton and event.button_index == JOY_BUTTON_START):
		_start_game()
		get_viewport().set_input_as_handled()

func _move_device(device: int, direction: int) -> void:
	if not controllerMap.has(device):
		return
	var target: int = clampi(controllerMap[device] + direction, -1, 1)
	# One device per player. An occupied side keeps the device in its current slot.
	for other in controllerMap:
		if target != 0 and other != device and controllerMap[other] == target:
			return
	controllerMap[device] = target
	_update_status()

func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if connected:
		controllerMap[device] = 0
	else:
		controllerMap.erase(device)
	stick_held.erase(device)
	_update_status()

func _both_players_selected() -> bool:
	return controllerMap.values().has(-1) and controllerMap.values().has(1)

func _update_status() -> void:
	for slot in columns:
		for child in columns[slot].get_children():
			columns[slot].remove_child(child)
			child.queue_free()
		var assigned := controllerMap.values().has(slot)
		statuses[slot].text = ("READY" if assigned else "Waiting for device") if slot != 0 else "Available devices"
		if not assigned:
			_label(columns[slot], "No devices" if slot == 0 else "- - -", 12, MUTED)
	for device in controllerMap:
		var slot: int = controllerMap[device]
		var tile := DeviceTile.instantiate()
		columns[slot].add_child(tile)
		tile.setup(device, slot)
		tile.move_requested.connect(_move_device)
	start_button.disabled = not _both_players_selected()
	hint.text = "Ready! Enter / Start to play" if _both_players_selected() else "A / D or DPAD < / > on each device"

func _start_game() -> void:
	if not _both_players_selected():
		return
	ControllerMap.controllerMap = controllerMap.duplicate()
	get_tree().change_scene_to_file("res://Levels/game.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/start_menu.tscn")

func _on_test_game_pressed() -> void:
	# Keep the existing development shortcut separate from two-player validation.
	ControllerMap.controllerMap.clear()
	ControllerMap.controllerMap[-1] = -1
	get_tree().change_scene_to_file("res://Levels/game.tscn")
