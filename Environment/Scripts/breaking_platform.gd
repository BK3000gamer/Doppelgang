extends StaticBody2D

@export var time := 0.2
@export var cooldown := 1.0
var timer := 0.0
var cooldownTimer := 0.0
var entered := false
var played := false
@onready var collision := $CollisionShape2D
@onready var animationPlayer := $AnimationPlayer

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player or body is Clone:
		entered = true
		timer = time
		cooldownTimer = cooldown
		if !played:
			animationPlayer.play("Break")
			played = true

func _process(delta: float) -> void:
	if entered:
		timer -= delta
		cooldownTimer -= delta
	if timer < 0.0:
		collision.set_deferred("disabled", true)
	if cooldownTimer < 0.0:
		collision.set_deferred("disabled", false)
		animationPlayer.play("Default")
		played = false
