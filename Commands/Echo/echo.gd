extends Command

func run_command(args: Array[String]) -> String:
	var return_string: String = ""
	
	for arg in args:
		return_string += "%s " % arg
	return_string += "\n"
	return return_string
