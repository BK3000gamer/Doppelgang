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
var _is_open := false
var _solved := false
var _timing := false

func _ready() -> void:
	add_to_group("doors")
	# Force the initial visual setup without playing a transition sound.
	_is_open = not startsOpen
	_update_door(false)

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
	for input in inputs:
		if input.is_active:
			currentActivations += 1
	var all_active := currentActivations == inputs.size()

	# Untimed doors: follow the inputs directly.
	if not useTimer or inputTime <= 0.0:
		_set_powered(all_active)
		return

	# Timed doors: once solved, stay that way until reset() is called.
	if _solved:
		return

	if all_active:
		_solved = true
		_timing = false
		_set_powered(true)
		return

	# First input starts the window.
	if not _timing and currentActivations >= 1:
		_timing = true
		inputTimer = inputTime

	if _timing:
		inputTimer -= delta
		if inputTimer <= 0.0:
			# Ran out of time: wipe the inputs and re-arm for another attempt.
			_timing = false
			for input in inputs:
				input.reset()

func _set_powered(powered: bool) -> void:
	# "Powered" means open for normal doors, closed for startsOpen doors.
	if powered != startsOpen:
		activate()
	else:
		deactivate()

func reset():
	_solved = false
	_timing = false
	_update_door()
