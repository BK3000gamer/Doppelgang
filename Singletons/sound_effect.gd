class_name SoundEffect
extends Resource
## Settings for one sound. Add these resources to the AudioManager scene.

enum Type {
	BUTTON_PRESS_1,
	BUTTON_PRESS_2,
	PRESSURE_PLATE,
	DOOR_OPEN,
	DOOR_CLOSE,
	TAKE_DAMAGE,
	PLATFORM_BREAK,
	MOTION_SENSOR,
	CLONE_SPAWN,
}

@export var type: Type = Type.BUTTON_PRESS_1
@export var stream: AudioStream
@export_range(-40.0, 6.0) var volume_db: float = 0.0
@export_range(0.1, 4.0, 0.01) var pitch_scale: float = 1.0
@export_range(1, 16) var max_instances: int = 4
