extends Area2D

@export var nextLevel: String
@export var checkpoint1: Vector2
@export var checkpoint2: Vector2

var player_1: Player
var player_2: Player
var group_1: Array
var group_2: Array

func _process(_delta: float) -> void:
	group_1 = get_tree().get_nodes_in_group("player_1")
	group_2 = get_tree().get_nodes_in_group("player_2")

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.playerNum == -1:
			player_1 = body
		elif body.playerNum == 1:
			player_2 = body
		
	if (player_1 and player_2) or (player_1 and group_2 == []) or (player_2 and group_1 == []):
		GameProgress.content.currentChapter = nextLevel
		GameProgress.content.currentCheckpoint1 = checkpoint1
		GameProgress.content.currentCheckpoint2 = checkpoint2
		GameProgress._start()
		get_parent().queue_free()
