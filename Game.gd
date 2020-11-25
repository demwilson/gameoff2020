extends Node2D

const TitleScene = preload("res://Title.tscn")
const PauseOverlay = preload("res://PauseOverlay.tscn")
const Settings = preload("res://settings/Settings.tscn")

# Used for pause screen
var pause_overlay = null
var settings_overlay = null

func _ready():
	OS.set_window_size(Vector2(1280, 720))
	var title = TitleScene.instance()
	Global.current_scene_id = Global.Scene.TITLE
	Global.current_scene = title
	title.connect("settings_pressed", self, "_on_settings_pressed")
	self.add_child(title)

func _input(event):
	if !event.is_pressed():
		return
	elif event.is_action("pause"):
		if !pause_overlay:
			pause_overlay = PauseOverlay.instance()
			self.add_child(pause_overlay)
	elif event.is_action("settings"):
		show_settings()

func show_settings():
	if !settings_overlay:
		settings_overlay = Settings.instance()
		self.add_child(settings_overlay)

func _on_settings_pressed():
	show_settings()
