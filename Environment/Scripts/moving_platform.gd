extends Path2D

@export var activateType: activateTypes
@export var activateSpeed := 5.0
@export var deactivateSpeed := 2.5
@export var cooldownTime: float = 5
@export var inputs: Array [Area2D] = []

@onready var path := $PathFollow2D
@onready var sprite := $SubViewport/Sprite2D
@onready var symbol := $AnimatableBody2D/Sprite2D

var currentActivations := 0
var cooldownTimer: float
var player: CharacterBody2D
var activating: = false

var colour := Color("fff9ae")

enum activateTypes {
	Inputs,
	Timed,
	Contact
}

func _ready() -> void:
	cooldownTimer = cooldownTime

func _physics_process(delta: float) -> void:
	match activateType:
		activateTypes.Inputs:
			currentActivations = 0
			if inputs[0] is PressurePlate:
				symbol.frame_coords.y = 0
			elif inputs[0] is MotionSensor:
				symbol.frame_coords.y = 1
			for i in range(inputs.size()):
				if inputs[i].is_active:
					currentActivations += 1
			if currentActivations == inputs.size():
				activate()
			else:
				deactivate()
		activateTypes.Timed:
			symbol.frame_coords.y = 3
			cooldownTimer -= delta
			if cooldownTimer < 0:
				cooldownTimer = cooldownTime
				activating = true
			if path.progress_ratio == 1.0:
				activating = false
			if activating:
				activate()
			else:
				deactivate()
		activateTypes.Contact:
			symbol.frame_coords.y = 4
			if player:
				if path.progress_ratio == 0.0:
					if player.CurrentState == player.States.Climb:
						activating = true
					elif player.global_position.y < global_position.y and (player.CurrentState == player.States.Idle or player.CurrentState == player.States.Run):
						activating = true
			if path.progress_ratio == 1.0:
				activating = false
			if activating:
				activate()
			else:
				deactivate()
	
	queue_redraw()

func activate():
	if path.progress_ratio < 1.0:
		path.progress += activateSpeed
		if player:
			if player.playerNum == -1:
				sprite.frame = 1
				symbol.frame_coords.x = 1
				colour = Color("6fe5e9")
			elif player.playerNum == 1:
				sprite.frame = 2
				symbol.frame_coords.x = 2
				colour = Color("ff6cf5")
		else:
			sprite.frame = 1
			symbol.frame_coords.x = 1

func deactivate():
	if path.progress_ratio > 0.0:
		path.progress -= deactivateSpeed
		sprite.frame = 0
		symbol.frame_coords.x = 0
		colour = Color("fff9ae")

func reset():
	path.progress = 0
	sprite.frame = 0
	symbol.frame_coords.x = 0
	colour = Color("fff9ae")

func _draw() -> void:
	draw_line(curve.get_point_position(0), curve.get_point_position(1), Color("4b4b4b"), 4, false)
	draw_line(curve.get_point_position(0), curve.get_point_position(1), colour, 2, false)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player or body is Clone:
		player = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player or body is Clone:
		player = null
