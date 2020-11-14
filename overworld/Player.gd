extends Area2D

var overworld
var canMove = true
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

var stepsTaken = 0
var stepsToTriggerCombat = 20
var encounterStep = 20

signal collided
func _ready():
	overworld = get_node("../..")
	generate_steps_to_trigger_combat()
	
func _process(delta):
	if canMove:
		if combat_triggered():
			stepsTaken = 0
			generate_steps_to_trigger_combat()
			canMove = false
			overworld.trigger_combat()
			return
		for dir in Moves.keys():
			if Input.is_action_pressed(dir):
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
			var tileMap = hitCollider
			var hitPos = get_node(Raycasts[dir]).get_collision_point()
			emit_signal('collided', hitPos, dir)
		return true
	else:
		return false

func _on_MoveTween_tween_completed(object, key):
	stepsTaken += 1
	canMove = true

func generate_steps_to_trigger_combat():
	stepsToTriggerCombat = randi() % encounterStep + (1 + randi() % encounterStep)

func combat_triggered():
	if stepsTaken >= stepsToTriggerCombat:
		return true
	else:
		return false
