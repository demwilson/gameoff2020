extends Node2D

func _ready():
	get_tree().paused = true

func _input(event):
	if !event.is_pressed():
		return
	elif event.is_action("help_screen"):
		close_help_screen()

func close_help_screen():
	get_tree().paused = false
	self.queue_free()

func _on_ReturnButton_pressed():
	close_help_screen()

