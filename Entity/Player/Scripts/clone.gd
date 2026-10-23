extends CharacterBody2D
class_name Clone

@export_category("Stats")
@export var maxSpeed: float
@export var jumpHeight: float
@export var jumpTimeToPeak: float
@export var jumpTimeToDecent: float
@export var launchTime: float
@export var launchSpeed: float
@export var recallSpeed: float
@export var holdTime: float = 0.5

@onready var recordJumpHeight := jumpHeight
@onready var Sprite := $Sprite2D
@onready var parent := get_parent()

var dir: int
var jumpVelocity: float
var jumpGravity: float
var fallGravity: float
var launchTimer: float = 0.0
var launchDir: Vector2

var player_1: Player
var player_2: Player

var playerNum: int = -1

enum States {
	Idle,
	Run,
	Jump,
	Fall,
	Launch,
	Clone,
	Disabled,
	Climb,
	Merge,
	Recall
}

var CurrentState := States.Idle

var carrier: CharacterBody2D
var carried_player: Player = null

var holdTimer: float

func _on_clone_enter(body: Node2D) -> void:
	if not body is Player:
		return
	var top_player := body as Player
	if top_player == self:
		return
	if carried_player != null:
		return
	if top_player.global_position.y >= global_position.y: #Checks for if the other player is on top.
		return
	set_collision_mask_value(1, true)
	set_collision_layer_value(2, true)
	# Add something for pressing down direction for stepping down from platform clone
	#if (Input.is_action_pressed("down_%d" % body.deviceNum)):
		# holdTimer = holdTime
		#if holdTimer < 0:
			#
		# Timer here maybe
		# Object.set

func _on_clone_exited(body: Node2D) -> void:
	if not body is Player:
		return
	var top_player := body as Player
	if top_player == self:
		return
	set_collision_mask_value(1, false)
	set_collision_layer_value(2, false)
	
func _get_gravity() -> float:
	return jumpGravity if velocity.y < 0.0 else fallGravity

func _physics_process(delta: float) -> void:
	if playerNum == -1:
		set_collision_mask_value(3, true)
		set_collision_mask_value(4, false)
	elif playerNum == 1:
		set_collision_mask_value(4, true)
		set_collision_mask_value(3, false)
	
	#Gravity
	jumpVelocity = (2.0 * jumpHeight) / jumpTimeToPeak * -1.0
	jumpGravity = (-2.0 * jumpHeight) / pow(jumpTimeToPeak, 2.0) * -1.0
	fallGravity = (-2.0 * jumpHeight) / pow(jumpTimeToDecent, 2.0) * -1.0
	
	#State Machine
	match CurrentState:
		States.Idle:
#			set_collision_mask_value(1, true)
			velocity = Vector2.ZERO
			
			if !is_on_floor():
				_change_state(States.Fall)
		States.Fall:
#			set_collision_mask_value(1, true)
			velocity.x = maxSpeed * dir
			velocity.y += _get_gravity() * delta
			
			if is_on_floor():
				_change_state(States.Idle)
		States.Launch:
#			set_collision_mask_value(1, false)
			if launchTimer < 0.0:
				velocity.x = clamp(velocity.x, -maxSpeed, maxSpeed)
				velocity.y = max(velocity.y, -maxSpeed)
				_change_state(States.Fall)
				
				if is_on_floor():
					_change_state(States.Idle)
		States.Recall:
			if playerNum == -1:
				position = position.move_toward(player_1.position, recallSpeed * delta)
			elif playerNum == 1:
				position = position.move_toward(player_2.position, recallSpeed * delta)
			
			set_collision_layer_value(1, false)
			set_collision_mask_value(1, false)
			set_collision_mask_value(2, false)
			set_collision_mask_value(3, false)
			set_collision_mask_value(4, false)
			await get_tree().create_timer(0.1).timeout
			queue_free()
	
	if carrier != null:
		velocity += carrier.velocity
	for index in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(index)
		if collision.get_collider().name == "Player":
			velocity = collision.get_normal() * collision.get_collider_velocity().length()
	move_and_slide()

func _process(delta: float) -> void:
	if playerNum == -1:
		Sprite.modulate = Color.SKY_BLUE
	elif playerNum == 1:
		Sprite.modulate = Color.INDIAN_RED
	
	player_1 = get_tree().get_first_node_in_group("player_1")
	player_2 = get_tree().get_first_node_in_group("player_2")
	
	launchTimer -= delta
	holdTimer -= delta

func _change_state(NewState: States) -> void:
	CurrentState = NewState
	match CurrentState:
		States.Idle:
			jumpHeight = recordJumpHeight
			velocity = Vector2.ZERO
		States.Fall:
			if velocity.x == 0:
				dir = 0
			elif velocity.x > 0:
				dir = 1
			elif velocity.x <0:
				dir = -1
		States.Launch:
			velocity = launchDir * launchSpeed
			launchTimer = launchTime
			
