extends Area2D
class_name InteractableButton

signal activated
signal deactivated
signal active_changed(is_active: bool)
signal interacted(body: Node2D)

@export var detects_players := true
@export var detects_clones := false
@export var toggle_mode := false

@onready var interaction_prompt := $InteractionPrompt
@onready var animationPlayer := $AnimationPlayer

var bodies_in_range: Array[Node2D] = []
var is_active := false

var bodies : Array[Player] = []

var player_1: Player
var player_2: Player

func _process(_delta: float) -> void:#Get players
	player_1 = get_tree().get_first_node_in_group("player_1")
	player_2 = get_tree().get_first_node_in_group("player_2")
	
	if (player_1 and global_position.distance_to(player_1.global_position) < 96) or (player_2 and global_position.distance_to(player_2.global_position) < 96):
		$Sprite2D.material.set_shader_parameter("outline_colour", Color(1, 1, 1, 1))
	else:
		$Sprite2D.material.set_shader_parameter("outline_colour", Color(1, 1, 1, 0))
	
	for i in range(bodies.size()):
		if Input.is_action_just_pressed("interact_%d" % bodies[i].deviceNum):
			_interact(bodies[i])
			if bodies[i].playerNum == -1:
				animationPlayer.play("Player1")
			elif bodies[i].playerNum == 1:
				animationPlayer.play("Player2")
		else:
			if animationPlayer.is_playing() == false:
				animationPlayer.play("Default")

func _interact(body: Node2D) -> void:
	interacted.emit(body)

	if toggle_mode:
		set_active(!is_active)
	else:
		set_active(true)

func set_active(value: bool) -> void:
	if is_active == value:
		return

	is_active = value
	_update_visual_state()
	active_changed.emit(is_active)

	if is_active:
		activated.emit()
	else:
		deactivated.emit()

func reset() -> void:
	set_active(false)

func _update_visual_state() -> void:
	pass

#func _is_valid_body(body: Node2D) -> bool:
#	if detects_players and body is Player:
#		return true
#
#	return false

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		bodies.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		for i in range(bodies.size()):
			if bodies[i] == body:
				bodies.remove_at(i)
