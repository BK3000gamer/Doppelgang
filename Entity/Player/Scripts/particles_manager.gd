extends Node2D

@onready var player: Player = $".."


func _shoot():
	var shoot := $Shoot
	shoot.direction = player.launchDir
	shoot.emitting = true
