extends Command

func run_command(args: Array[String]) -> String:
	if get_tree().current_scene.scene_file_path == "res://Levels/game.tscn":
		if len(args) > 0:
			var path = "res://Levels/%s.tscn" % args[0]
			if ResourceLoader.exists(path):
				var chapterScene = load(path)
				var chapter = chapterScene.instantiate()
				var scene = get_node_or_null("/root/Game/NormalViewport/LevelContainer/SubViewport")
				for child in scene.get_children():
					if child is not Camera2D:
						child.queue_free()
				scene.call_deferred("add_child", chapter)
				return "Load %s success\n" % args[0]
			else:
				return "Chapter not found!\n"
		else:
			return "Please input the chapter's name\n"
	else:
		return "You need to run the game first\n"
