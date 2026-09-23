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

func _physics_process(delta: float) -> void:
	player_1 = get_tree().get_first_node_in_group("player_1")
	player_2 = get_tree().get_first_node_in_group("player_2")
	
	# Add the gravity.
	if falling:
		velocity += get_gravity() * delta
	
		move_and_slide()
	else:
		velocity = Vector2.ZERO
	
	timer -= delta
	if timer < 0.0:
		trigger.monitoring = true

func _on_trigger_body_entered(body: Node2D) -> void:
	if (body is Player or body is Clone) and !falling:
		await get_tree().create_timer(0.1).timeout
		falling = true

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		if player_1:
			GameProgress.content.player1Deaths += 1
			player_1._respawn()
		if player_2:
			GameProgress.content.player2Deaths += 1
			player_2._respawn()
		trigger.monitoring = false
		timer = time
		var camera = get_tree().get_first_node_in_group("camera")
		camera.currentRoom._reset_room()
	elif body is Clone:
		body.queue_free()
		trigger.monitoring = false
