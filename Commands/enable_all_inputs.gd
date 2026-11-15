extends Command

func run_command(args: Array[String]) -> String:
	if get_tree().current_scene.scene_file_path == "res://Levels/game.tscn":
		#Get players
		var player_1 = get_tree().get_first_node_in_group("player_1")
		var player_2 = get_tree().get_first_node_in_group("player_2")
		
		GameProgress.content.clone = GameProgress.clone
		GameProgress.content.merge = GameProgress.merge
		GameProgress.content.tp_left = GameProgress.tp_left
		GameProgress.content.tp_right = GameProgress.tp_right
		if player_1:
			player_1.clone_input = GameProgress.clone
			player_1.merge_input = GameProgress.merge
			player_1.tp_left_input = GameProgress.tp_left
			player_1.tp_right_input = GameProgress.tp_right
		if player_2:
			player_2.clone_input = GameProgress.clone
			player_2.merge_input = GameProgress.merge
			player_2.tp_left_input = GameProgress.tp_left
			player_2.tp_right_input = GameProgress.tp_right
		return "Enabled all unlocakble inputs\n"
	else:
		return "You need to run the game first\n"
