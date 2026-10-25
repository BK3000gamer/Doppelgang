extends Node2D
## Global sound playback. Configure sound_effects in audio_manager.tscn.

@export var sound_effects: Array[SoundEffect] = []

var _effects: Dictionary = {}
var _active_counts: Dictionary = {}


func _ready() -> void:
	for effect in sound_effects:
		if effect == null or effect.stream == null:
			push_warning("AudioManager: a sound setting is empty or has no stream.")
			continue
		if _effects.has(effect.type):
			push_warning("AudioManager: duplicate sound type %s." % effect.type)
			continue
		_effects[effect.type] = effect


## Plays at a constant volume, useful for menu and interface sounds.
func create_audio(type: SoundEffect.Type) -> void:
	var effect := _get_available_effect(type)
	if effect == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = effect.stream
	player.volume_db = effect.volume_db
	player.pitch_scale = effect.pitch_scale
	_start_player(player, type)


## Plays in the game world; volume and panning depend on the listener.
func create_2d_audio_at_location(location: Vector2, type: SoundEffect.Type) -> void:
	var effect := _get_available_effect(type)
	if effect == null:
		return
	var player := AudioStreamPlayer2D.new()
	player.stream = effect.stream
	player.volume_db = effect.volume_db
	player.pitch_scale = effect.pitch_scale
	# Add the player before setting its global position.
	_start_player(player, type, location)


func _get_available_effect(type: SoundEffect.Type) -> SoundEffect:
	if not _effects.has(type):
		push_warning("AudioManager: no sound configured for type %s." % type)
		return null
	var effect: SoundEffect = _effects[type]
	if _active_counts.get(type, 0) >= effect.max_instances:
		return null
	return effect


func _start_player(player: Node, type: SoundEffect.Type, location: Vector2 = Vector2.ZERO) -> void:
	add_child(player)
	if player is AudioStreamPlayer2D:
		player.global_position = location
	_active_counts[type] = _active_counts.get(type, 0) + 1
	player.finished.connect(_on_player_finished.bind(player, type))
	player.play()


func _on_player_finished(player: Node, type: SoundEffect.Type) -> void:
	_active_counts[type] = maxi(0, _active_counts.get(type, 0) - 1)
	player.queue_free()
