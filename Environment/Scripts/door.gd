extends StaticBody2D
class_name Door

@export var startsOpen := false
@export var inputs: Array [Area2D] = []

@onready var collision := $CollisionShape2D
@onready var sprite := $Sprite2D

var currentActivations := 0

func _ready() -> void:
	_update_door()

func activate() -> void:
	collision.set_deferred("disabled", true)
	sprite.frame = 1
	var tween = create_tween()
	tween.tween_property(sprite, "position", Vector2(0, -48), 0.1)

func deactivate() -> void:
	collision.set_deferred("disabled", false)
	sprite.frame = 0
	var tween = create_tween()
	tween.tween_property(sprite, "position", Vector2.ZERO, 0.1)

func _update_door() -> void:
	if startsOpen:
		activate()
	else:
		deactivate()

func _process(_delta: float) -> void:
	currentActivations = 0
		
	for i in range(inputs.size()):
		if inputs[i].is_active:
			currentActivations += 1
	if currentActivations == inputs.size():
		if startsOpen:
			deactivate()
		else:
			activate()
	else:
		if startsOpen:
			activate()
		else:
			deactivate()

func reset():
	_update_door()
