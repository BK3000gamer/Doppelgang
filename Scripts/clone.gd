extends CharacterBody2D
class_name Clone

@export_category("Stats")
@export var maxSpeed: float
@export var deceleration: float
@export var jumpHeight: float
@export var jumpTimeToPeak: float
@export var jumpTimeToDecent: float
@export var launchTime: float
@export var launchSpeed: float

@onready var recordJumpHeight := jumpHeight
@onready var Sprite := $Sprite2D
@onready var parent := get_parent()

var Momentum: float
var jumpVelocity: float
var jumpGravity: float
var fallGravity: float
var launchTimer: float = 0.0
var launchDir: Vector2

var playerNum: int = 1

enum States {
	Idle,
	Run,
	Jump,
	Fall,
	Launch,
	Clone,
	Disabled
}

var CurrentState := States.Idle

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
			Momentum *= deceleration
			velocity.x = Momentum
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
	
	move_and_slide()

func _process(delta: float) -> void:
	if playerNum == 1:
		Sprite.modulate = Color.SKY_BLUE
	elif playerNum == 2:
		Sprite.modulate = Color.INDIAN_RED
	
	launchTimer -= delta

func _change_state(NewState: States) -> void:
	CurrentState = NewState
	match CurrentState:
		States.Idle:
			jumpHeight = recordJumpHeight
			velocity = Vector2.ZERO
		States.Fall:
			Momentum = velocity.x
		States.Launch:
			velocity = launchDir * launchSpeed
			launchTimer = launchTime
