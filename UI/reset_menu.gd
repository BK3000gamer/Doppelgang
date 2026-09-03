extends MarginContainer

var player_1: Player
var player_2: Player
var group_1: Array
var group_2: Array
var clone_1: Array
var clone_2: Array
var environment: Array

func _process(_delta: float) -> void:
	player_1 = get_tree().get_first_node_in_group("player_1")
	player_2 = get_tree().get_first_node_in_group("player_2")
	environment = get_tree().get_nodes_in_group("environment")
	group_1 = get_tree().get_nodes_in_group("player_1")
	group_2 = get_tree().get_nodes_in_group("player_2")
	clone_1 = []
	clone_2 = []
	for i in range(1, group_1.size()):
		if !clone_2.has(group_1[i]):
			clone_2.append(group_1[i])
	for i in range(1, group_2.size()):
		if !clone_1.has(group_2[i]):
			clone_1.append(group_2[i])

func _on_reset_pressed() -> void:
	if player_1:
		player_1._respawn()
	if player_2:
		player_2._respawn()
	
	for i in range(clone_1.size()):
		clone_1[i].queue_free()
	for i in range(clone_2.size()):
		clone_2[i].queue_free()
	
	for i in range(environment.size()):
		environment[i]._reset()
