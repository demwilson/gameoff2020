extends Position2D

onready var player = get_node("../Player")

func _process(delta):
	var target = player.global_position
	var targetPosX
	var targetPosY
	targetPosX = int(lerp(global_position.x, target.x, 0.8))
	targetPosY = int(lerp(global_position.y, target.y, 0.8))
	global_position = Vector2(targetPosX, targetPosY)

func set_start_position(startPosition):
	global_position = Vector2(startPosition.x, startPosition.y)
	
