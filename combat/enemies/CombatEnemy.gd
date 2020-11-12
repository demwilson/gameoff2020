extends Sprite

onready var name_label = get_node("Name")
onready var health = get_node("Health")
onready var ticks = get_node("Ticks")
onready var ani_player = get_node("AnimationPlayer")

var show_name = false
var show_health = false
var show_ticks = false
var texture_path = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if show_name:
		name_label.visible = true
	if show_health:
		health.visible = true
	if show_ticks:
		ticks.visible = true
	
	if texture_path:
		self.set("texture", load("res://assets/undead_hue.png"))
	else:
		self.set("texture", load("res://assets/dead_hue.png"))
	

func stop_animation():
	ani_player.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
