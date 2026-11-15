extends Command

func run_command(args: Array[String]) -> String:
	if len(args) > 0:
		if ConsoleManager.command_dict.has(args[0]):
			var cmd: Command = ConsoleManager.command_dict[args[0]]
			return "%s: %s\n" % [cmd.command, cmd.help_text]
		else:
			return "Unknown command '%s', cannot help.\n" % args[0]
	
	var return_string: String = "Type '/help' to see this list:\n\n"
	
	for key in ConsoleManager.command_dict:
		var cmd: Command = ConsoleManager.command_dict[key]
		return_string += "[%s] %s - %s\n" % [cmd.group, cmd.command, cmd.help_text_short]
	return_string += "\ntype '/help' <command> for mor information about a specific command\n"
	return return_string
