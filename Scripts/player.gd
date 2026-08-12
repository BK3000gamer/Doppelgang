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
@onready var parent := get_parent()
@onready var playerScene := load("res://Scenes/player.tscn")
@onready var cloneScene := load("res://Scenes/clone.tscn")

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
var group_1: Array
var group_2: Array
var clone_1: Array
var clone_2: Array

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
	
	#Merge
	if Input.is_action_just_pressed("merge_1"):
		if !group_1.is_empty() and !group_2.is_empty():
			group_2[group_2.size() - 1].queue_free()
	elif Input.is_action_just_pressed("merge_2"):
		if !group_1.is_empty() and !group_2.is_empty():
			group_1[group_1.size() - 1].queue_free()
	
	#TP
	if playerNum == 1:
		if Input.is_action_just_pressed("tp_left_1"):
			var distance = 1000.0
			var target: CharacterBody2D
			for i in range(clone_1.size()):
				if !is_instance_valid(clone_1[i]):
					continue
				if clone_1[i].global_position.x < global_position.x and global_position.distance_to(clone_1[i].global_position) < distance:
					distance = global_position.distance_to(clone_1[i].global_position)
					target = clone_1[i]
			if target != null and is_instance_valid(target):
				var recordPos = global_position
				global_position = target.global_position
				target.global_position = recordPos
			else:
				target = null
		elif Input.is_action_just_pressed("tp_right_1"):
			var distance = 1000.0
			var target: CharacterBody2D
			for i in range(clone_1.size()):
				if !is_instance_valid(clone_1[i]):
					continue
				if clone_1[i].global_position.x > global_position.x and global_position.distance_to(clone_1[i].global_position) < distance:
					distance = global_position.distance_to(clone_1[i].global_position)
					target = clone_1[i]
			if target != null and is_instance_valid(target):
				var recordPos = global_position
				global_position = target.global_position
				target.global_position = recordPos
			else:
				target = null
	elif playerNum == 2:
		if Input.is_action_just_pressed("tp_left_2"):
			var distance = 1000.0
			var target: CharacterBody2D
			for i in range(clone_2.size()):
				if !is_instance_valid(clone_2[i]):
					continue
				if clone_2[i].global_position.x < global_position.x and global_position.distance_to(clone_2[i].global_position) < distance:
					distance = global_position.distance_to(clone_2[i].global_position)
					target = clone_2[i]
			if target != null and is_instance_valid(target):
				var recordPos = global_position
				global_position = target.global_position
				target.global_position = recordPos
			else:
				target = null
		elif Input.is_action_just_pressed("tp_right_2"):
			var distance = 1000.0
			var target: CharacterBody2D
			for i in range(clone_2.size()):
				if !is_instance_valid(clone_2[i]):
					continue
				if clone_2[i].global_position.x > global_position.x and global_position.distance_to(clone_2[i].global_position) < distance:
					distance = global_position.distance_to(clone_2[i].global_position)
					target = clone_2[i]
			if target != null and is_instance_valid(target):
				var recordPos = global_position
				global_position = target.global_position
				target.global_position = recordPos
			else:
				target = null
	
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
			if launchTimer < 0.0:
				velocity.x = clamp(velocity.x, -baseSpeed, baseSpeed)
				velocity.y = max(velocity.y, -baseSpeed)
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
		Sprite.modulate = Color.NAVY_BLUE
	elif playerNum == 2:
		Sprite.modulate = Color.DARK_RED
	
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
			var clone: CharacterBody2D
			if (playerNum == 1 and group_2.is_empty()) or (playerNum == 2 and group_1.is_empty()):
				clone = playerScene.instantiate()
				if playerNum == 1:
					clone.playerNum = 2
					clone.add_to_group("player_2")
				elif playerNum == 2:
					clone.playerNum = 1
					clone.add_to_group("player_1")
				clone.name = "Player" + str(clone.playerNum)
			elif (playerNum == 1 and group_2.size() > 0) or (playerNum == 2 and group_1.size() > 0):
				clone = cloneScene.instantiate()
				if playerNum == 1:
					clone.playerNum = 1
					clone.add_to_group("player_2")
					clone.name = "Clone" + str(playerNum) + "-" + str(group_1.size())
				elif playerNum == 2:
					clone.playerNum = 2
					clone.add_to_group("player_1")
			
			clone.global_position = global_position
			parent.add_child(clone)
			
			if (InputDir.y > 0.0 and is_on_floor()):
				launchDir = Vector2(InputDir.x, -InputDir.y)
				_change_state(States.Launch)
			elif (Input.is_action_pressed("jump_1") and playerNum == 1) or (Input.is_action_pressed("jump_2") and playerNum == 2):
				if InputDir == Vector2.ZERO:
					launchDir = Vector2.UP
				else:
					launchDir = InputDir
				_change_state(States.Launch)
			else:
				if InputDir == Vector2.ZERO:
					clone.launchDir = Vector2.UP
				else:
					clone.launchDir = InputDir
				clone._change_state(States.Launch)
				clone.move_and_slide()
			
			group_1 = get_tree().get_nodes_in_group("player_1")
			group_2 = get_tree().get_nodes_in_group("player_2")
			for i in range(1, group_1.size()):
				if !clone_2.has(group_1[i]):
					clone_2.append(group_1[i])
			for i in range(1, group_2.size()):
				if !clone_1.has(group_2[i]):
					clone_1.append(group_2[i])

func _respawn() -> void:
	global_position = checkpoint
	_change_state(States.Idle)
	respawn.emit()
