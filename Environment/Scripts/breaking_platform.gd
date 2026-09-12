extends StaticBody2D

@export var time := 0.2
@export var cooldown := 1.0
var timer := 0.0
var cooldownTimer := 0.0
var entered := false
@onready var collision := $CollisionShape2D
@onready var sprite := $Sprite2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player or body is Clone:
		entered = true
		timer = time
		cooldownTimer = cooldown

func _process(delta: float) -> void:
	if entered:
		timer -= delta
		cooldownTimer -= delta
	if timer < 0.0:
		collision.set_deferred("disabled", true)
		sprite.set_deferred("visible", false)
	if cooldownTimer < 0.0:
		collision.set_deferred("disabled", false)
		sprite.set_deferred("visible", true)
