extends Node

const Items = preload("res://game/Items.gd")

onready var loot_list = $CanvasLayer/ColorRect/ColorRect2/ItemList

# Called when the node enters the scene tree for the first time.
func _ready():
	var loot_bag = Global.items.generate_combat_loot(Global.floor_level, Global.last_combat_enemies)
	Global.items.apply_loot_bag(loot_bag, Global.player)
	Global.populate_loot_list(loot_list, loot_bag)

func _on_ok_button_pressed():
	Global.goto_scene(Global.Scene.OVERWORLD)
