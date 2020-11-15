extends Node

const Items = preload("res://game/Items.gd")

onready var loot_list = $CanvasLayer/ColorRect/ColorRect2/ItemList

# Called when the node enters the scene tree for the first time.
func _ready():
	var loot = Global.items.generate_loot(Global.current_level, Global.player)
	var entries = []
	match loot.type:
		Items.LootType.ITEM:
			for item in loot.items:
				entries.append(item.name)
		Items.LootType.CURRENCY:
			entries.append(str(loot.items) + " " + Global.CURRENCY_TEXT)
		Items.LootType.OXYGEN:
			entries.append(str(loot.items) + " " + Global.OXYGEN_TEXT)
	for entry in entries:
		loot_list.add_item(entry, null, false)

func _on_ok_button_pressed():
	Global.goto_scene(Global.Scene.OVERWORLD)
