extends Node2D

func _ready():
	pass

func _on_StartGame_pressed():
	Global.reset_global_data()
	Global.build_player()
	Global.goto_scene(Global.Scene.OVERWORLD, "restart_overworld")
