extends MarginContainer

const PLAYER_COLORS := [Color("79bffa"), Color("f5b477")]
const MUTED := Color("a6b1c2")
var controllerMap: Dictionary[int, int] = {}
var stick_held: Dictionary[int, bool] = {}
var columns: Dictionary[int, VBoxContainer] = {}
var cards: Dictionary[int, PanelContainer] = {}
var statuses: Dictionary[int, Label] = {}
var start_button: Button
var hint: Label

func _ready() -> void:
	_build_menu()
	controllerMap[-1] = 0
	for device in Input.get_connected_joypads():
		controllerMap[device] = 0
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_update_status()

func _style(color: Color, border: Color, width: int = 1) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(8)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

func _label(parent: Node, text: String, font_size: int, color: Color = Color.WHITE) -> Label:
	var label := Label.new()
	parent.add_child(label)
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _button(parent: Node, text: String, action: Callable) -> Button:
	var button := Button.new()
	parent.add_child(button)
	button.text = text
	button.custom_minimum_size.y = 28
	button.add_theme_font_size_override("font_size", 13)
	button.pressed.connect(action)
	return button

func _build_menu() -> void:
	var background := ColorRect.new()
	add_child(background)
	background.color = Color("141b29")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var margin := MarginContainer.new()
	add_child(margin)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	var content := VBoxContainer.new()
	margin.add_child(content)
	content.add_theme_constant_override("separation", 8)
	_label(content, "CHOOSE YOUR SIDE", 22)
	_label(content, "Move your device left or right", 12, MUTED)
	var row := HBoxContainer.new()
	content.add_child(row)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 10)
	for slot in [-1, 0, 1]:
		var card := PanelContainer.new()
		row.add_child(card)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cards[slot] = card
		var stack := VBoxContainer.new()
		card.add_child(stack)
		stack.add_theme_constant_override("separation", 6)
		var accent: Color = MUTED if slot == 0 else PLAYER_COLORS[0 if slot == -1 else 1]
		_label(stack, "UNASSIGNED" if slot == 0 else "PLAYER %d" % (1 if slot == -1 else 2), 15, accent)
		statuses[slot] = _label(stack, "", 11, MUTED)
		var scroll := ScrollContainer.new()
		stack.add_child(scroll)
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		var devices := VBoxContainer.new()
		scroll.add_child(devices)
		devices.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		devices.add_theme_constant_override("separation", 6)
		columns[slot] = devices
	hint = _label(content, "", 12, MUTED)
	var footer := HBoxContainer.new()
	content.add_child(footer)
	footer.add_theme_constant_override("separation", 8)
	_button(footer, "Back", _on_back_pressed)
	var spacer := Control.new()
	footer.add_child(spacer)
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_button(footer, "Keyboard test", _on_test_game_pressed).tooltip_text = "Development shortcut: play with keyboard only"
	start_button = _button(footer, "Start Game", _start_game)
	start_button.custom_minimum_size.x = 140

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
		var accent: Color = MUTED if slot == 0 else PLAYER_COLORS[0 if slot == -1 else 1]
		cards[slot].add_theme_stylebox_override("panel", _style(Color("202b3d"), accent if assigned and slot != 0 else Color("39465b"), 2 if assigned and slot != 0 else 1))
		statuses[slot].text = ("READY" if assigned else "Waiting for device") if slot != 0 else "Available devices"
		if not assigned:
			_label(columns[slot], "No devices" if slot == 0 else "- - -", 12, MUTED)
	for device in controllerMap:
		var slot: int = controllerMap[device]
		var tile := PanelContainer.new()
		columns[slot].add_child(tile)
		tile.add_theme_stylebox_override("panel", _style(Color("2d3a50"), Color("465771")))
		var stack := VBoxContainer.new()
		tile.add_child(stack)
		_label(stack, "KEYS" if device == -1 else "PAD %d" % (device + 1), 11, MUTED)
		_label(stack, "Keyboard" if device == -1 else "Controller %d" % (device + 1), 13)
		if device != -1:
			tile.tooltip_text = Input.get_joy_name(device)
		var arrows := HBoxContainer.new()
		stack.add_child(arrows)
		arrows.alignment = BoxContainer.ALIGNMENT_CENTER
		var left := _button(arrows, "<", _move_device.bind(device, -1))
		var right := _button(arrows, ">", _move_device.bind(device, 1))
		left.focus_mode = Control.FOCUS_NONE
		right.focus_mode = Control.FOCUS_NONE
		left.disabled = slot == -1
		right.disabled = slot == 1
		left.tooltip_text = "Move device left"
		right.tooltip_text = "Move device right"
	start_button.disabled = not _both_players_selected()
	hint.text = "Ready! Enter / Start to play" if _both_players_selected() else "A / D or left / right on each device"

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
