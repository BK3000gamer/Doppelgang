extends Area2D
class_name Room

@export var roomType: roomTypes

@onready var checkpoint_1_1 := $"Checkpoint1-1"
@onready var checkpoint_2_1 := $"Checkpoint2-1"
@onready var checkpoint_1_2 := $"Checkpoint1-2"
@onready var checkpoint_2_2 := $"Checkpoint2-2"
@onready var cameraCheckpoint_1 := $"CameraCheckpoint1"
@onready var cameraCheckpoint_2 := $"CameraCheckpoint2"
@onready var cameraController := $"/root/Game/CameraController"
@onready var camera := $"/root/Game/NormalViewport/SubViewport/Camera2D"
@onready var checkpoint_1 := checkpoint_1_1
@onready var checkpoint_2 := checkpoint_2_1

var player_1: Player
var player_2: Player
var group_1: Array
var group_2: Array

var activated: bool = false

enum roomTypes {
	Normal,
	Horizontal,
	Vertical
}

func _process(_delta: float) -> void:
	group_1 = get_tree().get_nodes_in_group("player_1")
	group_2 = get_tree().get_nodes_in_group("player_2")
	
	if !player_1 and !player_2:
		activated = false

func _activate_room() -> void:
	cameraController.currentRoom = self
	
	#set checkpoint
	if player_1:
		if player_1.CurrentState == player_1.States.Disabled:
			player_1._change_state(player_1.States.Idle)
		player_1.checkpoint = checkpoint_1.global_position
	if player_2:
		if player_2.CurrentState == player_2.States.Disabled:
			player_2._change_state(player_2.States.Idle)
		player_2.checkpoint = checkpoint_2.global_position
	
	#move camera
	if !activated:
		cameraController.tween_camera()
		activated = true

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.playerNum == 1:
			if body.checkpoint:
				checkpoint_1 = get_closest_checkpoint(body, checkpoint_1_1, checkpoint_1_2)
				body._change_state(body.States.Disabled)
				body.global_position = checkpoint_1.global_position
			player_1 = body
		elif body.playerNum == 2:
			if body.checkpoint:
				checkpoint_2 = get_closest_checkpoint(body, checkpoint_2_1, checkpoint_2_2)
				body._change_state(body.States.Disabled)
				body.global_position = checkpoint_2.global_position
			player_2 = body
		
		if (player_1 and player_2) or (player_1 and group_2 == []) or (player_2 and group_1 == []):
			_activate_room()

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		if body.playerNum == 1:
			player_1 = null
		elif body.playerNum == 2:
			player_2 = null

func get_closest_checkpoint(player: Player,checkpoint1: Marker2D, checkpoint2: Marker2D) -> Marker2D:
	return checkpoint1 if player.global_position.distance_to(checkpoint1.global_position) < player.global_position.distance_to(checkpoint2.global_position) else checkpoint2
