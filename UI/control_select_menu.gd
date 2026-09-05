extends MarginContainer

var controllerMap: Dictionary[int, int] = {}

func _ready() -> void:
	for deviceID in Input.get_connected_joypads():
		if Input.is_joy_known(deviceID):
			controllerMap[deviceID] = 0
	controllerMap[-1] = 0

func _input(event: InputEvent) -> void:
	var playerIDx: int
	if event is InputEventKey:
		playerIDx = controllerMap[-1]
	elif event is InputEventJoypadButton:
		playerIDx = controllerMap[event.device]
	
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
	
	if Input.is_action_just_pressed("ui_accept"):
		var p1Selected := false
		var p2Selected := false
		for deviceID in controllerMap.keys():
			if controllerMap[deviceID] == -1:
				p1Selected = true
			elif controllerMap[deviceID] == 1:
				p2Selected = true
			if p1Selected and p2Selected:
				break
		if p1Selected and p2Selected:
			ControllerMap.controllerMap = controllerMap
			get_tree().change_scene_to_file("res://Scenes/game.tscn")
