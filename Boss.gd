extends Area2D

var overworld
var canMove = true
var accumilatedDelta = 0.0
var actionRate = 1.0
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

signal bossCollided

func _ready():
	overworld = get_parent().get_parent()
	connect("bossCollided", overworld.tile_map, "_on_Boss_collided")

func _process(delta):
	accumilatedDelta += delta
	if canMove && accumilatedDelta >= actionRate:
		accumilatedDelta = 0.0
		var keys = Moves.keys()
		var dir = keys[randi() % keys.size()]
		move(dir)

func move(dir):
	var tileSize = overworld.tile_map.tileSize
	if has_collided(dir):
		return
	canMove = false
	$AnimationPlayer.play(dir)
	$MoveTween.interpolate_property(self, "position", position, position + Moves[dir] * tileSize, $AnimationPlayer.current_animation_length, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$MoveTween.start()
	return true

func set_can_move(active):
	canMove = active

func has_collided(dir):
	if get_node(Raycasts[dir]).is_colliding():
		var hitCollider = get_node(Raycasts[dir]).get_collider()
		if hitCollider:
			emit_signal('bossCollided', hitCollider, dir)
		return true
	else:
		return false

func _on_MoveTween_tween_completed(object, key):
	canMove = true
