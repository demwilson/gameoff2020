extends Node2D

const LootItem = preload("res://game/LootItem.gd")
const Creature = preload("res://game/Creature.gd")
const GlobalPlayer = preload("res://game/GlobalPlayer.gd")
const Item = preload("res://game/Item.gd")
const Items = preload("res://game/Items.gd")
const Move = preload("res://game/Move.gd")
const Moves = preload("res://game/Moves.gd")
const Stats = preload("res://game/Stats.gd")

onready var audio = $AudioStreamPlayer
onready var loot_list = $CanvasLayer/NinePatchRect/Equipment/EquipList
onready var move_list = $CanvasLayer/NinePatchRect/MoveList

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
# Stat Bonuses
var attack_bonus = Global.player.get_bonus(Stats.ATTACK)
var accuracy_bonus = Global.player.get_bonus(Stats.ACCURACY)
# No speed bonus
var defense_bonus = Global.player.get_bonus(Stats.DEFENSE)
var evade_bonus = Global.player.get_bonus(Stats.EVADE)

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
	var move_text = ""
	var move_min_damage = 0
	var move_max_damage = 0
	var move_accuracy = 0
	
	for move in moves:
		match move.type:
			Move.MoveType.DAMAGE:
				move_min_damage = floor(Move.calculate_damage(move.damage, attack, attack_bonus, move.low))
				move_max_damage = floor(Move.calculate_damage(move.damage, attack, attack_bonus, move.high))
				move_accuracy = floor(Move.calculate_accuracy(move.accuracy, accuracy, accuracy_bonus))
				move_text = move.name + " - Dmg: " + str(move_min_damage) + " - " + str(move_max_damage) + ", Acc: " + str(move_accuracy) + "%"
			Move.MoveType.HEAL:
				move_min_damage = floor(Move.calculate_damage(move.damage, defense, defense_bonus, move.low))
				move_max_damage = floor(Move.calculate_damage(move.damage, defense, defense_bonus, move.high))
				move_text = move.name + " - Heal: " + str(move_min_damage) + " - " + str(move_max_damage)
		move_list.add_item(move.name, null, false)
		move_list.set_item_tooltip(move_list.get_item_count()-1, move_text)
#Equipment 
func obtain_equipment_list():
	var equip_id = []
	var equip_list = []
	
	equip_id = Global.player.get_items()
	for id in equip_id:
		var item = Global.items.get_item_by_id(id)
		var loot_item = LootItem.new(Items.LootType.GEAR, item)
		equip_list.append(loot_item)
	return equip_list
	
func populate_equipment_list():
	var equips = obtain_equipment_list()
	Global.populate_loot_list(loot_list, equips)
		
func set_data():
	
	$CanvasLayer/NinePatchRect/Name.text = "Name: " + str(player_name)
	$CanvasLayer/NinePatchRect/HP.text = "HP: " + str(current_hp) + "/" + str(max_hp)
	$CanvasLayer/NinePatchRect/Oxygen.text = "Oxygen: " + str(current_oxygen) + "/" + str(max_oxygen)
	
	$CanvasLayer/NinePatchRect/Attack/AttackScore.text = str(attack) + " + " + str(attack_bonus)
	$CanvasLayer/NinePatchRect/Accuracy/AccuracyScore.text = str(accuracy) + " + " + str(accuracy_bonus)
	$CanvasLayer/NinePatchRect/Speed/SpeedScore.text = str(speed)
	$CanvasLayer/NinePatchRect/Defense/DefenseScore.text = str(defense) + " + " + str(defense_bonus)
	$CanvasLayer/NinePatchRect/Evade/EvadeScore.text = str(evade) + " + " + str(evade_bonus)
	
	populate_move_list()
	populate_equipment_list()
	
func _ready():
	set_data()
		
func _input(event):
	if !event.is_pressed():
		return
	elif event.is_action("stats_profile"):
		Global.goto_scene(Global.Scene.OVERWORLD)
		
func set_audio(value):
	if value:
		audio.play()
	else:
		audio.stop()

