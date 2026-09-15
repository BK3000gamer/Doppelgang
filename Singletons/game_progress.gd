extends Node

var clone := "clone_%d"
var merge := "merge_%d"
var tp_left := "tp_left_%d"
var tp_right := "tp_right_%d"

const saveLocation := "user://SaveFile.json"

var content: Dictionary = {
	"clone": "disabled_%d",
	"merge": "disabled_%d",
	"tp_left": "disabled_%d",
	"tp_right": "disabled_%d"
}

func _save():
	var file = FileAccess.open(saveLocation, FileAccess.WRITE)
	file.store_var(content.duplicate())
	file.close()

func _load():
	if FileAccess.file_exists(saveLocation):
		var file = FileAccess.open(saveLocation, FileAccess.READ)
		var data = file.get_var()
		file.close()
		
		var saveData = data.duplicate()
		content.clone = saveData.clone
		content.merge = saveData.merge
		content.tp_left = saveData.tp_left
		content.tp_right = saveData.tp_right
