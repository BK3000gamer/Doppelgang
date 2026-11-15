extends Command

func run_command(args: Array[String]) -> String:
	ConsoleManager.toggle_visibility()
	return "Exited console.\n"
