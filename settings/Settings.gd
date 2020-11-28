extends Node

signal closed_scene

var overlay_type = null

func _ready(): pass

func _on_OKButton_pressed():
	emit_signal("closed_scene", self.overlay_type)
	self.queue_free()
