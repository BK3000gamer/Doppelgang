extends Node

var clone := "clone_%d"
var merge := "merge_%d"
var tp_left := "tp_left_%d"
var tp_right := "tp_right_%d"

const saveLocation := "user://SaveFile%d.json"

var content: Dictionary = {
	"clone": "disabled_%d",
	"merge": "disabled_%d",
	"tp_left": "disabled_%d",
	"tp_right": "disabled_%d",
	"currentRoom": null,
	"currentChapter": "tutorial_level",
	"currentCheckpoint1": Vector2(-288.0, -53.0),
	"currentCheckpoint2": Vector2(-288.0, 123.0),
	"controllerMap": {},
	"player1Deaths": 0,
	"player2Deaths": 0
}

func _save(slot: int):
	var file = FileAccess.open(saveLocation % slot, FileAccess.WRITE)
	file.store_var(content.duplicate())
	file.close()

func _load(slot: int):
	if FileAccess.file_exists(saveLocation % slot):
		var file = FileAccess.open(saveLocation % slot, FileAccess.READ)
		var data = file.get_var()
		file.close()
		
		var saveData = data.duplicate()
		content.clone = saveData.clone
		content.merge = saveData.merge
		content.tp_left = saveData.tp_left
		content.tp_right = saveData.tp_right
		content.currentRoom = saveData.currentRoom
		content.currentChapter = saveData.currentChapter
		content.currentCheckpoint1 = saveData.currentCheckpoint1
		content.currentCheckpoint2 = saveData.currentCheckpoint2
		content.controllerMap = saveData.controllerMap
		content.player1Deaths = saveData.player1Deaths
		content.player2Deaths = saveData.player2Deaths
		
		print(content)

func _start():
	var cp1: Vector2 = content["currentCheckpoint1"]
	var cp2: Vector2 = content["currentCheckpoint2"]
	
	ControllerMap.controllerMap = content.controllerMap
	
	#load level
	var chapterScene = load("res://Levels/%s.tscn" % content.currentChapter)
	var chapter = chapterScene.instantiate()
	var scene = get_node_or_null("/root/Game/NormalViewport/LevelContainer/SubViewport")
	scene.call_deferred("add_child", chapter)
	await get_tree().process_frame
	
	#Get players
	var player_1 = get_tree().get_first_node_in_group("player_1")
	var player_2 = get_tree().get_first_node_in_group("player_2")
	
	#enable inputs
	if player_1:
		player_1.global_position = cp1
		player_1.checkpoint = cp1
		
		player_1.clone_input = content.clone
		player_1.merge_input = content.merge
		player_1.tp_left_input = content.tp_left
		player_1.tp_right_input = content.tp_right
	if player_2:
		player_2.global_position = cp2
		player_2.checkpoint = cp2
		
		player_2.clone_input = content.clone
		player_2.merge_input = content.merge
		player_2.tp_left_input = content.tp_left
		player_2.tp_right_input = content.tp_right
	
