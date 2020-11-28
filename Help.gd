extends Node2D

signal closed_scene(scene_type)

var overlay_type = null

func _ready(): pass

func close_help_screen():
	emit_signal("closed_scene", self.overlay_type)
	self.queue_free()

func _on_ReturnButton_pressed():
	close_help_screen()

