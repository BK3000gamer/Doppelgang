extends Node2D

@onready var Sprite: Sprite2D = $"../Sprite2D"
@onready var animation_tree: AnimationTree = $"../AnimationTree"
@onready var player: Player = get_parent()

func _process(_delta: float) -> void:
	if player.InputDir.x < 0:
		Sprite.flip_h = true
		$"../RayCast2D".target_position.x = -20
	elif player.InputDir.x > 0:
		Sprite.flip_h = false
		$"../RayCast2D".target_position.x = 20
	
	animation_tree["parameters/Player%d/Launch/blend_position" % player.playerNum] = player.launchDir
	animation_tree["parameters/Player%d/Shoot/blend_position" % player.playerNum] = player.InputDir
	animation_tree["parameters/Player%d/Jump_Shoot/blend_position" % player.playerNum] = player.InputDir
	
	queue_redraw()

func _draw() -> void:
	if player.TPclone:
		var color = Color("6fe5e9") if player.playerNum == -1 else Color("ff6cf5")
		draw_dashed_line(to_local(player.global_position), to_local(player.TPclone.global_position), color, 2, 4, false, false)
	if player.mergeOutOfRange:
		draw_circle(position, 64, Color(1, 0, 0, 0.75), false, 6, false)
		draw_circle(position, 64, Color(1, 1, 1, 0.75), false, 2, false)
