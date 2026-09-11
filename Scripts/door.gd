extends StaticBody2D
class_name Door

@export var starts_open := false
@export var inputs : Array [Area2D] = []

@onready var collision := $CollisionShape2D
@onready var sprite := $Sprite2D

var current_activations := 0

func _ready() -> void:
	_update_door()

func add_activation() -> void:
	current_activations += 1
	_update_door()

func remove_activation() -> void:
	current_activations = max(0, current_activations - 1)
	_update_door()

func activate() -> void:
	collision.set_deferred("disabled", true)
	sprite.visible = false

func deactivate() -> void:
	collision.set_deferred("disabled", false)
	sprite.visible = true

func set_active(is_active: bool) -> void:
	if is_active:
		add_activation()
	else:
		remove_activation()

func _update_door() -> void:
	if starts_open:
		activate()
	else:
		deactivate()

func _process(delta: float) -> void:
	current_activations = 0
		
	for i in range(inputs.size()):
		if inputs[i].is_active:
			current_activations += 1
	if current_activations == inputs.size():
		activate()
	else: deactivate()
