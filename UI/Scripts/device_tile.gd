extends PanelContainer

signal move_requested(device: int, direction: int)

var device: int

func setup(new_device: int, slot: int) -> void:
	device = new_device
	$Stack/Tag.text = "KEYS" if device == -1 else "PAD %d" % (device + 1)
	$Stack/Name.text = "Keyboard" if device == -1 else "Controller %d" % (device + 1)
	if device != -1:
		tooltip_text = Input.get_joy_name(device)
	$Stack/Arrows/Left.disabled = slot == -1
	$Stack/Arrows/Right.disabled = slot == 1

func _ready() -> void:
	$Stack/Arrows/Left.pressed.connect(func(): move_requested.emit(device, -1))
	$Stack/Arrows/Right.pressed.connect(func(): move_requested.emit(device, 1))
