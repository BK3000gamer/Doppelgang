extends Area2D
class_name Room

@export var roomType: roomTypes

@onready var checkpoint1 := $"Checkpoint 1"
@onready var checkpoint2 := $"Checkpoint 2"
@onready var cameraCheckpoint := $"Camera Checkpoint"
@onready var camera := $"/root/Test/Camera"

var player_1: Player
var player_2: Player
var group_1: Array
var group_2: Array

enum roomTypes {
	Normal,
	Horizontal,
	Vertical
}

func _process(_delta: float) -> void:
	group_1 = get_tree().get_nodes_in_group("player_1")
	group_2 = get_tree().get_nodes_in_group("player_2")

func _activate_room() -> void:
	#move camera
	var currentPos = camera.global_position
	var tween := get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(camera, "global_position", cameraCheckpoint.global_position, 0.2).from(currentPos)
	
	#set checkpoint
	if player_1:
		if player_1.CurrentState == player_1.States.Disabled:
			player_1._change_state(player_1.States.Idle)
		player_1.checkpoint = checkpoint1.global_position
	if player_2:
		if player_2.CurrentState == player_2.States.Disabled:
			player_2._change_state(player_2.States.Idle)
		player_2.checkpoint = checkpoint2.global_position

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.playerNum == 1:
			if body.checkpoint:
				body._change_state(body.States.Disabled)
				body.global_position = checkpoint1.global_position
			player_1 = body
		elif body.playerNum == 2:
			if body.checkpoint:
				body._change_state(body.States.Disabled)
				body.global_position = checkpoint2.global_position
			player_2 = body
		
		if (player_1 and player_2) or (player_1 and group_2 == []) or (player_2 and group_1 == []):
			_activate_room()

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		if body.playerNum == 1:
			player_1 = null
		elif body.playerNum == 2:
			player_2 = null
