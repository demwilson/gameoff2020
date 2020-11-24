extends Node2D

onready var audio = get_node("AudioStreamPlayer")
onready var version_label = $CanvasLayer/Version
# Called when the node enters the scene tree for the first time.
func _ready():
	version_label.text = "v " + Global.version

func _on_Start_pressed():
	audio.stop()
	Global.goto_scene(Global.Scene.OVERWORLD)

func _input(event):
	if !event.is_pressed():
		return
	elif event.is_action("settings"):
		Global.goto_scene(Global.Scene.SETTINGS)
