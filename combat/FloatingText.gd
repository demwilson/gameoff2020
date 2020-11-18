extends Position2D

const Move = preload("res://game/Move.gd")
const MOVEMENT_RANGE = 40
const TEXT_MOVEMENT_SPEED = 15

onready var label = get_node("Label")
onready var tween = get_node("Tween")

var amount = 0
var type = null

var velocity = Vector2(0, 0)

var full_size = Vector2(1, 1)
var minimum_size = Vector2(0.1, 0.1)
var end_scale_up_time = 0.3
var begin_scale_down_wait = 0.5
var end_scale_down_time = 0.7

# Called when the node enters the scene tree for the first time.
func _ready():
	label.set_text(str(amount))
	match type:
		Move.MoveType.HEAL:
			label.set("custom_colors/font_color", Color(Global.TEXT_COLOR.HEAL))
		Move.MoveType.DAMAGE:
			label.set("custom_colors/font_color", Color(Global.TEXT_COLOR.DAMAGE))
		_:
			label.set("custom_colors/font_color", Color(Global.TEXT_COLOR.TEXT))
	# Generate a number between -20 and 20
	var side_movement = (1 + Global.random.randi() % MOVEMENT_RANGE) - (MOVEMENT_RANGE / 2)
	velocity = Vector2(side_movement, TEXT_MOVEMENT_SPEED)
	tween.interpolate_property(self, 'scale', scale, full_size, end_scale_up_time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'scale', full_size, minimum_size, end_scale_down_time, Tween.TRANS_LINEAR, Tween.EASE_OUT, begin_scale_down_wait)
	tween.start()

func _on_Tween_tween_all_completed():
	self.queue_free()

func _process(delta):
	position -= velocity * delta
