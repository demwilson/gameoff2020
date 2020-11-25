extends Node2D

const TitleScene = preload("res://Title.tscn")
const PauseOverlay = preload("res://PauseOverlay.tscn")
const Credits = preload("res://Credits.tscn")
const Help = preload("res://Help.tscn")
const Settings = preload("res://settings/Settings.tscn")

# Used for pause screen
var pause_overlay = null
var settings_overlay = null
var help_overlay = null
var credits_overlay = null

func _ready():
	OS.set_window_size(Vector2(1280, 720))
	var title = TitleScene.instance()
	Global.current_scene_id = Global.Scene.TITLE
	Global.current_scene = title
	title.connect("settings_pressed", self, "_on_settings_pressed")
	title.connect("help_pressed", self, "_on_help_pressed")
	title.connect("credits_pressed", self, "_on_credits_pressed")
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
	elif event.is_action("help_screen"):
		show_help()

func show_settings():
	if Global.current_scene_id == Global.Scene.COMBAT:
		return
	if !settings_overlay:
		settings_overlay = Settings.instance()
		self.add_child(settings_overlay)

func show_help():
	if !help_overlay:
		help_overlay = Help.instance()
		self.add_child(help_overlay)

func show_credits():
	if !credits_overlay:
		credits_overlay = Credits.instance()
		credits_overlay.from_title = true
		credits_overlay.connect("closed_scene", Global.current_scene, "_opened_scene_closed")
		self.add_child(credits_overlay)

func _on_settings_pressed():
	show_settings()

func _on_help_pressed():
	show_help()

func _on_credits_pressed():
	show_credits()
