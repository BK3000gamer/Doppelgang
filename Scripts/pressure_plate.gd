extends Area2D
class_name PressurePlate

signal activated
signal deactivated
signal active_changed(is_active: bool)

@export var detects_players := true
@export var detects_clones := true

@onready var sprite := $Sprite2D

var bodies_on_plate: Array[Node2D] = []
var is_active := false

func _physics_process(_delta: float) -> void:
	var removed_invalid_body := false
	for body in bodies_on_plate.duplicate():
		if !is_instance_valid(body):
			bodies_on_plate.erase(body)
			removed_invalid_body = true
	
	if removed_invalid_body:
		_update_active_state()

func _on_body_entered(body: Node2D) -> void:
	if !_is_valid_body(body):
		return
	
	if !bodies_on_plate.has(body):
		bodies_on_plate.append(body)
	
	_update_active_state()

func _on_body_exited(body: Node2D) -> void:
	if bodies_on_plate.has(body):
		bodies_on_plate.erase(body)
	
	_update_active_state()

func _update_active_state() -> void:
	var should_be_active := bodies_on_plate.size() > 0
	if should_be_active == is_active:
		return
	
	is_active = should_be_active
	_update_visual_state()
	active_changed.emit(is_active)
	
	if is_active:
		activated.emit()
	else:
		deactivated.emit()

func _update_visual_state() -> void:
	if !sprite:
		return
	
	sprite.position.y = 3 if is_active else 0
	sprite.modulate = Color.LIME_GREEN if is_active else Color.WHITE

func _is_valid_body(body: Node2D) -> bool:
	if detects_players and body is Player:
		return true
	
	if detects_clones and body is Clone:
		return true
	
	return false
