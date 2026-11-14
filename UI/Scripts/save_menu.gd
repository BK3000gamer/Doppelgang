extends MarginContainer

const MAIN_MENU := "res://UI/Scenes/start_menu.tscn"

func _on_save_1_pressed() -> void:
	GameProgress._save(1)
	# Scene changes do not clear SceneTree.paused automatically.
	get_tree().paused = false
	var error := get_tree().change_scene_to_file(MAIN_MENU)
	if error != OK:
		get_tree().paused = true
		push_error("Could not open main menu: %s" % error_string(error))
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_save_2_pressed() -> void:
	GameProgress._save(2)
	# Scene changes do not clear SceneTree.paused automatically.
	get_tree().paused = false
	var error := get_tree().change_scene_to_file(MAIN_MENU)
	if error != OK:
		get_tree().paused = true
		push_error("Could not open main menu: %s" % error_string(error))
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_save_3_pressed() -> void:
	GameProgress._save(3)
	# Scene changes do not clear SceneTree.paused automatically.
	get_tree().paused = false
	var error := get_tree().change_scene_to_file(MAIN_MENU)
	if error != OK:
		get_tree().paused = true
		push_error("Could not open main menu: %s" % error_string(error))
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
