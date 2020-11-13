extends Sprite

const CombatGlobal = preload("res://combat/CombatGlobal.gd")
onready var name_label = get_node("Name")
onready var health = get_node("Health")
onready var ticks = get_node("Ticks")
onready var ani_player = get_node("AnimationPlayer")

const IDLE_ANIMATION_NAME = "idle"
const CREATURE_FRAMES_LARGE_TALL = 8
const CREATURE_FRAMES_MEDIUM = 4
const TICKS_LOCATION_Y_LARGE_TALL = 32
const TICKS_LOCATION_Y_MEDIUM = 16

var show_name = false
var show_health = false
var show_ticks = false
var creature_size = CombatGlobal.CreatureSize.MEDIUM
var texture_path = "res://assets/dead_hue.png"
var idle_path = "combat/animations/hue_idle.tres"

# Called when the node enters the scene tree for the first time.
func _ready():
	if show_name:
		name_label.visible = true
	if show_health:
		health.visible = true
	if show_ticks:
		ticks.visible = true
	
	self.set("texture", load(texture_path))
	var idle = load(idle_path)
	ani_player.add_animation(IDLE_ANIMATION_NAME, idle)
	ani_player.play(IDLE_ANIMATION_NAME)
	match self.creature_size:
		CombatGlobal.CreatureSize.LARGE_TALL:
			self.hframes = CREATURE_FRAMES_LARGE_TALL
			self.vframes = 2 # Temporary while using dummy monsters
			self.ticks.rect_position.y = TICKS_LOCATION_Y_LARGE_TALL
		_:
			self.hframes = CREATURE_FRAMES_MEDIUM
			self.vframes = 1 # Temporary while using dummy monsters
			self.ticks.rect_position.y = TICKS_LOCATION_Y_MEDIUM

func stop_animation():
	ani_player.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
