extends StaticBody2D
class_name Door

@export var starts_open := false

@onready var collision := $CollisionShape2D
@onready var sprite := $Sprite2D

func _ready() -> void:
	if starts_open:
		activate()
	else:
		deactivate()

func activate() -> void:
	collision.set_deferred("disabled", true)
	sprite.visible = false

func deactivate() -> void:
	collision.set_deferred("disabled", false)
	sprite.visible = true

func set_active(is_active: bool) -> void:
	if is_active:
		activate()
	else:
		deactivate()


func _on_pressure_plate_activated() -> void:
	activate()


func _on_pressure_plate_deactivated() -> void:
	deactivate()


func _on_motion_sensor_triggered(body: Node2D) -> void:
	activate()
