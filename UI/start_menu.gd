extends Control
class_name StartMenu


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/control_select_menu.tscn")


func _on_quit_game_pressed() -> void:
	get_tree().quit()


func _on_load_game_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/load_menu.tscn")
