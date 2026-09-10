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

func _get_gravity() -> float:
	return jumpGravity if velocity.y < 0.0 else fallGravity

func _physics_process(delta: float) -> void:
	#Gravity
	jumpVelocity = (2.0 * jumpHeight) / jumpTimeToPeak * -1.0
	jumpGravity = (-2.0 * jumpHeight) / pow(jumpTimeToPeak, 2.0) * -1.0
	fallGravity = (-2.0 * jumpHeight) / pow(jumpTimeToDecent, 2.0) * -1.0
	
	#State Machine
	match CurrentState:
		States.Idle:
			velocity = Vector2.ZERO
			
			if !is_on_floor():
				_change_state(States.Fall)
		States.Fall:
			velocity.x = maxSpeed * dir
			velocity.y += _get_gravity() * delta
			
			if is_on_floor():
				_change_state(States.Idle)
		States.Launch:
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
			await get_tree().create_timer(0.1).timeout
			queue_free()
	
	if carrier != null:
		velocity += carrier.velocity
	move_and_slide()

func _process(delta: float) -> void:
	if playerNum == -1:
		Sprite.modulate = Color.SKY_BLUE
	elif playerNum == 1:
		Sprite.modulate = Color.INDIAN_RED
	
	player_1 = get_tree().get_first_node_in_group("player_1")
	player_2 = get_tree().get_first_node_in_group("player_2")
	
	launchTimer -= delta

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

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player or body is Clone:
		if body != self:
			body.carrier = self

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.carrier:
		body.carrier = null
