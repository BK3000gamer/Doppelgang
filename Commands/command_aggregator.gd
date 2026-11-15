extends Node
class_name CommandAggregator

func _ready() -> void:
	for child in get_children():
		if child is Command:
			ConsoleManager._add_command(child.command, child)
