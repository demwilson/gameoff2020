extends Sprite

const Creature = preload("res://game/Creature.gd")
onready var name_label = get_node("Name")
onready var health = get_node("Health")
onready var ticks = get_node("Ticks")
onready var ani_player = get_node("AnimationPlayer")

const IDLE_ANIMATION_NAME = "idle"
const PLAYER_H_FRAMES = 8
const BASE_H_FRAMES = 1
const BASE_V_FRAMES = 1
const TICKS_LOCATION_Y_LARGE_TALL = 32
const TICKS_LOCATION_Y_MEDIUM = 16

var creature_name = null
var show_name = false
var show_health = false
var show_ticks = false
var creature_size = Creature.CreatureSize.MEDIUM
var texture_path = null
var idle_path = null

# Called when the node enters the scene tree for the first time.
func _ready():
	if creature_name:
		name_label.text = creature_name
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
	# Framing PNG
	self.vframes = BASE_V_FRAMES
	# Temporary while waiting for animation stuff
	match self.creature_name:
		Global.PLAYER_NAME:
			self.hframes = PLAYER_H_FRAMES
		_:
			self.hframes = BASE_H_FRAMES
	match self.creature_size:
		Creature.CreatureSize.LARGE_TALL:
			self.ticks.rect_position.y = TICKS_LOCATION_Y_LARGE_TALL
		_:
			self.ticks.rect_position.y = TICKS_LOCATION_Y_MEDIUM

func stop_animation():
	ani_player.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
