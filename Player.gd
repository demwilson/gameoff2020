extends KinematicBody2D

var direction = Vector2()
var velocity = Vector2()
var overworld

var speed = 0
const ACCELERATION = 500
const MAX_SPEED = 80
const FRICTION = 500


var is_moving = false
var target_pos = Vector2()
var target_dir = Vector2()

var anim_direction = "down"
var anim_mode = "idle"
var animation
onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")

signal collided


# Called when the node enters the scene tree for the first time.
func _ready():
	overworld = get_parent()

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		animation_tree.set("parameters/idle/blend_position", input_vector)
		animation_tree.set("parameters/walk/blend_position", input_vector)
		animation_state.travel("walk")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animation_state.travel("idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	velocity = move_and_slide(velocity)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision:
			emit_signal('collided', collision)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	direction = Vector2()
#
#	if Input.is_action_pressed("Up"):
#		direction.y = -1
#		anim_direction = "up"
#	elif Input.is_action_pressed("Down"):	
#		direction.y = 1
#		anim_direction = "down"
#	elif Input.is_action_pressed("Right"):
#		direction.x = 1
#		anim_direction = "right"
#	elif Input.is_action_pressed("Left"):
#		direction.x = -1
#		anim_direction = "left"
#
#	if not is_moving and direction != Vector2():
#		anim_mode = "idle"
#		target_dir = direction
#		if game.tile_map.is_cell_vacant(self.position, target_dir):
#			target_pos = game.tile_map.update_child_pos(self)
#			is_moving = true
#	elif is_moving:
#		anim_mode = "walk"
#		speed = MAX_SPEED
#		velocity = speed * target_dir * delta
#
#		var pos = self.position
#		var distance_to_target = Vector2(abs(target_pos.x - pos.x) , abs(target_pos.y - pos.y))
#
#		if abs(velocity.x) > abs(distance_to_target.x):
#			velocity.x = distance_to_target.x * target_dir.x
#			is_moving = false
#			anim_mode = "idle"
#		if abs(velocity.y) > abs(distance_to_target.y):
#			velocity.y = distance_to_target.y * target_dir.y
#			is_moving = false
#			anim_mode = "idle"
#		move_and_collide(velocity)
#
#	animation = anim_mode + "_" + anim_direction
#	print("The animation is: " + str(animation))
#	animation_player.play(animation)
