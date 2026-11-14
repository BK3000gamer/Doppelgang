extends MarginContainer

@onready var ResetMenu := $ResetMenu
@onready var TutorialMenu: MarginContainer = $TutorialMenu
@onready var Tutorial: Sprite2D = $TutorialMenu/MarginContainer/Tutorial
@onready var PauseMenu := $PauseMenu
@onready var SaveMenu := $SaveMenu

func toggle_visibility(element) -> void:
	element.visible = !element.visible

func _process(_delta: float) -> void:
	if not get_tree().paused and Input.is_action_just_pressed("reset"):
		toggle_visibility(ResetMenu)
		get_tree().paused = true
		$ResetMenu/Centre/Panel/Margin/Buttons/Reset.grab_focus()
	
	if Input.is_action_just_pressed("back") and TutorialMenu.visible:
		toggle_visibility(TutorialMenu)
		get_tree().paused = false
	
	if not get_tree().paused and Input.is_action_just_pressed("pause"):
		toggle_visibility(PauseMenu)
		get_tree().paused = true
		$PauseMenu/Centre/Panel/Margin/Buttons/Resume.grab_focus()

func _tutorial_pop_up(tutorial: int) -> void:
	if not get_tree().paused:
		toggle_visibility(TutorialMenu)
		get_tree().paused = true
	Tutorial.frame = tutorial

func _on_reset_menu_close_pressed() -> void:
	toggle_visibility(ResetMenu)
	get_tree().paused = false

func _on_reset_pressed() -> void:
	toggle_visibility(ResetMenu)
	get_tree().paused = false

func _on_resume_pressed() -> void:
	toggle_visibility(PauseMenu)
	get_tree().paused = false

func _on_save_game_pressed() -> void:
	toggle_visibility(PauseMenu)
	toggle_visibility(SaveMenu)
	if PauseMenu.visible:
		$PauseMenu/Centre/Panel/Margin/Buttons/Resume.grab_focus()
	elif SaveMenu.visible:
		$SaveMenu/Margin/Saves/Save1.grab_focus()
