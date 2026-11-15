extends Control
class_name DevConsole

@onready var text_entry: LineEdit = $Panel/Margin/Content/InputPanel/HBoxContainer/TextEntry
@onready var submit_button: Button = $Panel/Margin/Content/InputPanel/HBoxContainer/SubmitButton
@onready var output_text: RichTextLabel = $Panel/Margin/Content/CommandHistory/Panel/MarginContainer/OutputText
@onready var close_button: Button = $Panel/Margin/Content/Header/Row/CloseButton

func _ready() -> void:
	#connect signals
	text_entry.text_submitted.connect(_submit_command_text_entry)
	submit_button.pressed.connect(_submit_command_button)
	close_button.pressed.connect(ConsoleManager.toggle_visibility)

func _submit_command_button() -> void:
	#grab command text
	var raw_cmd: String = text_entry.text
	if raw_cmd == "":
		return
	text_entry.text = ""
	ConsoleManager._run_command(raw_cmd)

func _submit_command_text_entry(raw_cmd: String) -> void:
	if raw_cmd == "":
		return
	text_entry.text = ""
	ConsoleManager._run_command(raw_cmd)

func _console_print_log(text: String) -> void:
	output_text.text += text
