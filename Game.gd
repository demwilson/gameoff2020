extends Node2D

const TitleScene = preload("res://Title.tscn")

func _ready():
	OS.set_window_size(Vector2(1280, 720))
	var title = TitleScene.instance()
	Global.current_scene_id = Global.Scene.TITLE
	Global.current_scene = title
	self.add_child(title)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
