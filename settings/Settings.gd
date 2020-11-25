extends Node

func _ready():
	pass

func _input(event):
	if !event.is_pressed():
		return
	elif event.is_action("settings"):
		_on_OKButton_pressed()

func _on_OKButton_pressed():
	self.queue_free()
