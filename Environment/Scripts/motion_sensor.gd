extends Area2D
class_name MotionSensor

signal triggered(body: Node2D)
signal body_detected(body: Node2D)
signal body_lost(body: Node2D)
signal active_changed(is_active: bool)

@export var detects_players := true
@export var detects_clones := true
@export var trigger_once := false
@export var detect_sensor :MotionSensor
@export var player_specific : = false

@onready var sprite := $Sprite2D

var detected_bodies: Array[Node2D] = []
var is_active := false
var has_triggered := false
var player_number : int = 0

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

func _on_body_entered(body: Node2D) -> void:
	player_number = body.playerNum
	if !_is_valid_body(body):
		return
	
	if !detected_bodies.has(body):
		detected_bodies.append(body)
	
	body_detected.emit(body)
	if !trigger_once or !has_triggered:
		has_triggered = true
		triggered.emit(body)
		
	if player_specific : 
		if detect_sensor.player_number != 0:
			if detect_sensor.player_number !=player_number :
				_activate_sensor()
	else:
		_activate_sensor()

func _on_body_exited(body: Node2D) -> void:
	if !detected_bodies.has(body):
		return
	
	detected_bodies.erase(body)
	body_lost.emit(body)

func reset() -> void:
	has_triggered = false
	is_active = false
	detected_bodies.clear()
	_update_visual_state()
	active_changed.emit(is_active)

func _activate_sensor() -> void:
	if is_active:
		return
	
	is_active = true
	_update_visual_state()
	active_changed.emit(is_active)

func _update_visual_state() -> void:
	if !sprite:
		return
	
	if is_active:
		if player_number == -1:
			sprite.frame = 1
		elif player_number == 1:
			sprite.frame = 2
	else:
		sprite.frame = 0

func _is_valid_body(body: Node2D) -> bool:
	if detects_players and body is Player:
		return true
	
	if detects_clones and body is Clone:
		return true
	
	return false
