extends Node2D

signal pause_system

const TitleScene = preload("res://Title.tscn")
const PauseOverlay = preload("res://PauseOverlay.tscn")
const Credits = preload("res://Credits.tscn")
const Help = preload("res://Help.tscn")
const Settings = preload("res://settings/Settings.tscn")

enum OverlayType {
	HELP,
	PAUSE,
	SETTINGS,
	CREDITS,
}
const OverlayPackages = [
	Help,
	PauseOverlay,
	Settings,
	Credits
]

# Used for pause screen
var overlays = [null, null, null, null]

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
	if event.is_action("pause"): 
		show_overlay(OverlayType.PAUSE)
	if overlays[OverlayType.PAUSE] == null:
		if event.is_action("settings"): 
			show_overlay(OverlayType.SETTINGS)
		elif event.is_action("help_screen"):
			emit_signal("pause_system")
			show_overlay(OverlayType.HELP)

func show_overlay(overlay_type):
	if overlays[overlay_type] != null:
		if overlay_type == OverlayType.PAUSE:
			get_tree().paused = false
		overlays[overlay_type].queue_free()
		overlays[overlay_type] = null
		return
	
	match overlay_type:
		OverlayType.PAUSE:
			overlays[overlay_type] = create_overlay_instance(overlay_type)
			get_tree().paused = true
		OverlayType.SETTINGS:
			if Global.current_scene_id == Global.Scene.COMBAT:
				return
			overlays[overlay_type] = create_overlay_instance(overlay_type)
		OverlayType.CREDITS:
			overlays[overlay_type] = create_overlay_instance(overlay_type)
			overlays[overlay_type].connect("closed_scene", Global.current_scene, "_opened_overlay_closed")
			overlays[overlay_type].from_title = true
		_:
			overlays[overlay_type] = create_overlay_instance(overlay_type)
	self.add_child(overlays[overlay_type])

func create_overlay_instance(overlay_type):
	var overlay_instance = OverlayPackages[overlay_type].instance()
	overlay_instance.connect("closed_scene", self, "_opened_overlay_closed")
	overlay_instance.overlay_type = overlay_type
	return overlay_instance

func _on_settings_pressed():
	show_overlay(OverlayType.SETTINGS)

func _on_help_pressed():
	show_overlay(OverlayType.HELP)

func _on_credits_pressed():
	show_overlay(OverlayType.CREDITS)

func _opened_overlay_closed(overlay_type):
	overlays[overlay_type] = null
