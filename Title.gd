extends Node2D

signal settings_pressed
signal help_pressed
signal credits_pressed

onready var audio = get_node("AudioStreamPlayer")
onready var version_label = $CanvasLayer/Version
onready var continue_button = $CanvasLayer/Continue

func _ready():
	version_label.text = "v " + Global.version
	if Global.has_save():
		continue_button.disabled = false

func _input(event):
	if !event.is_pressed():
		return

func begin_audio():
	audio.play()

func _on_Start_pressed():
	audio.stop()
	Global.goto_scene(Global.Scene.STORY)

func _on_Settings_pressed():
	emit_signal("settings_pressed")

func _on_Help_pressed():
	emit_signal("help_pressed")

func _on_Credits_pressed():
	audio.stop()
	emit_signal("credits_pressed")

func _opened_overlay_closed(scene_type):
	begin_audio()

func _on_Continue_pressed():
	Global.load_game()
	audio.stop()
	Global.goto_scene(Global.Scene.GROUND_CONTROL)
