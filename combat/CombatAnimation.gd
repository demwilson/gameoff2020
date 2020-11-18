extends Sprite

signal animation_action_complete

const Move = preload("res://game/Move.gd")
onready var ani_player = get_node("AnimationPlayer")

const BASE_SPRITE_PATH = "assets/Tony_Created_Assets/"
const BASE_SPRITE_FILE_EXTENSION = ".png"
const BASE_ANIMATION_PREFIX = "combat_anim_"
const BASE_ANIMATION_FILE_EXTENSION = ".tres"

const LEFT_SIDE = 0
const RIGHT_SIDE = 1

var combat_side = null
var base_path = null
const NEGATIVE_VECTOR = Vector2(-1, -1)

# Called when the node enters the scene tree for the first time.
func _ready():
	var animation_name = Move.animation_details[base_path][Move.AnimationDetail.BASE_NAME]
	var position_offset = Move.animation_details[base_path][Move.AnimationDetail.VECTOR_OFFSET]
	if combat_side == LEFT_SIDE:
		position_offset *= NEGATIVE_VECTOR
	self.hframes = Move.animation_details[base_path][Move.AnimationDetail.HFRAMES]
	self.vframes = Move.animation_details[base_path][Move.AnimationDetail.VFRAMES]
	self.position = position_offset
	var texture_path = BASE_SPRITE_PATH + animation_name + BASE_SPRITE_FILE_EXTENSION
	self.set("texture", load(texture_path))
	var animation_path = BASE_SPRITE_PATH + BASE_ANIMATION_PREFIX + animation_name + BASE_ANIMATION_FILE_EXTENSION
	var animation = load(animation_path)
	ani_player.add_animation(animation_name, animation)
	ani_player.play(animation_name)

func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("animation_action_complete")
	self.queue_free()
