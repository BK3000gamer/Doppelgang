extends Command
func run_command(args: Array[String]) -> String:
	if !get_tree().current_scene.scene_file_path == "res://Levels/game.tscn":
		ControllerMap.controllerMap.clear()
		ControllerMap.controllerMap[-1] = -1
		GameProgress.content.controllerMap = ControllerMap.controllerMap
		get_tree().change_scene_to_file("res://Levels/game.tscn")
	return "Running keyboard test.\n"
