extends CanvasLayer

const MAIN_MENU := "res://UI/start_menu.tscn"
var overlay: Control
var resume_button: Button
var previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE
@onready var reset_popup: MarginContainer = get_parent().get_node("PopUpMenu")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	overlay = Control.new()
	add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	overlay.add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0, 0, 0, 0.65)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var center := CenterContainer.new()
	overlay.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	center.add_child(panel)
	panel.custom_minimum_size = Vector2(220, 0)
	var margin := MarginContainer.new()
	panel.add_child(margin)
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	var buttons := VBoxContainer.new()
	margin.add_child(buttons)
	buttons.add_theme_constant_override("separation", 8)
	var title := Label.new()
	buttons.add_child(title)
	title.text = "Paused"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	resume_button = _add_button(buttons, "Resume", resume)
	var main_menu := _add_button(buttons, "Main Menu", _on_main_menu_pressed)
	var exit_button := _add_button(buttons, "Exit to Desktop", _on_exit_pressed)
	resume_button.focus_neighbor_top = resume_button.get_path_to(exit_button)
	resume_button.focus_neighbor_bottom = resume_button.get_path_to(main_menu)
	main_menu.focus_neighbor_top = main_menu.get_path_to(resume_button)
	main_menu.focus_neighbor_bottom = main_menu.get_path_to(exit_button)
	exit_button.focus_neighbor_top = exit_button.get_path_to(main_menu)
	exit_button.focus_neighbor_bottom = exit_button.get_path_to(resume_button)
	overlay.hide()

func _add_button(parent: Node, text: String, action: Callable) -> Button:
	var button := Button.new()
	parent.add_child(button)
	button.text = text
	button.custom_minimum_size.y = 30
	button.pressed.connect(action)
	return button

func _input(event: InputEvent) -> void:
	var pause_pressed := false
	if event is InputEventKey:
		pause_pressed = event.pressed and not event.echo and event.keycode == KEY_ESCAPE
	elif event is InputEventJoypadButton:
		pause_pressed = event.pressed and event.button_index == JOY_BUTTON_START
	if not pause_pressed:
		return
	get_viewport().set_input_as_handled()
	if overlay.visible:
		resume()
	elif reset_popup.get_node("ResetMenu").visible:
		reset_popup._on_reset_menu_close_pressed()
	elif not get_tree().paused:
		open()

func open() -> void:
	previous_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	overlay.show()
	get_tree().paused = true
	resume_button.grab_focus()

func resume() -> void:
	overlay.hide()
	resume_button.release_focus()
	Input.mouse_mode = previous_mouse_mode
	get_tree().paused = false

func _on_main_menu_pressed() -> void:
	# Scene changes do not clear SceneTree.paused automatically.
	get_tree().paused = false
	var error := get_tree().change_scene_to_file(MAIN_MENU)
	if error != OK:
		get_tree().paused = true
		push_error("Could not open main menu: %s" % error_string(error))
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_exit_pressed() -> void:
	get_tree().quit()
