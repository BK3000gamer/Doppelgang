extends Area2D

var player_1: Player
var player_2: Player

func _physics_process(_delta: float) -> void:
	player_1 = get_tree().get_first_node_in_group("player_1")
	player_2 = get_tree().get_first_node_in_group("player_2")

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if player_1:
			player_1._respawn()
		if player_2:
			player_2._respawn()
	elif body is Clone:
		body.queue_free()
