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
