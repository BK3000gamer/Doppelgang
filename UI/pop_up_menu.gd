extends MarginContainer

@onready var ResetMenu := $ResetMenu

func toggle_visibility(element) -> void:
	element.visible = !element.visible

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		toggle_visibility(ResetMenu)
		get_tree().paused = true
		$ResetMenu/MarginContainer/VBoxContainer/Reset.grab_focus()

func _on_reset_menu_close_pressed() -> void:
	toggle_visibility(ResetMenu)
	get_tree().paused = false

func _on_reset_pressed() -> void:
	toggle_visibility(ResetMenu)
	get_tree().paused = false
