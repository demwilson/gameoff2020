extends Control

func _ready():
	get_tree().paused = true

func _input(event):
	if !event.is_pressed():
		return
	elif event.is_action("pause"):
		get_tree().paused = false
		self.queue_free()

