extends Node2D

@onready var Sprite: Sprite2D = $"../Sprite2D"
@onready var animation_tree: AnimationTree = $"../AnimationTree"
@onready var player: Player = get_parent()

func _process(delta: float) -> void:
	if player.InputDir.x < 0:
		Sprite.flip_h = true
	else:
		Sprite.flip_h = false
	
	if player.PreviousState == player.States.Clone:
		animation_tree["parameters/Player%d/Launch/blend_position" % player.playerNum] = player.launchDir
	else:
		animation_tree["parameters/Player%d/Launch/blend_position" % player.playerNum] = Vector2.ZERO
	animation_tree["parameters/Player%d/Shoot/blend_position" % player.playerNum] = player.InputDir
	animation_tree["parameters/Player%d/Jump_Shoot/blend_position" % player.playerNum] = player.InputDir
