extends CharacterBody2D

var falling := false

var player_1: Player
var player_2: Player
@onready var trigger := $Trigger  # your trigger Area2D
var pos: Vector2

var time := 0.1
var timer := 0.0

func _ready() -> void:
	pos = position
	if player_1:
		player_1.respawn.connect(_reset)
	if player_2:
		player_2.respawn.connect(_reset)

func _physics_process(delta: float) -> void:
	player_1 = get_tree().get_first_node_in_group("player_1")
	player_2 = get_tree().get_first_node_in_group("player_2")
	
	# Add the gravity.
	if falling:
		velocity += get_gravity() * delta
	else:
		velocity = Vector2.ZERO
	
	timer -= delta
	if timer < 0.0:
		trigger.monitoring = true
	
	move_and_slide()

func _on_trigger_body_entered(body: Node2D) -> void:
	if (body is Player or body is Clone) and !falling:
		await get_tree().create_timer(0.1).timeout
		falling = true

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		falling = false
		if player_1:
			player_1._respawn()
		if player_2:
			player_2._respawn()
		trigger.monitoring = false
		timer = time
		_reset()
	elif body is Clone:
		falling = false
		body.queue_free()
		trigger.monitoring = false
		_reset()

func _reset() -> void:
	position = pos
	falling = false
	velocity = Vector2.ZERO
