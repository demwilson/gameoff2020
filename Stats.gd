extends Node2D

const Creature = preload("res://game/Creature.gd")
const GlobalPlayer = preload("res://game/GlobalPlayer.gd")
const Item = preload("res://game/Item.gd")
const Items = preload("res://game/Items.gd")
const Move = preload("res://game/Move.gd")
const Moves = preload("res://game/Moves.gd")
const Stats = preload("res://game/Stats.gd")

#Character main stats
var current_hp = Global.player.get_health()
var max_hp = Global.player.get_max_health()
var player_name = Global.player.get_name()
var current_oxygen = Global.player.get_oxygen()
var max_oxygen = Global.player.get_max_oxygen()

# Secondary stats
var attack = Global.player.get_stat(Stats.ATTACK)
var accuracy = Global.player.get_stat(Stats.ACCURACY)
var speed = Global.player.get_stat(Stats.SPEED)
var defense = Global.player.get_stat(Stats.DEFENSE)
var evade = Global.player.get_stat(Stats.EVADE)

#Moves
func obtain_move_list():
	var total_moves = []
	var commands = []
	
	total_moves = Global.player.get_moves()
	for move in total_moves:
		var command = Global.moves.get_move_by_id(move)
		commands.append(command)
	return commands

func populate_move_list():
	var moves = obtain_move_list()
	for move in moves:
		var move_name = move.name
		$CanvasLayer/NinePatchRect/Character/Commands/MoveList.add_item(move_name, null, true)
		
#Equipment 
func obtain_equipment_list():
	var equip_id = []
	var equip_list = []
	
	equip_id = Global.player.get_items()
	for id in equip_id:
		var item = Global.items.get_item_by_id(id)
		equip_list.append(item)
	return equip_list
	
func populate_equipment_list():
	var equips = obtain_equipment_list()
	for item in equips:
		var item_name = item.name
		$CanvasLayer/NinePatchRect/Equipment/EquipList.add_item(item_name, null, true)
		
func set_data():
	
	$CanvasLayer/NinePatchRect/Character/Name.text = "Name: " + str(player_name)
	$CanvasLayer/NinePatchRect/Character/HP.text = "HP: " + str(current_hp) + "/" + str(max_hp)
	$CanvasLayer/NinePatchRect/Character/Oxygen.text = "Oxygen: " + str(current_oxygen) + "/" + str(max_oxygen)
	
	$CanvasLayer/NinePatchRect/Character/Abilities/Attack.text = "Attack: " + str(attack)
	$CanvasLayer/NinePatchRect/Character/Abilities/Accuracy.text = "Accuracy: " + str(accuracy)
	$CanvasLayer/NinePatchRect/Character/Abilities/Speed.text = "Speed: " + str(speed)
	$CanvasLayer/NinePatchRect/Character/Abilities/Defense.text = "Defense: " + str(defense)
	$CanvasLayer/NinePatchRect/Character/Abilities/Evade.text = "Evade: " + str(evade)
	
	populate_move_list()
	populate_equipment_list()
	
func _ready():
	set_data()
		
func _input(event):
	if !event.is_pressed():
		return
	elif event.is_action("stats_profile"):
		Global.goto_scene(Global.Scene.OVERWORLD)
	

