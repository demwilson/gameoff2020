extends Position2D

const MAX_SIDE_MOVEMENT = 80

onready var label = get_node("Label")
onready var tween = get_node("Tween")
var amount = 0
var type = Global.AttackType.DAMAGE

var velocity = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	label.set_text(str(amount))
	match type:
		Global.AttackType.HEAL:
			label.set("custom_colors/font_color", Color("2eff27"))
		Global.AttackType.DAMAGE:
			label.set("custom_colors/font_color", Color("ff3131"))
	randomize()
	var side_movement = 1 + randi() % MAX_SIDE_MOVEMENT - MAX_SIDE_MOVEMENT/2
	velocity = Vector2(side_movement, 15)
	tween.interpolate_property(self, 'scale', scale, Vector2(1, 1), 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'scale', Vector2(1, 1), Vector2(0.1, 0.1), 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.5)
	tween.start()

func _on_Tween_tween_all_completed():
	self.queue_free()

func _process(delta):
	position -= velocity * delta
