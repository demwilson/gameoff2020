extends Sprite

signal animation_step_complete
signal damaged_animation_complete

const Creature = preload("res://game/Creature.gd")
onready var name_label = get_node("Name")
onready var health = get_node("Health")
onready var ticks = get_node("Ticks")
onready var ani_player = get_node("AnimationPlayer")
onready var tween = get_node("Tween")
var CombatAnimation = preload("res://combat/CombatAnimation.tscn")

const IDLE_ANIMATION_NAME = "idle"
const DAMAGED_PATH = "_damaged"
const PLAYER_H_FRAMES = 8
const BASE_H_FRAMES = 1
const BASE_V_FRAMES = 1
const TICKS_LOCATION_Y_LARGE_TALL = 32
const TICKS_LOCATION_Y_MEDIUM = 16
const LEFT_SIDE = 0
const RIGHT_SIDE = 1
const INITIAL_STATE = 0
const STATE_STEP = 1
const PIXEL_DISTANCE = 150
const MOVE_TIME = 0.20


var state = null
var creature_name = null
var show_name = false
var show_health = false
var show_ticks = false
var parent = false
var creature_size = Creature.CreatureSize.MEDIUM
var base_texture = null
var damaged_texture = null
var texture_path = null
var idle_path = null

var combat_side = null
var original_pos = null
var new_pos = null
var move_details = null
var combat_creature = null

var is_being_hit = false

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
	
	base_texture = load(texture_path + Global.TEXTURE_FILE_EXTENSION)
	damaged_texture = load(texture_path + DAMAGED_PATH + Global.TEXTURE_FILE_EXTENSION)
	self.set("texture", base_texture)
	var idle = load(idle_path)
	ani_player.add_animation(IDLE_ANIMATION_NAME, idle)
	ani_player.play(IDLE_ANIMATION_NAME)
	# Framing PNG
	self.vframes = BASE_V_FRAMES
	update_hframes()
	match self.creature_size:
		Creature.CreatureSize.LARGE_TALL:
			self.ticks.rect_position.y = TICKS_LOCATION_Y_LARGE_TALL
		_:
			self.ticks.rect_position.y = TICKS_LOCATION_Y_MEDIUM

func update_hframes():
	# Temporary while waiting for animation stuff
	match self.creature_name:
		Global.PLAYER_NAME:
			self.hframes = PLAYER_H_FRAMES
		_:
			self.hframes = BASE_H_FRAMES

func stop_animation():
	ani_player.stop()

func move_forward(side):
	combat_side = side
	original_pos = position.x
	var amount = PIXEL_DISTANCE
	if side == RIGHT_SIDE:
		amount = -amount
	new_pos = original_pos + amount
	tween.interpolate_property(self, 'position', Vector2(original_pos, position.y), Vector2(new_pos, position.y), MOVE_TIME, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

func move_backward():
	tween.interpolate_property(self, 'position', Vector2(new_pos, position.y), Vector2(original_pos, position.y) , MOVE_TIME, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

func damage_creature():
	ani_player.stop()
	self.set("texture", damaged_texture)
	self.set_frame(0)
	self.hframes = BASE_H_FRAMES
	var original_x = position.x
	var right_sway = position.x + 5
	var left_sway = position.x - 10
	is_being_hit = true
	tween.interpolate_property(self, 'position', position, Vector2(right_sway, position.y) , 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'position', position, Vector2(left_sway, position.y) , 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.1)
	tween.interpolate_property(self, 'position', position, Vector2(original_x, position.y) , 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.2)
	tween.start()

func animation_completed():
	emit_signal("animation_step_complete")

func apply_animation(move):
	# combat animation
	var attack_anim = CombatAnimation.instance()
	attack_anim.base_path = move.animation_path
	attack_anim.combat_side = combat_side
	attack_anim.connect("animation_action_complete", self, "animation_completed")
	self.add_child(attack_anim)

func _on_Tween_tween_all_completed():
	if is_being_hit:
		is_being_hit = false
		self.set("texture", base_texture)
		update_hframes()
		ani_player.play(IDLE_ANIMATION_NAME)
		emit_signal("damaged_animation_complete")
	else:
		emit_signal("animation_step_complete")
