extends Command

func run_command(args: Array[String]) -> String:
	if get_tree().current_scene.scene_file_path == "res://Levels/game.tscn":
		if len(args) > 0:
			var scene = get_node_or_null("/root/Game/NormalViewport/LevelContainer/SubViewport")
			var chapter: Chapter
			for child in scene.get_children():
				if child is Chapter:
					chapter = child
			var room: Room = chapter.get_node_or_null("Room%s" % args[0])
			if room != null:
				var checkpoint1 = room.get_node("Checkpoint1-1")
				var checkpoint2 = room.get_node("Checkpoint2-1")
				#Get players
				var player_1 = get_tree().get_first_node_in_group("player_1")
				var player_2 = get_tree().get_first_node_in_group("player_2")
				if player_1:
					player_1.global_position = checkpoint1.global_position
				if player_2:
					player_2.global_position = checkpoint2.global_position
				return "Load room%s success\n" % args[0]
			else:
				return "Room not found\n"
		else:
			return "Please input the room number\n"
	else:
		return "You need to run the game first\n"
