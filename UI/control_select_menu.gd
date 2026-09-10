extends MarginContainer

@onready var status_label: Label = $Content/VBoxContainer/StatusLabel

var controllerMap: Dictionary[int, int] = {}

func _ready() -> void:
	for deviceID in Input.get_connected_joypads():
		if Input.is_joy_known(deviceID):
			controllerMap[deviceID] = 0
	controllerMap[-1] = 0
	_update_status()

func _input(event: InputEvent) -> void:
	var playerIDx: int
	if event is InputEventKey:
		playerIDx = controllerMap[-1]
	elif event is InputEventJoypadButton:
		if !controllerMap.has(event.device):
			controllerMap[event.device] = 0
		playerIDx = controllerMap[event.device]
	else:
		return
	
	if event.is_action_pressed("left"):
		playerIDx = max(-1, playerIDx - 1)
	elif event.is_action_pressed("right"):
		playerIDx = min(1, playerIDx + 1)
	
	for deviceID in controllerMap.keys():
		if controllerMap[deviceID] == playerIDx:
			if event is InputEventKey and deviceID != -1:
				playerIDx = 0
			elif event is InputEventJoypadButton and deviceID != event.device:
				playerIDx = 0
	
	if event is InputEventKey:
		controllerMap[-1] = playerIDx
	elif event is InputEventJoypadButton:
		controllerMap[event.device] = playerIDx
	
	_update_status()
	
	if Input.is_action_just_pressed("ui_accept"):
		if _both_players_selected():
			_start_game()

func _both_players_selected() -> bool:
	return controllerMap.values().has(-1) and controllerMap.values().has(1)

func _start_game() -> void:
	ControllerMap.controllerMap = controllerMap
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _update_status() -> void:
	if !status_label:
		return
	
	var lines: Array[String] = []
	for deviceID in controllerMap.keys():
		var device_name := "Keyboard" if deviceID == -1 else "Controller %d" % deviceID
		var player_name := "Unassigned"
		if controllerMap[deviceID] == -1:
			player_name = "Player 1"
		elif controllerMap[deviceID] == 1:
			player_name = "Player 2"
		lines.append("%s: %s" % [device_name, player_name])
	
	if _both_players_selected():
		lines.append("")
		lines.append("Press Enter to start.")
	else:
		lines.append("")
		lines.append("Use left/right to assign each device.")
	
	status_label.text = "\n".join(lines)

func _on_test_game_pressed() -> void:
	controllerMap[-1] = -1
	_start_game()
