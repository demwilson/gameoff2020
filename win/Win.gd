extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if !event.is_pressed():
		return
	elif event.is_action("ui_accept"):
		_on_Restart_pressed()

func _on_Restart_pressed():
	Global.goto_scene(Global.Scene.GROUND_CONTROL)
	self.queue_free()


func _on_Credits_pressed():
	Global.goto_scene(Global.Scene.CREDITS)
