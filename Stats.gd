extends Node2D

#Character main stats
var hp = 100
var player_name = "Roger Mcfly"
var oxygen = 80

# Secondary stats
var attack = 25
var accuracy = 75
var speed = 20
var defense = 45
var evade = 30

#Moves
var move_1 = "Active"
var move_2 = "Deactived"
var move_3 = "Active once per encounter"

#Tier upgrades
var tier_0 = "Oxygen Capacity"
var tier_1 = "Offensive Amplifications"
var tier_2 = "Detection Systems"
var tier_3 = "Combat Training"
var tier_4 = "Advanced Weapons"

#Equipment 
var equipment_1 = "Helmet of SAAN provides +10 to defense"
var equipment_2 = "Blaster of SAAN provides +5 to attack and accuracy"

func set_dummy_data():
	
	$CanvasLayer/NinePatchRect/Character/Name.text = "Name: " + str(player_name)
	$CanvasLayer/NinePatchRect/Character/HP.text = "HP: " + str(hp)
	$CanvasLayer/NinePatchRect/Character/Oxygen.text = "Oxygen: " + str(oxygen) + "%"
	
	$CanvasLayer/NinePatchRect/Character/Abilities/Attack.text = "Attack: " + str(attack)
	$CanvasLayer/NinePatchRect/Character/Abilities/Accuracy.text = "Accuracy: " + str(accuracy) + "%"
	$CanvasLayer/NinePatchRect/Character/Abilities/Speed.text = "Speed: " + str(speed)
	$CanvasLayer/NinePatchRect/Character/Abilities/Defense.text = "Defense: " + str(defense)
	$CanvasLayer/NinePatchRect/Character/Abilities/Evade.text = "Evade: " + str(evade) + "%"
	
	$CanvasLayer/NinePatchRect/Character/Commands/Blaster.text = "Blaster: " + str(move_1)
	$CanvasLayer/NinePatchRect/Character/Commands/Flamethrower.text = "Flamethrower: " + str(move_2)
	$CanvasLayer/NinePatchRect/Character/Commands/Activeshield.text = "Active shield: " + str(move_3)
	
	$CanvasLayer/NinePatchRect/Upgrades/Tier0.text = "Tier 0: " + str(tier_0)
	$CanvasLayer/NinePatchRect/Upgrades/Tier1.text = "Tier 1: " + str(tier_1)
	$CanvasLayer/NinePatchRect/Upgrades/Tier2.text = "Tier 2: " + str(tier_2)
	$CanvasLayer/NinePatchRect/Upgrades/Tier3.text = "Tier 3: " + str(tier_3)
	$CanvasLayer/NinePatchRect/Upgrades/Tier4.text = "Tier 4: " + str(tier_4)
	
	$CanvasLayer/NinePatchRect/Equipment/Equip1.text = "Equipment 1: " + str(equipment_1)
	$CanvasLayer/NinePatchRect/Equipment/Equip2.text = "Equipment 2: " + str(equipment_2)
	
func _ready():
		 set_dummy_data()
		
func _input(event):
	if !event.is_pressed():
		return
	elif event.is_action("stats_profile"):
		Global.goto_scene(Global.Scene.OVERWORLD)
	

