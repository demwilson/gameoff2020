extends Control

onready var parent = get_parent()

func _ready():
	pass

func _input(event):
	if !event.is_pressed():
		return
	elif event.is_action("pause"):
		get_tree().paused = false
		self.queue_free()

