extends Node

const Items = preload("res://game/Items.gd")

onready var loot_list = $CanvasLayer/ColorRect/ColorRect2/ItemList

# Called when the node enters the scene tree for the first time.
func _ready():
	var loot = Global.items.generate_loot(Global.floor_level, Global.player)
	Global.populate_loot_list(loot_list, loot)

func _on_ok_button_pressed():
	Global.goto_scene(Global.Scene.OVERWORLD)
