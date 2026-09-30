extends Area2D
class_name PressurePlate

signal activated
signal deactivated
signal active_changed(is_active: bool)

@export var detects_players := true
@export var detects_clones := true

@onready var animationPlayer := $AnimationPlayer

var bodies_on_plate: Array[Node2D] = []
var is_active := false

var player_1: Player
var player_2: Player

func _physics_process(_delta: float) -> void:
	#Get players
	player_1 = get_tree().get_first_node_in_group("player_1")
	player_2 = get_tree().get_first_node_in_group("player_2")
	
	if (player_1 and global_position.distance_to(player_1.global_position) < 96) or (player_2 and global_position.distance_to(player_2.global_position) < 96):
		$Sprite2D.material.set_shader_parameter("outline_colour", Color(1, 1, 1, 1))
	else:
		$Sprite2D.material.set_shader_parameter("outline_colour", Color(1, 1, 1, 0))
	
	var current_bodies := get_overlapping_bodies().filter(_is_valid_body)
	bodies_on_plate = current_bodies
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
	if is_active:
		if bodies_on_plate[0].playerNum == -1:
			animationPlayer.play("Player1")
		elif bodies_on_plate[0].playerNum == 1:
			animationPlayer.play("Player2")
	else:
		animationPlayer.play("Default")

func _is_valid_body(body: Node2D) -> bool:
	if detects_players and body is Player:
		return true
	
	if detects_clones and body is Clone:
		return true
	
	return false
