extends Control


func _on_save_1_pressed() -> void:
	GameProgress._load(1)

func _on_save_2_pressed() -> void:
	GameProgress._load(2)

func _on_save_3_pressed() -> void:
	GameProgress._load(3)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/game.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/Scenes/start_menu.tscn")
