extends Node

enum LogLevel {
	ERROR,
	DEBUG,
	WARN,
	INFO,
	TRACE,
}

var debug = LogLevel.ERROR

func _init():
	pass

#func _input(event):
#	if !event.is_pressed():
#		return
#	elif event.is_action("settings"):
#		Global.goto_scene(Global.Scene.OVERWORLD)

func _on_OKButton_pressed():
	Global.goto_scene(Global.Scene.OVERWORLD)

	
