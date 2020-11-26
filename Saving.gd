extends Node2D

onready var info = $CanvasLayer/ColorRect/Label
const SAVING_WAIT_TIME = 1
const TIME_TO_READ = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.save_game()
	yield(get_tree().create_timer(SAVING_WAIT_TIME), "timeout")
	info.text = "Game Saved"
	yield(get_tree().create_timer(TIME_TO_READ), "timeout")
	self.queue_free()
