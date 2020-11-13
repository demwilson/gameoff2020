extends Area2D

var overworld
var canMove = true
var facing = "right"
var Moves = {
	"right": Vector2(1,0),
	"left": Vector2(-1,0),
	"up": Vector2(0,-1),
	"down": Vector2(0,1)
}
var Raycasts = {
	"right": "RayCastRight",
	"left": "RayCastLeft",
	"up": "RayCastUp",
	"down": "RayCastDown"
}
var previousDir
signal collided
func _ready():
	overworld = get_parent()
	
func _process(delta):
	if canMove:
		for dir in Moves.keys():
			if Input.is_action_pressed(dir):
				move(dir)
				
func move(dir):
	var tileSize = overworld.tile_map.tileSize
	facing = dir
	if has_collided(facing, dir):
		return
	canMove = false
	$AnimationPlayer.play(facing)
	$MoveTween.interpolate_property(self, "position", position, position + Moves[facing] * tileSize, $AnimationPlayer.current_animation_length, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$MoveTween.start()
	return true

func has_collided(facing, dir):
	if get_node(Raycasts[facing]).is_colliding():
		var hitCollider = get_node(Raycasts[facing]).get_collider()
		if hitCollider:
			var tileMap = hitCollider
			var hitPos = get_node(Raycasts[facing]).get_collision_point()
			emit_signal('collided', hitPos, dir)
		return true
	else:
		return false

func _on_MoveTween_tween_completed(object, key):
	canMove = true
