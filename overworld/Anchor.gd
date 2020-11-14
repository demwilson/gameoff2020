extends Position2D

onready var player = get_node("../Player")

func _process(delta):
	var target = player.global_position
	var hardcodedDeltaForTrailing = 0.8
	var targetPosX
	var targetPosY
	targetPosX = int(lerp(global_position.x, target.x, hardcodedDeltaForTrailing))
	targetPosY = int(lerp(global_position.y, target.y, hardcodedDeltaForTrailing))
	global_position = Vector2(targetPosX, targetPosY)

func set_start_position(startPosition):
	global_position = Vector2(startPosition.x, startPosition.y)
	
