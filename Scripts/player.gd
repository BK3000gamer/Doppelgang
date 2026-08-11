extends CharacterBody2D
class_name Player

@export_category("Stats")
@export var baseSpeed: float
@export var maxSpeed: float
@export var acceleration: float
@export var deceleration: float
@export var jumpHeight: float
@export var jumpTimeToPeak: float
@export var jumpTimeToDecent: float
@export var jumpBufferTime: float
@export var coyoteTime: float
@export var launchTime: float
@export var launchSpeed: float

@onready var recordJumpHeight := jumpHeight
@onready var Sprite := $Sprite2D
@onready var Raycast := $RayCast2D
@onready var parent := get_parent()
@onready var cloneScene := load("res://Scenes/player.tscn")

var InputDir := Vector2.ZERO
var Speed: float
var Momentum: float
var jumpVelocity: float
var jumpGravity: float
var fallGravity: float
var jumpBufferTimer: float = 0.0
var coyoteTimer: float = 0.0
var launchTimer: float = 0.0
var launchDir: Vector2

var playerNum: int = 1
var group_1
var group_2

var checkpoint := Vector2.ZERO

signal respawn

enum States {
	Idle,
	Run,
	Jump,
	Fall,
	Launch,
	Clone
}

var CurrentState = States.Idle

func _get_gravity() -> float:
	return jumpGravity if velocity.y < 0.0 else fallGravity

func _physics_process(delta: float) -> void:
	#Input Direction
	if playerNum == 1:
		InputDir.x = Input.get_action_strength("right_1") - Input.get_action_strength("left_1")
		InputDir.y = Input.get_action_strength("down_1") - Input.get_action_strength("up_1")
		InputDir = InputDir.normalized()
	elif playerNum == 2:
		InputDir.x = Input.get_action_strength("right_2") - Input.get_action_strength("left_2")
		InputDir.y = Input.get_action_strength("down_2") - Input.get_action_strength("up_2")
		InputDir = InputDir.normalized()
	
	if InputDir != Vector2.ZERO:
		Raycast.global_rotation = InputDir.angle() + PI/2
	else:
		Raycast.global_rotation = 0.0
	
	#Merge
	if Input.is_action_just_pressed("merge_1") and !group_2.is_empty():
		group_2[0].queue_free()
	elif Input.is_action_just_pressed("merge_2") and !group_1.is_empty():
		group_1[0].queue_free()
	
	#Gravity
	jumpVelocity = (2.0 * jumpHeight) / jumpTimeToPeak * -1.0
	jumpGravity = (-2.0 * jumpHeight) / pow(jumpTimeToPeak, 2.0) * -1.0
	fallGravity = (-2.0 * jumpHeight) / pow(jumpTimeToDecent, 2.0) * -1.0
	
	#State Machine
	match CurrentState:
		States.Idle:
			velocity = Vector2.ZERO
			
			if !InputDir.x == 0.0:
				_change_state(States.Run)
			
			if is_on_floor():
				if (Input.is_action_just_pressed("jump_1") and playerNum == 1) or (Input.is_action_just_pressed("jump_2") and playerNum == 2):
					_change_state(States.Jump)
			else:
				_change_state(States.Fall)
			
			if (Input.is_action_just_pressed("clone_1") and playerNum == 1) or (Input.is_action_just_pressed("clone_2") and playerNum == 2):
				_change_state(States.Clone)
		States.Run:
			Speed *= acceleration
			velocity.x = InputDir.x * min(Speed, maxSpeed)
			
			if InputDir.x == 0.0:
				_change_state(States.Idle)
			
			if is_on_floor():
				if (Input.is_action_just_pressed("jump_1") and playerNum == 1) or (Input.is_action_just_pressed("jump_2") and playerNum == 2):
					_change_state(States.Jump)
			else:
				_change_state(States.Fall)
			
			if (Input.is_action_just_pressed("clone_1") and playerNum == 1) or (Input.is_action_just_pressed("clone_2") and playerNum == 2):
				_change_state(States.Clone)
		States.Jump:
			Speed *= acceleration
			velocity.x = InputDir.x * min(Speed, maxSpeed)
			velocity.y += _get_gravity() * delta
			
			if velocity.y < 0.0:
				_change_state(States.Fall)
			
			if is_on_floor():
				if InputDir.x == 0.0:
					_change_state(States.Idle)
				else:
					_change_state(States.Run)
			
			if (Input.is_action_just_pressed("clone_1") and playerNum == 1) or (Input.is_action_just_pressed("clone_2") and playerNum == 2):
				_change_state(States.Clone)
		States.Fall:
			Momentum *= deceleration
			if InputDir.x == 0.0:
				velocity.x = Momentum
			else:
				velocity.x = InputDir.x * abs(Momentum)
			velocity.y += _get_gravity() * delta
			
			if (Input.is_action_just_pressed("jump_1") and playerNum == 1) or (Input.is_action_just_pressed("jump_2") and playerNum == 2):
				if coyoteTimer > 0:
					coyoteTimer = 0.0
					_change_state(States.Jump)
				else:
					jumpBufferTimer = jumpBufferTime
			
			if is_on_floor():
				if jumpBufferTimer > 0:
					jumpBufferTimer = 0.0
					_change_state(States.Jump)
				else:
					if InputDir.x == 0.0:
						_change_state(States.Idle)
					else:
						_change_state(States.Run)
			
			if (Input.is_action_just_pressed("clone_1") and playerNum == 1) or (Input.is_action_just_pressed("clone_2") and playerNum == 2):
				_change_state(States.Clone)
		States.Launch:
			print(velocity)
			if launchTimer < 0.0:
				velocity.x = clamp(velocity.x, -maxSpeed, maxSpeed)
				velocity.y = max(velocity.y, -maxSpeed)
				_change_state(States.Fall)
			
			if (Input.is_action_just_pressed("jump_1") and playerNum == 1) or (Input.is_action_just_pressed("jump_2") and playerNum == 2):
				if coyoteTimer > 0:
					coyoteTimer = 0.0
					_change_state(States.Jump)
				else:
					jumpBufferTimer = jumpBufferTime
			
			if is_on_floor():
				if jumpBufferTimer > 0:
					jumpBufferTimer = 0.0
					_change_state(States.Jump)
				else:
					if InputDir.x == 0.0:
						_change_state(States.Idle)
					else:
						_change_state(States.Run)
			
			if (Input.is_action_just_pressed("clone_1") and playerNum == 1) or (Input.is_action_just_pressed("clone_2") and playerNum == 2):
				_change_state(States.Clone)
		States.Clone:
			velocity.y += _get_gravity() * delta
			await get_tree().create_timer(0.2).timeout
			
			if velocity.y < 0.0:
				_change_state(States.Fall)
			
			if is_on_floor():
				if InputDir.x == 0.0:
					_change_state(States.Idle)
				else:
					_change_state(States.Run)
	
	move_and_slide()

func _process(delta: float) -> void:
	if playerNum == 1:
		Sprite.modulate = Color.SKY_BLUE
	elif playerNum == 2:
		Sprite.modulate = Color.INDIAN_RED
	
	group_1 = get_tree().get_nodes_in_group("player_1")
	group_2 = get_tree().get_nodes_in_group("player_2")
	
	jumpBufferTimer -= delta
	coyoteTimer -= delta
	launchTimer -= delta
	if InputDir.x < 0:
		Sprite.flip_h = true
	else:
		Sprite.flip_h = false
	
	#match CurrentState:
		#States.Idle:
			#Sprite.play("Idle")
		#States.Run:
			#Sprite.play("Run")
		#States.Jump:
			#Sprite.play("Jump")
		#States.Fall:
			#Sprite.play("Jump")

func _change_state(NewState: States) -> void:
	CurrentState = NewState
	match CurrentState:
		States.Idle:
			jumpHeight = recordJumpHeight
			velocity = Vector2.ZERO
		States.Run:
			jumpHeight = recordJumpHeight
			Speed = baseSpeed
		States.Jump:
			velocity.y = jumpVelocity
		States.Fall:
			coyoteTimer = coyoteTime
			Momentum = velocity.x
		States.Launch:
			velocity = launchDir * launchSpeed
			launchTimer = launchTime
		States.Clone:
			if group_1.is_empty() or group_2.is_empty():
				var clone = cloneScene.instantiate()
				clone.global_position = global_position
				clone.launchDir = InputDir
				parent.add_child(clone)
				clone._change_state(States.Launch)
				if playerNum == 1:
					clone.playerNum = 2
					clone.add_to_group("player_2")
				elif playerNum == 2:
					clone.playerNum = 1
					clone.add_to_group("player_1")

func _respawn() -> void:
	global_position = checkpoint
	_change_state(States.Idle)
	respawn.emit()
