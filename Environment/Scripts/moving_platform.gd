extends Path2D

@export var activateType: activateTypes
@export var activateSpeed := 5.0
@export var deactivateSpeed := 2.5
@export var cooldownTime: float = 5
@export var inputs: Array [Area2D] = []

@onready var path = $PathFollow2D
@onready var animation = $AnimationPlayer

var currentActivations := 0
var cooldownTimer: float
var player: CharacterBody2D
var activating: = false

enum activateTypes {
	Inputs,
	Timed,
	Contact
}

func _physics_process(delta: float) -> void:
	
	match activateType:
		activateTypes.Inputs:
			currentActivations = 0
				
			for i in range(inputs.size()):
				if inputs[i].is_active:
					currentActivations += 1
			if currentActivations == inputs.size():
				activate()
			else:
				deactivate()
		activateTypes.Timed:
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

func activate():
	if path.progress_ratio < 1.0:
		path.progress += activateSpeed

func deactivate():
	if path.progress_ratio > 0.0:
		path.progress -= deactivateSpeed

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player or body is Clone:
		player = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player or body is Clone:
		player = null
