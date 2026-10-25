extends StaticBody2D
class_name Door

@export var startsOpen := false
@export var useTimer := false
@export var inputs: Array [Area2D] = []
@export var inputTime: float = 0.0

@onready var collision := $CollisionShape2D
@onready var sprite := $Sprite2D

var currentActivations := 0
var inputTimer: float = 0.0
var useTimerRec: bool
var _is_open := false

func _ready() -> void:
	add_to_group("doors")
	# Force the initial visual setup without playing a transition sound.
	_is_open = not startsOpen
	_update_door(false)
	useTimerRec = useTimer

func activate(play_sound: bool = true) -> void:
	if _is_open:
		return
	_is_open = true
	if play_sound:
		AudioManager.create_2d_audio_at_location(global_position, SoundEffect.Type.DOOR_OPEN)
	collision.set_deferred("disabled", true)
	sprite.frame = 1
	var tween = create_tween()
	tween.tween_property(sprite, "position", Vector2(0, -64), 0.1)

func deactivate(play_sound: bool = true) -> void:
	if not _is_open:
		return
	_is_open = false
	if play_sound:
		AudioManager.create_2d_audio_at_location(global_position, SoundEffect.Type.DOOR_CLOSE)
	collision.set_deferred("disabled", false)
	sprite.frame = 0
	var tween = create_tween()
	tween.tween_property(sprite, "position", Vector2.ZERO, 0.1)

func _update_door(play_sound: bool = true) -> void:
	if startsOpen:
		activate(play_sound)
	else:
		deactivate(play_sound)

func _process(delta: float) -> void:
	currentActivations = 0
	inputTimer -= delta
	
	for i in range(inputs.size()):
		if inputs[i].is_active:
			currentActivations += 1
	if useTimer and currentActivations == 1:
		inputTimer = inputTime
		useTimer = false
	if inputTime == 0.0:
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
	else:
		if inputTimer > 0.0:
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
	useTimer = useTimerRec
