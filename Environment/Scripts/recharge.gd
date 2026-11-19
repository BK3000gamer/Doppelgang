extends Area2D

@export var refill_time: float = 2.5

var enabled: bool = true
var refill_timer: float

func _on_body_entered(body: Node2D) -> void:
	if body is Player and enabled:
		body.velocity = Vector2.ZERO
		if !body.group_1.is_empty() and !body.group_2.is_empty():
			if body.playerNum == -1:
				body.group_2[body.group_2.size() - 1]._change_state(body.States.Recall)
			elif body.playerNum == 1:
				body.group_1[body.group_1.size() - 1]._change_state(body.States.Recall)
		body.cloned = false
		body._change_state(body.States.Carried)
		await get_tree().create_timer(0.11).timeout
		body._change_state(body.States.Fall)
		enabled = false
		refill_timer = refill_time

func _process(delta: float) -> void:
	refill_timer -= delta
	if refill_timer < 0.0:
		enabled = true

func reset():
	enabled = true
