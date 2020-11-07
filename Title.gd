extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Start_pressed():
	Global.goto_scene(Global.Scene.OVERWORLD)
