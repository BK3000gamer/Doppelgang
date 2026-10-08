extends Area2D
class_name InteractableButton

signal activated
signal deactivated
signal active_changed(is_active: bool)
signal interacted(body: Node2D)

@export var detects_players := true
@export var detects_clones := false
@export var toggle_mode := false

@onready var button_face := $ButtonFace
@onready var interaction_prompt := $InteractionPrompt

var bodies_in_range: Array[Node2D] = []
var is_active := false

func _process(_delta: float) -> void:
	var current_bodies := get_overlapping_bodies().filter(_is_valid_body)
	bodies_in_range = current_bodies
	interaction_prompt.visible = !bodies_in_range.is_empty()

	if bodies_in_range.is_empty():
		return

	if Input.is_action_just_pressed("interact"):
		_interact(bodies_in_range[0])

func _interact(body: Node2D) -> void:
	interacted.emit(body)

	if toggle_mode:
		set_active(!is_active)
	else:
		set_active(true)

func set_active(value: bool) -> void:
	if is_active == value:
		return

	is_active = value
	_update_visual_state()
	active_changed.emit(is_active)

	if is_active:
		activated.emit()
	else:
		deactivated.emit()

func reset() -> void:
	set_active(false)

func _update_visual_state() -> void:
	button_face.color = Color("4ed67a") if is_active else Color("d64e4e")

func _is_valid_body(body: Node2D) -> bool:
	if detects_players and body is Player:
		return true

	if detects_clones and body is Clone:
		return true

	return false
