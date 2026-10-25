extends Node2D
class_name Camera

@onready var views := {
	"normal": {
		root = $"/root/Game/NormalViewport",
		viewport = $"/root/Game/NormalViewport/LevelContainer",
		bg_viewport = $"/root/Game/NormalViewport/BackgroundContainer",
		subviewport = $"/root/Game/NormalViewport/LevelContainer/SubViewport",
		bg_subviewport = $"/root/Game/NormalViewport/BackgroundContainer/SubViewport",
		camera = $"/root/Game/NormalViewport/LevelContainer/SubViewport/Camera2D",
		bg_camera = $"/root/Game/NormalViewport/BackgroundContainer/SubViewport/Camera2D"
	},
	"horizontal": {
		viewport = $"/root/Game/HorizontalViewport",
		viewport_1 = $"/root/Game/HorizontalViewport/Half1/LevelContainer",
		viewport_2 = $"/root/Game/HorizontalViewport/Half2/LevelContainer",
		subviewport_1 = $"/root/Game/HorizontalViewport/Half1/LevelContainer/SubViewport",
		subviewport_2 = $"/root/Game/HorizontalViewport/Half2/LevelContainer/SubViewport",
		camera_1 = $"/root/Game/HorizontalViewport/Half1/LevelContainer/SubViewport/Camera2D",
		camera_2 = $"/root/Game/HorizontalViewport/Half2/LevelContainer/SubViewport/Camera2D",
		bg_viewport_1 = $"/root/Game/HorizontalViewport/Half1/BackgroundContainer",
		bg_viewport_2 = $"/root/Game/HorizontalViewport/Half2/BackgroundContainer",
		bg_subviewport_1 = $"/root/Game/HorizontalViewport/Half1/BackgroundContainer/SubViewport",
		bg_subviewport_2 = $"/root/Game/HorizontalViewport/Half2/BackgroundContainer/SubViewport",
		bg_camera_1 = $"/root/Game/HorizontalViewport/Half1/BackgroundContainer/SubViewport/Camera2D",
		bg_camera_2 = $"/root/Game/HorizontalViewport/Half2/BackgroundContainer/SubViewport/Camera2D"
	},
	"vertical": {
		viewport = $"/root/Game/VerticalViewport",
		viewport_1 = $"/root/Game/VerticalViewport/Half1/LevelContainer",
		viewport_2 = $"/root/Game/VerticalViewport/Half2/LevelContainer",
		subviewport_1 = $"/root/Game/VerticalViewport/Half1/LevelContainer/SubViewport",
		subviewport_2 = $"/root/Game/VerticalViewport/Half2/LevelContainer/SubViewport",
		camera_1 = $"/root/Game/VerticalViewport/Half1/LevelContainer/SubViewport/Camera2D",
		camera_2 = $"/root/Game/VerticalViewport/Half2/LevelContainer/SubViewport/Camera2D",
		bg_viewport_1 = $"/root/Game/VerticalViewport/Half1/BackgroundContainer",
		bg_viewport_2 = $"/root/Game/VerticalViewport/Half2/BackgroundContainer",
		bg_subviewport_1 = $"/root/Game/VerticalViewport/Half1/BackgroundContainer/SubViewport",
		bg_subviewport_2 = $"/root/Game/VerticalViewport/Half2/BackgroundContainer/SubViewport",
		bg_camera_1 = $"/root/Game/VerticalViewport/Half1/BackgroundContainer/SubViewport/Camera2D",
		bg_camera_2 = $"/root/Game/VerticalViewport/Half2/BackgroundContainer/SubViewport/Camera2D"
	}
}
var currentRoom: Room

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

const HALF_VIEW_W := 160.0

func _ready() -> void:
	views["horizontal"].subviewport_1.world_2d = views["normal"].subviewport.world_2d
	views["horizontal"].subviewport_2.world_2d = views["normal"].subviewport.world_2d
	views["vertical"].subviewport_1.world_2d = views["normal"].subviewport.world_2d
	views["vertical"].subviewport_2.world_2d = views["normal"].subviewport.world_2d
	
	_offset_parallax(views["horizontal"].bg_subviewport_1, 1.0)
	_offset_parallax(views["horizontal"].bg_subviewport_2, -1.0)

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
				views["normal"].root.visible = true
				views["horizontal"].viewport.visible = false
				views["vertical"].viewport.visible = false
				
				var cam_pos: Vector2
				
				cam_pos = currentRoom.cameraCheckpoint_1.global_position
				
				var cam_subpixel_offset = cam_pos.round() - cam_pos
				views["normal"].viewport.material.set_shader_parameter("cam_offset", cam_subpixel_offset)
				views["normal"].bg_viewport.material.set_shader_parameter("cam_offset", _bg_offset(views["normal"].bg_subviewport, cam_subpixel_offset))
				
				views["normal"].camera.global_position = cam_pos.round()
				views["normal"].bg_camera.global_position = cam_pos.round()
			viewTypes.Horizontal:
				views["normal"].root.visible = false
				views["horizontal"].viewport.visible = true
				views["vertical"].viewport.visible = false
				
				var cam_pos_1: Vector2
				var cam_pos_2: Vector2
				
				cam_pos_1.y = currentRoom.cameraCheckpoint_1.global_position.y
				cam_pos_2.y = currentRoom.cameraCheckpoint_1.global_position.y
				
				if player_1.global_position.x < player_2.global_position.x:
					cam_pos_1.x = player_1.global_position.x
					cam_pos_2.x = player_2.global_position.x
				else:
					cam_pos_1.x = player_2.global_position.x
					cam_pos_2.x = player_1.global_position.x
				
				cam_pos_1.x = clamp(cam_pos_1.x, currentRoom.cameraCheckpoint_1.global_position.x - 160, currentRoom.cameraCheckpoint_2.global_position.x + 160)
				cam_pos_2.x = clamp(cam_pos_2.x, currentRoom.cameraCheckpoint_1.global_position.x - 160, currentRoom.cameraCheckpoint_2.global_position.x + 160)
				
				var cam_subpixel_offset_1 = cam_pos_1.round() - cam_pos_1
				var cam_subpixel_offset_2 = cam_pos_2.round() - cam_pos_2
				views["horizontal"].viewport_1.material.set_shader_parameter("cam_offset", cam_subpixel_offset_1)
				views["horizontal"].viewport_2.material.set_shader_parameter("cam_offset", cam_subpixel_offset_2)
				views["horizontal"].bg_viewport_1.material.set_shader_parameter("cam_offset", _bg_offset(views["horizontal"].bg_subviewport_1, cam_subpixel_offset_1))
				views["horizontal"].bg_viewport_2.material.set_shader_parameter("cam_offset", _bg_offset(views["horizontal"].bg_subviewport_2, cam_subpixel_offset_2))
				
				views["horizontal"].camera_1.global_position = cam_pos_1.round()
				views["horizontal"].camera_2.global_position = cam_pos_2.round()
				views["horizontal"].bg_camera_1.global_position = cam_pos_1.round()
				views["horizontal"].bg_camera_2.global_position = cam_pos_2.round()
			viewTypes.SingleHorizontal:
				views["normal"].root.visible = true
				views["horizontal"].viewport.visible = false
				views["vertical"].viewport.visible = false
				
				var cam_pos: Vector2
				
				cam_pos.y = currentRoom.cameraCheckpoint_1.global_position.y
				
				if player_1 and player_2:
					cam_pos.x = (player_1.global_position.x + player_2.global_position.x) / 2.0
				elif player_1:
					cam_pos.x = player_1.global_position.x
				elif player_2:
					cam_pos.x = player_2.global_position.x
				
				cam_pos.x = clamp(cam_pos.x, currentRoom.cameraCheckpoint_1.global_position.x, currentRoom.cameraCheckpoint_2.global_position.x)
				
				var cam_subpixel_offset = cam_pos.round() - cam_pos
				views["normal"].viewport.material.set_shader_parameter("cam_offset", cam_subpixel_offset)
				views["normal"].bg_viewport.material.set_shader_parameter("cam_offset", _bg_offset(views["normal"].bg_subviewport, cam_subpixel_offset))
				
				views["normal"].camera.global_position = cam_pos.round()
				views["normal"].bg_camera.global_position = cam_pos.round()
			viewTypes.Vertical:
				views["normal"].root.visible = false
				views["horizontal"].viewport.visible = false
				views["vertical"].viewport.visible = true
				
				var cam_pos_1: Vector2
				var cam_pos_2: Vector2
				
				cam_pos_1.x = currentRoom.cameraCheckpoint_1.global_position.x
				cam_pos_2.x = currentRoom.cameraCheckpoint_1.global_position.x
				
				if player_1.global_position.y < player_2.global_position.y:
					cam_pos_1.y = player_1.global_position.y
					cam_pos_2.y = player_2.global_position.y
				else:
					cam_pos_1.y = player_2.global_position.y
					cam_pos_2.y = player_1.global_position.y
				
				cam_pos_1.y = clamp(cam_pos_1.y, currentRoom.cameraCheckpoint_1.global_position.y - 90, currentRoom.cameraCheckpoint_2.global_position.y + 90)
				cam_pos_2.y = clamp(cam_pos_2.y, currentRoom.cameraCheckpoint_1.global_position.y - 90, currentRoom.cameraCheckpoint_2.global_position.y + 90)
				
				var cam_subpixel_offset_1 = cam_pos_1.round() - cam_pos_1
				var cam_subpixel_offset_2 = cam_pos_2.round() - cam_pos_2
				views["vertical"].viewport_1.material.set_shader_parameter("cam_offset", cam_subpixel_offset_1)
				views["vertical"].viewport_2.material.set_shader_parameter("cam_offset", cam_subpixel_offset_2)
				views["vertical"].bg_viewport_1.material.set_shader_parameter("cam_offset", _bg_offset(views["vertical"].bg_subviewport_1, cam_subpixel_offset_1))
				views["vertical"].bg_viewport_2.material.set_shader_parameter("cam_offset", _bg_offset(views["vertical"].bg_subviewport_2, cam_subpixel_offset_2))
				
				views["vertical"].camera_1.global_position = cam_pos_1.round()
				views["vertical"].camera_2.global_position = cam_pos_2.round()
				views["vertical"].bg_camera_1.global_position = cam_pos_1.round()
				views["vertical"].bg_camera_2.global_position = cam_pos_2.round()
			viewTypes.SingleVertical:
				views["normal"].root.visible = true
				views["horizontal"].viewport.visible = false
				views["vertical"].viewport.visible = false
				
				var cam_pos: Vector2
				
				cam_pos.x = currentRoom.cameraCheckpoint_1.global_position.x
				
				if player_1 and player_2:
					cam_pos.y = (player_1.global_position.y + player_2.global_position.y) / 2.0
				elif player_1:
					cam_pos.y = player_1.global_position.y
				elif player_2:
					cam_pos.y = player_2.global_position.y
				
				cam_pos.y = clamp(cam_pos.y, currentRoom.cameraCheckpoint_1.global_position.y, currentRoom.cameraCheckpoint_2.global_position.y)
				
				var cam_subpixel_offset = cam_pos.round() - cam_pos
				views["normal"].viewport.material.set_shader_parameter("cam_offset", _bg_offset(views["normal"].bg_subviewport, cam_subpixel_offset))
				
				views["normal"].camera.global_position = cam_pos.round()
				views["normal"].bg_camera.global_position = cam_pos.round()

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
	tween.tween_method(func(p: Vector2):
		views["normal"].camera.global_position = p
		views["normal"].bg_camera.global_position = p
	, currentPos, target, 0.2)
	
	tween.finished.connect(func(): transitioning = false)

func _offset_parallax(subviewport: SubViewport, dir: float) -> void:
	var bg := subviewport.get_node("ParallaxBackground")
	if bg == null:
		return
	for p in bg.get_children():
		if p is Parallax2D:
			p.scroll_offset.x = -(HALF_VIEW_W * (1.0 - p.scroll_scale.x)) + dir * HALF_VIEW_W * (1.0 - p.scroll_scale.x)

func _bg_offset(sub: SubViewport, offset: Vector2) -> Vector2:
	var bg: Node2D = sub.get_node("ParallaxBackground")
	var s := Vector2.ZERO
	var n := 0
	for p in bg.get_children():
		if p is Parallax2D:
			s += p.scroll_scale
			n += 1
	if n == 0:
		return Vector2.ZERO
	return offset * (s / n)
