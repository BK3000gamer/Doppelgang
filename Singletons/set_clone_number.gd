extends Command

func run_command(args: Array[String]) -> String:
	if len(args) > 0:
		if str_to_var(args[0]) is int and str_to_var(args[0]) >= 0:
			#Get players
			var player_1 = get_tree().get_first_node_in_group("player_1")
			var player_2 = get_tree().get_first_node_in_group("player_2")
			if player_1:
				player_1.cloneNum = str_to_var(args[0])
			if player_2:
				player_2.cloneNum = str_to_var(args[0])
			return "Set player's clone number to %s\n" % args[0]
		else:
			return "Please input a valid number\n"
	else:
		return "Please input a number\n"
