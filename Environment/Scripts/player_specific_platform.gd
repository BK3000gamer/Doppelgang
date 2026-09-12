extends StaticBody2D

@export var playerNum: int = 0
@export var inputs: Array [Area2D] = []
@export var switchType: switchTypes
@export var switchTime: float

@onready var sprite := $Sprite2D

enum switchTypes {
	None,
	Inputs,
	Timed,
	Jump
}

var currentActivations := 0
var switchTimer: float

var player_1: Player
var player_2: Player

func _ready() -> void:
	_update_visual_state()
	switchTimer = switchTime

func _physics_process(delta: float) -> void:
	#Get players
	player_1 = get_tree().get_first_node_in_group("player_1")
	player_2 = get_tree().get_first_node_in_group("player_2")
	
	switchTimer -= delta
	
	#Set collsion layers
	if playerNum == -1:
		set_collision_layer_value(3, true)
		set_collision_layer_value(4, false)
	elif playerNum == 1:
		set_collision_layer_value(4, true)
		set_collision_layer_value(3, false)
	
	match switchType:
		switchTypes.None:
			pass
		switchTypes.Inputs:
			currentActivations = 0
				
			for i in range(inputs.size()):
				if inputs[i].is_active:
					currentActivations += 1
			if currentActivations == inputs.size():
				_switch()
		switchTypes.Timed:
			if switchTimer < 0:
				_switch()
				_update_visual_state()
				switchTimer = switchTime
		switchTypes.Jump:
			if player_1:
				if player_1.CurrentState == player_1.States.Jump or player_1.CurrentState == player_1.States.Clone:
					_switch()
					_update_visual_state()
			if player_2:
				if player_2.CurrentState == player_2.States.Jump or player_2.CurrentState == player_2.States.Clone:
					_switch()
					_update_visual_state()

func _switch() -> void:
	playerNum = -playerNum

func _update_visual_state() -> void:
	if !sprite:
		return
	
	sprite.modulate = Color.RED if playerNum == 1 else Color.BLUE
