extends Node2D
class_name Camera

@onready var views := {
	"normal": {
		viewport = $"/root/Game/NormalViewport",
		subviewport = $"/root/Game/NormalViewport/SubViewport",
		camera = $"/root/Game/NormalViewport/SubViewport/Camera2D"
	},
	"horizontal": {
		viewport = $"/root/Game/HorizontalViewport",
		subviewport_1 = $"/root/Game/HorizontalViewport/SubViewportContainer1/SubViewport",
		subviewport_2 = $"/root/Game/HorizontalViewport/SubViewportContainer2/SubViewport",
		camera_1 = $"/root/Game/HorizontalViewport/SubViewportContainer1/SubViewport/Camera2D",
		camera_2 = $"/root/Game/HorizontalViewport/SubViewportContainer2/SubViewport/Camera2D"
	},
	"vertical": {
		viewport = $"/root/Game/VerticalViewport",
		subviewport_1 = $"/root/Game/VerticalViewport/SubViewportContainer1/SubViewport",
		subviewport_2 = $"/root/Game/VerticalViewport/SubViewportContainer2/SubViewport",
		camera_1 = $"/root/Game/VerticalViewport/SubViewportContainer1/SubViewport/Camera2D",
		camera_2 = $"/root/Game/VerticalViewport/SubViewportContainer2/SubViewport/Camera2D"
	}
}
var currentRoom

var player_1: Player
var player_2: Player

enum viewTypes {
	Normal,
	Horizontal,
	Vertical,
	SingleHorizontal,
	SingleVertical,
}

var viewType := viewTypes.Normal

var transitioning: bool
var tween: Tween

func _ready() -> void:
	views["horizontal"].subviewport_1.world_2d = views["normal"].subviewport.world_2d
	views["horizontal"].subviewport_2.world_2d = views["normal"].subviewport.world_2d
	views["vertical"].subviewport_1.world_2d = views["normal"].subviewport.world_2d
	views["vertical"].subviewport_2.world_2d = views["normal"].subviewport.world_2d

func _physics_process(_delta: float) -> void:
	player_1 = get_tree().get_first_node_in_group("player_1")
	player_2 = get_tree().get_first_node_in_group("player_2")
	
	if currentRoom:
		match currentRoom.roomType:
			currentRoom.roomTypes.Normal:
				viewType = viewTypes.Normal
			currentRoom.roomTypes.Horizontal:
				if player_1 and player_2:
					if player_1.global_position.x > (currentRoom.cameraCheckpoint_2.global_position.x + 160):
						if abs(player_2.global_position.x - (currentRoom.cameraCheckpoint_2.global_position.x + 160)) <= 320:
							viewType = viewTypes.SingleHorizontal
						else:
							viewType = viewTypes.Horizontal
					elif player_2.global_position.x > (currentRoom.cameraCheckpoint_2.global_position.x + 160):
						if abs(player_1.global_position.x - (currentRoom.cameraCheckpoint_2.global_position.x + 160)) <= 320:
							viewType = viewTypes.SingleHorizontal
						else:
							viewType = viewTypes.Horizontal
					elif player_1.global_position.x < (currentRoom.cameraCheckpoint_1.global_position.x - 160):
						if abs(player_2.global_position.x - (currentRoom.cameraCheckpoint_1.global_position.x - 160)) <= 320:
							viewType = viewTypes.SingleHorizontal
						else:
							viewType = viewTypes.Horizontal
					elif player_2.global_position.x < (currentRoom.cameraCheckpoint_1.global_position.x - 160):
						if abs(player_1.global_position.x - (currentRoom.cameraCheckpoint_1.global_position.x - 160)) <= 320:
							viewType = viewTypes.SingleHorizontal
						else:
							viewType = viewTypes.Horizontal
					elif abs(player_1.global_position.x - player_2.global_position.x) <= 320:
						viewType = viewTypes.SingleHorizontal
					else:
						viewType = viewTypes.Horizontal
				else:
					viewType = viewTypes.SingleHorizontal
			currentRoom.roomTypes.Vertical:
				if player_1 and player_2:
					if player_1.global_position.y > (currentRoom.cameraCheckpoint_2.global_position.y + 90):
						if abs(player_2.global_position.y - (currentRoom.cameraCheckpoint_2.global_position.y + 90)) <= 180:
							viewType = viewTypes.SingleVertical
						else:
							viewType = viewTypes.Vertical
					elif player_2.global_position.y > (currentRoom.cameraCheckpoint_2.global_position.y + 90):
						if abs(player_1.global_position.y - (currentRoom.cameraCheckpoint_2.global_position.y + 90)) <= 180:
							viewType = viewTypes.SingleVertical
						else:
							viewType = viewTypes.Vertical
					elif player_1.global_position.y < (currentRoom.cameraCheckpoint_1.global_position.y - 90):
						if abs(player_2.global_position.y - (currentRoom.cameraCheckpoint_1.global_position.y - 90)) <= 180:
							viewType = viewTypes.SingleVertical
						else:
							viewType = viewTypes.Vertical
					elif player_2.global_position.y < (currentRoom.cameraCheckpoint_1.global_position.y - 90):
						if abs(player_1.global_position.y - (currentRoom.cameraCheckpoint_1.global_position.y - 90)) <= 180:
							viewType = viewTypes.SingleVertical
						else:
							viewType = viewTypes.Vertical
					elif abs(player_1.global_position.y - player_2.global_position.y) <= 180:
						viewType = viewTypes.SingleVertical
					else:
						viewType = viewTypes.Vertical
				else:
					viewType = viewTypes.SingleVertical
		
		if transitioning:
			return
		
		match viewType:
			viewTypes.Normal:
				views["normal"].viewport.visible = true
				views["horizontal"].viewport.visible = false
				views["vertical"].viewport.visible = false
				
				views["normal"].camera.global_position = currentRoom.cameraCheckpoint_1.global_position
			viewTypes.Horizontal:
				views["normal"].viewport.visible = false
				views["horizontal"].viewport.visible = true
				views["vertical"].viewport.visible = false
				
				views["horizontal"].camera_1.global_position.y = currentRoom.cameraCheckpoint_1.global_position.y
				views["horizontal"].camera_2.global_position.y = currentRoom.cameraCheckpoint_1.global_position.y
				if player_1.global_position.x < player_2.global_position.x:
					views["horizontal"].camera_1.global_position.x = player_1.global_position.x
					views["horizontal"].camera_2.global_position.x = player_2.global_position.x
				else:
					views["horizontal"].camera_1.global_position.x = player_2.global_position.x
					views["horizontal"].camera_2.global_position.x = player_1.global_position.x
				
				views["horizontal"].camera_1.global_position.x = clamp(views["horizontal"].camera_1.global_position.x, currentRoom.cameraCheckpoint_1.global_position.x - 160, currentRoom.cameraCheckpoint_2.global_position.x + 160)
				views["horizontal"].camera_2.global_position.x = clamp(views["horizontal"].camera_2.global_position.x, currentRoom.cameraCheckpoint_1.global_position.x - 160, currentRoom.cameraCheckpoint_2.global_position.x + 160)
			viewTypes.SingleHorizontal:
				views["normal"].viewport.visible = true
				views["horizontal"].viewport.visible = false
				views["vertical"].viewport.visible = false
				
				views["normal"].camera.global_position.y = currentRoom.cameraCheckpoint_1.global_position.y
				if player_1 and player_2:
					views["normal"].camera.global_position.x = (player_1.global_position.x + player_2.global_position.x) / 2.0
				elif player_1:
					views["normal"].camera.global_position.x = player_1.global_position.x
				elif player_2:
					views["normal"].camera.global_position.x = player_2.global_position.x
				
				views["normal"].camera.global_position.x = clamp(views["normal"].camera.global_position.x, currentRoom.cameraCheckpoint_1.global_position.x, currentRoom.cameraCheckpoint_2.global_position.x)
			viewTypes.Vertical:
				views["normal"].viewport.visible = false
				views["horizontal"].viewport.visible = false
				views["vertical"].viewport.visible = true
				
				views["vertical"].camera_1.global_position.x = currentRoom.cameraCheckpoint_1.global_position.x
				views["vertical"].camera_2.global_position.x = currentRoom.cameraCheckpoint_1.global_position.x
				if player_1.global_position.y < player_2.global_position.y:
					views["vertical"].camera_1.global_position.y = player_1.global_position.y
					views["vertical"].camera_2.global_position.y = player_2.global_position.y
				else:
					views["vertical"].camera_1.global_position.y = player_2.global_position.y
					views["vertical"].camera_2.global_position.y = player_1.global_position.y
				
				views["vertical"].camera_1.global_position.y = clamp(views["vertical"].camera_1.global_position.y, currentRoom.cameraCheckpoint_1.global_position.y - 90, currentRoom.cameraCheckpoint_2.global_position.y + 90)
				views["vertical"].camera_2.global_position.y = clamp(views["vertical"].camera_2.global_position.y, currentRoom.cameraCheckpoint_1.global_position.y - 90, currentRoom.cameraCheckpoint_2.global_position.y + 90)
			viewTypes.SingleVertical:
				views["normal"].viewport.visible = true
				views["horizontal"].viewport.visible = false
				views["vertical"].viewport.visible = false
				
				views["normal"].camera.global_position.x = currentRoom.cameraCheckpoint_1.global_position.x
				if player_1 and player_2:
					views["normal"].camera.global_position.y = (player_1.global_position.y + player_2.global_position.y) / 2.0
				elif player_1:
					views["normal"].camera.global_position.y = player_1.global_position.y
				elif player_2:
					views["normal"].camera.global_position.y = player_2.global_position.y
				
				views["normal"].camera.global_position.y = clamp(views["normal"].camera.global_position.y, currentRoom.cameraCheckpoint_1.global_position.y, currentRoom.cameraCheckpoint_2.global_position.y)

func tween_camera() -> void:
	transitioning = true
	
	if tween:
		tween.kill()
	
	var target = currentRoom.cameraCheckpoint_1.global_position
	
	if player_1 and player_2:
		target.x = (player_1.global_position.x + player_2.global_position.x) / 2.0
	elif player_1:
		target.x = player_1.global_position.x
	elif player_2:
		target.x = player_2.global_position.x
	
	
	if player_1 and player_2:
		target.y = (player_1.global_position.y + player_2.global_position.y) / 2.0
	elif player_1:
		target.y = player_1.global_position.y
	elif player_2:
		target.y = player_2.global_position.y
	
	target.x = clamp(
		target.x,
		currentRoom.cameraCheckpoint_1.global_position.x,
		currentRoom.cameraCheckpoint_2.global_position.x
		)
	
	target.y = clamp(
		target.y,
		currentRoom.cameraCheckpoint_1.global_position.y,
		currentRoom.cameraCheckpoint_2.global_position.y
		)
	
	var currentPos = views["normal"].camera.global_position
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(views["normal"].camera, "global_position", target, 0.2).from(currentPos)
	
	tween.finished.connect(func(): transitioning = false)
