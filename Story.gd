extends Node2D

func _ready():
	pass

func _on_StartGame_pressed():
	Global.goto_scene(Global.Scene.OVERWORLD)
