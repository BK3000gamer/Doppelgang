extends Node

#Signals
signal on_console_open
signal on_console_close

@onready var dev_consol: DevConsole = $ConsoleCanvasLayer/DevConsole
@onready var console_layer: CanvasLayer = $ConsoleCanvasLayer

var command_dict: Dictionary = {}

var command_history: Array[String] = []
var command_history_index: int = -1

func _ready() -> void:
	#hide console on start
	console_layer.visible = false

func _add_command(cmd_name: String, cmd: Command) -> void:
	if command_dict.has(cmd_name):
		print("Command name %s already has a command associated with it." % cmd_name)
		return
	
	#add command
	command_dict[cmd_name] = cmd

func _run_command(raw_cmd: String) -> void:
	#insert command into history
	command_history.insert(0, raw_cmd)
	#reset command history index
	command_history_index = -1
	#split raw command
	var cmd_split = raw_cmd.split(' ', false)
	#identify command
	if command_dict.has(cmd_split[0]):
		#Print command to console
		dev_consol._console_print_log("> %s\n" % cmd_split[0])
		#Run command and save output
		var output_string: String = command_dict[cmd_split[0]].run_command(cmd_split.slice(1))
		#Print output to console
		dev_consol._console_print_log(output_string)
	else:
		dev_consol._console_print_log("Command %s not found, try '/help' .\n" % cmd_split[0])

func _input(_event: InputEvent) -> void:
	if !InputMap.has_action("console_open"):
		return
	if Input.is_action_just_pressed("console_open") and !console_layer.visible:
		toggle_visibility()
	if Input.is_action_just_pressed("console_close") and console_layer.visible:
		toggle_visibility()
	
	if console_layer.visible:
		if Input.is_action_just_pressed("console_up"):
			if command_history_index < len(command_history) - 1:
				command_history_index += 1
				dev_consol.text_entry.text = command_history[command_history_index]
		if Input.is_action_just_pressed("console_down"):
			if command_history_index > -1:
				command_history_index -= 1
				if command_history_index == -1:
					dev_consol.text_entry.text = ""
				else:
					dev_consol.text_entry.text = command_history[command_history_index]

func toggle_visibility() -> void:
	console_layer.visible = !console_layer.visible
	
	if console_layer.visible:
		dev_consol.text_entry.grab_focus()
		get_tree().paused = true
		on_console_open.emit()
	else:
		dev_consol.text_entry.text = ""
		get_tree().paused = false
		on_console_close.emit()
