extends AnimatableBody2D
class_name MovingPlatform

var velocity := Vector2.ZERO
var deltaPos := Vector2.ZERO
var lastPos: Vector2

func _ready() -> void:
	lastPos = global_position
	process_physics_priority = -10

func _physics_process(delta: float) -> void:
	#Calculate velocity
	deltaPos = global_position - lastPos
	velocity = deltaPos / delta
	lastPos = global_position

func get_delta_position() -> Vector2:
	return global_position - lastPos
