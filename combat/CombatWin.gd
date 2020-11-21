extends Node

const Items = preload("res://game/Items.gd")
const ROLL_UP_STEP = 1
const DEFAULT_ROLL_UP_PERCENTAGE = 0

onready var loot_list = $CanvasLayer/ColorRect/ColorRect2/ItemList

# Called when the node enters the scene tree for the first time.
func _ready():
	var loot_bag = Global.items.generate_combat_loot(Global.floor_level, Global.last_combat_enemies)
	possible_roll_up(loot_bag)
	Global.items.apply_loot_bag(loot_bag, Global.player)
	Global.populate_loot_list(loot_list, loot_bag)

func possible_roll_up(loot_bag):
	for loot in loot_bag:
		if loot.type == Items.LootType.GEAR:
			var rand = Items.get_random_count(Items.LOOT_CHANCE_MAX_RAND)
			if rand <= Global.roll_up_percentage:
				var previous_item_name = loot.item.name
				var new_item = Global.items.roll_up_item(loot.item)
				loot.item = new_item
				Global.log(Settings.LogLevel.DEBUG, "[possible_roll_up] Roll Up Item: " + str(previous_item_name) + " | New Item: " + str(new_item.name))
				Global.roll_up_percentage = DEFAULT_ROLL_UP_PERCENTAGE
			else:
				Global.roll_up_percentage += ROLL_UP_STEP

func _on_ok_button_pressed():
	Global.goto_scene(Global.Scene.OVERWORLD)
