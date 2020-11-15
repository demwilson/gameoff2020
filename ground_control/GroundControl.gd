extends Node2D

#Count on button clicks
var Button_Click = {
	"Oxygen": 0,
	"Attack": 0,
	"Accuracy": 0,
	"Speed": 0,
	"Defense": 0,
	"Evade": 0,
	"Basic_Weapon": 0,
	"Basic_Defense": 0,
	"Combat_Training": 0,
	"Advance_Weapon": 0,
	"Advance_Defense": 0,
	"Advance_Training": 0
}
#Max Clicks / Upgrades
var Max_Click = {
	"Oxygen": 5,
	"Attack": 4,
	"Accuracy": 4,
	"Defense": 4,
	"Speed": 4,
	"Evade": 4,
	"BasicWeapon": 1,
	"BasicDefense": 1,
	"CombatTraining": 1,
	"AdvanceWeapon": 1,
	"AdvanceDefense": 1,
	"AdvanceTraining": 1,
}

var Upgrades_Needed = {
	"Tier0_to_Tier1": 1,
	"Tier1_to_Tier2": 3,
	"Tier2_to_Tier3": 2,
	"Basic_to_Advance": 1,
}
#Upgrade
enum UpgradeType {
	OXYGEN,
	ATTACK,
	ACCURACY,
	SPEED,
	DEFENSE,
	EVADE,
	BASICWEAPONS,
	BASICDEFENSE,
	COMBATTRAINING,
	ADVANCEWEAPONS,
	ADVANCEDEFENSE,
	ADVANCETRAINING,
}
#cost of upgrades
var oxygen_cost
var attack_cost
var accuracy_cost
var defense_cost 
var speed_cost 
var evade_cost 
var basic_weapon_cost
var basic_defense_cost
var combat_training_cost
var advance_weapon_cost
var advance_defense_cost
var advance_combat_cost
var currency
var actual_currency
var tier1_total
var tier2_total


func _ready():
	actual_currency = Global.currency
	initialize_cost()
	$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
	OS.set_window_size(Vector2(1280, 720))
	
func initialize_cost():
	oxygen_cost = get_cost(UpgradeType.OXYGEN, Button_Click.Oxygen)
	attack_cost = get_cost(UpgradeType.ATTACK, Button_Click.Attack)
	accuracy_cost = get_cost(UpgradeType.ACCURACY, Button_Click.Accuracy)
	defense_cost = get_cost(UpgradeType.DEFENSE, Button_Click.Defense)
	speed_cost = get_cost(UpgradeType.SPEED, Button_Click.Speed)
	evade_cost = get_cost(UpgradeType.EVADE, Button_Click.Evade)
	basic_weapon_cost= get_cost(UpgradeType.BASICWEAPONS, Button_Click.Basic_Weapon)
	basic_defense_cost= get_cost(UpgradeType.BASICDEFENSE, Button_Click.Basic_Defense)
	combat_training_cost= get_cost(UpgradeType.COMBATTRAINING, Button_Click.Combat_Training)
	advance_weapon_cost= get_cost(UpgradeType.ADVANCEWEAPONS, Button_Click.Advance_Weapon)
	advance_defense_cost= get_cost(UpgradeType.ADVANCEDEFENSE, Button_Click.Advance_Defense)
	advance_combat_cost= get_cost(UpgradeType.ADVANCETRAINING, Button_Click.Advance_Training)

func get_cost(type, level):
	match type:
		UpgradeType.OXYGEN:
			return (level + 1) * 5
		UpgradeType.ATTACK:
			return (level + 1) * 12
		UpgradeType.ACCURACY:
			return(level + 1) * 10
		UpgradeType.DEFENSE:
			return(level + 1) * 15
		UpgradeType.SPEED:
			return (level + 1) * 20
		UpgradeType.EVADE:
			return (level + 1) * 24
		UpgradeType.BASICWEAPONS:
			return (level + 1) * 50
		UpgradeType.BASICDEFENSE:
			return (level + 1) * 30
		UpgradeType.COMBATTRAINING:
			return (level + 1) * 60
		UpgradeType.ADVANCEWEAPONS:
			return (level + 1) * 75
		UpgradeType.ADVANCEDEFENSE:
			return (level + 1) * 50
		UpgradeType.ADVANCETRAINING:
			return (level + 1) * 60
			
func spend_currency(cost):
	
	actual_currency = actual_currency - cost

func can_spend(cost):
	# Checks current currency to see if player has enough to spend
	if cost <= actual_currency:
		return true
	else: 
		return false

#OXYGEN UPGRADE PURCHASE 
func oxygen_upgrade():
	# Checks to see if player has enough currency to spend
	# if true spends currency and upgrades 1
	# Subtracts amount spent from currency and increases cost
	if Button_Click.Oxygen < Max_Click.Oxygen:
		if can_spend(get_cost(UpgradeType.OXYGEN, Button_Click.Oxygen)):
			spend_currency(get_cost(UpgradeType.OXYGEN, Button_Click.Oxygen))
			Button_Click.Oxygen += 1
			get_cost(UpgradeType.OXYGEN, Button_Click.Oxygen)
			$CanvasLayer/OxygenButton/OxygenCount.text = str(Button_Click.Oxygen) + "/" + str(Max_Click.Oxygen)
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
			$CanvasLayer/OxygenButton.text = "Oxygen: " + str(get_cost(UpgradeType.OXYGEN, Button_Click.Oxygen))
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true

#ATTACK UPGRADE PURCHASE
func attack_upgrade():
	if Button_Click.Attack < Max_Click.Attack:
		if can_spend(get_cost(UpgradeType.ATTACK, Button_Click.Attack)):
			spend_currency(get_cost(UpgradeType.ATTACK, Button_Click.Attack))
			Button_Click.Attack += 1
			get_cost(UpgradeType.ATTACK, Button_Click.Attack)
			$CanvasLayer/Tier1/AttackButton/AttackCount.text = str(Button_Click.Attack) + "/" + str(Max_Click.Attack)
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
			$CanvasLayer/Tier1/AttackButton.text = "Attack: " + str(get_cost(UpgradeType.ATTACK, Button_Click.Attack))
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true

#ACCURACY UPGRADE PURCHASE
func accuracy_upgrade():
	if Button_Click.Accuracy < Max_Click.Accuracy:
		if can_spend(get_cost(UpgradeType.ACCURACY, Button_Click.Accuracy)):
			spend_currency(get_cost(UpgradeType.ACCURACY, Button_Click.Accuracy))
			Button_Click.Accuracy += 1
			get_cost(UpgradeType.ACCURACY, Button_Click.Accuracy)
			$CanvasLayer/Tier1/AccuracyButton/AccuracyCount.text = str(Button_Click.Accuracy) + "/" + str(Max_Click.Accuracy)
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
			$CanvasLayer/Tier1/AccuracyButton.text = "Accuracy: " + str(get_cost(UpgradeType.ACCURACY, Button_Click.Accuracy))
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true

#DEFENSE UPGRADE PURCHASE
func defense_upgrade():
	if Button_Click.Defense < Max_Click.Defense:
		if can_spend(get_cost(UpgradeType.DEFENSE, Button_Click.Defense)):
			spend_currency(get_cost(UpgradeType.DEFENSE, Button_Click.Defense))
			Button_Click.Defense += 1
			get_cost(UpgradeType.DEFENSE, Button_Click.Defense)
			$CanvasLayer/Tier1/DefenseButton/DefenseCount.text = str(Button_Click.Defense) + "/" + str(Max_Click.Defense)
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
			$CanvasLayer/Tier1/DefenseButton.text = "Defense: " + str(get_cost(UpgradeType.DEFENSE, Button_Click.Defense))
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true
			
func speed_upgrade():
	if Button_Click.Speed < Max_Click.Speed:
		if can_spend(get_cost(UpgradeType.SPEED, Button_Click.Speed)):
			spend_currency(get_cost(UpgradeType.SPEED, Button_Click.Speed))
			Button_Click.Speed += 1
			get_cost(UpgradeType.SPEED, Button_Click.Speed)
			$CanvasLayer/Tier2/SpeedButton/SpeedCount.text = str(Button_Click.Speed) + "/" + str(Max_Click.Speed)
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
			$CanvasLayer/Tier2/SpeedButton.text = "Speed: " + str(get_cost(UpgradeType.SPEED, Button_Click.Speed))
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true
			
func evade_upgrade():
	if Button_Click.Evade < Max_Click.Evade:
		if can_spend(get_cost(UpgradeType.EVADE, Button_Click.Evade)):
			spend_currency(get_cost(UpgradeType.EVADE, Button_Click.Evade))
			Button_Click.Evade += 1
			get_cost(UpgradeType.EVADE, Button_Click.Evade)
			$CanvasLayer/Tier2/EvadeButton/EvadeCount.text = str(Button_Click.Evade) + "/" + str(Max_Click.Evade)
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
			$CanvasLayer/Tier2/EvadeButton.text = "Evade: " + str(get_cost(UpgradeType.EVADE, Button_Click.Evade))
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true
			
func basic_weapon_upgrade():
	if Button_Click.Basic_Weapon < Max_Click.BasicWeapon:
		if can_spend(get_cost(UpgradeType.BASICWEAPONS, Button_Click.Basic_Weapon)):
			spend_currency(get_cost(UpgradeType.BASICWEAPONS, Button_Click.Basic_Weapon))
			Button_Click.Basic_Weapon += 1
			get_cost(UpgradeType.BASICWEAPONS, Button_Click.Basic_Weapon)
			$CanvasLayer/Tier3/BasicWpnButton/BasicWpnCount.text = str(Button_Click.Basic_Weapon) + "/" + str(Max_Click.BasicWeapon)
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true
			
func basic_defense_upgrade():
	if Button_Click.Basic_Defense < Max_Click.BasicDefense:
		if can_spend(get_cost(UpgradeType.BASICDEFENSE, Button_Click.Basic_Defense)):
			spend_currency(get_cost(UpgradeType.BASICDEFENSE, Button_Click.Basic_Defense))
			Button_Click.Basic_Defense += 1
			get_cost(UpgradeType.BASICDEFENSE, Button_Click.Basic_Defense)
			$CanvasLayer/Tier3/BasicDefButton/BasicDefenseCount.text = str(Button_Click.Basic_Defense) + "/" + str(Max_Click.BasicDefense)
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true
func combat_training_upgrade():
	if Button_Click.Combat_Training < Max_Click.CombatTraining:
		if can_spend(get_cost(UpgradeType.COMBATTRAINING, Button_Click.Combat_Training)):
			spend_currency(get_cost(UpgradeType.COMBATTRAINING, Button_Click.Combat_Training))
			Button_Click.Combat_Training += 1
			get_cost(UpgradeType.COMBATTRAINING, Button_Click.Combat_Training)
			$CanvasLayer/Tier3/CombatTrnButton/CombatTrnCount.text = str(Button_Click.Combat_Training) + "/" + str(Max_Click.CombatTraining)
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true
			
func advanced_weapon():
	if Button_Click.Advance_Weapon < Max_Click.AdvanceWeapon:
		if can_spend(get_cost(UpgradeType.ADVANCEWEAPONS, Button_Click.Advance_Weapon)):
			spend_currency(get_cost(UpgradeType.ADVANCEWEAPONS, Button_Click.Advance_Weapon))
			Button_Click.Advance_Weapon += 1
			get_cost(UpgradeType.ADVANCEWEAPONS, Button_Click.Advance_Weapon)
			$CanvasLayer/Tier4/AdvWpnButton/AdvWpnCount.text = str(Button_Click.Advance_Weapon) + "/" + str(Max_Click.AdvanceWeapon)
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true
			
func advance_defense():
	if Button_Click.Advance_Defense < Max_Click.AdvanceDefense:
		if can_spend(get_cost(UpgradeType.ADVANCEDEFENSE, Button_Click.Advance_Defense)):
			spend_currency(get_cost(UpgradeType.ADVANCEDEFENSE, Button_Click.Advance_Defense))
			Button_Click.Advance_Defense += 1
			get_cost(UpgradeType.ADVANCEDEFENSE, Button_Click.Advance_Defense)
			$CanvasLayer/Tier4/AdvDefButton/AdvDefCount.text = str(Button_Click.Advance_Defense) + "/" + str(Max_Click.AdvanceDefense)
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true

func advance_training():
	if Button_Click.Advance_Training < Max_Click.AdvanceTraining:
		if can_spend(get_cost(UpgradeType.ADVANCETRAINING, Button_Click.Advance_Training)):
			spend_currency(get_cost(UpgradeType.ADVANCETRAINING, Button_Click.Advance_Training))
			Button_Click.Advance_Training += 1
			get_cost(UpgradeType.ADVANCETRAINING, Button_Click.Advance_Training)
			$CanvasLayer/Tier4/AdvTrnButton/AdvTrnCount.text = str(Button_Click.Advance_Training) + "/" + str(Max_Click.AdvanceTraining)
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true
#TIERS
func tier_list():
	#Checks to see if requirements are met to go on to next tier
	#Either one of each or 3 of one tier 1 and tier 2
	tier1_total = Button_Click.Attack + Button_Click.Accuracy + Button_Click.Defense
	tier2_total = Button_Click.Speed + Button_Click.Evade
	if Button_Click.Oxygen >= Upgrades_Needed.Tier0_to_Tier1:
		$CanvasLayer/Tier1.visible = true
	if tier1_total >= Upgrades_Needed.Tier1_to_Tier2:
		$CanvasLayer/Tier2.visible = true
	if tier2_total >= Upgrades_Needed.Tier2_to_Tier3:
		$CanvasLayer/Tier3.visible = true
	if Button_Click.Basic_Weapon == Upgrades_Needed.Basic_to_Advance:
		$CanvasLayer/Tier4/AdvWpnButton.visible = true
	if Button_Click.Basic_Defense == Upgrades_Needed.Basic_to_Advance:
		$CanvasLayer/Tier4/AdvDefButton.visible = true
	if Button_Click.Combat_Training == Upgrades_Needed.Basic_to_Advance:
		$CanvasLayer/Tier4/AdvTrnButton.visible = true
		
##### Button_Click
func _on_OxygenButton_pressed():
	oxygen_upgrade()
func _on_AttackButton_pressed():
	attack_upgrade()
func _on_AccuracyButton_pressed():
	accuracy_upgrade()
func _on_DefenseButton_pressed():
	defense_upgrade()
func _on_SpeedButton_pressed():
	speed_upgrade()
func _on_EvadeButton_pressed():
	evade_upgrade()
func _on_BasicWpnButton_pressed():
	basic_weapon_upgrade()
func _on_BasicDefButton_pressed():
	basic_defense_upgrade()
func _on_CombatTrnButton_pressed():
	combat_training_upgrade()
func _on_AdvWpnButton_pressed():
	advanced_weapon()
func _on_AdvDefButton_pressed():
	advance_defense()
func _on_AdvTrnButton_pressed():
	advance_training()
func _on_AlertButton_pressed():
	$CanvasLayer/Alert.visible = false

func _on_StartGameMission_pressed():
	#Update upgrades in global
	Global.Upgrades.Oxygen = Button_Click.Oxygen
	Global.Upgrades.Attack = Button_Click.Attack
	Global.Upgrades.Accuracy = Button_Click.Accuracy
	Global.Upgrades.Defense = Button_Click.Defense
	Global.Upgrades.Speed = Button_Click.Speed
	Global.Upgrades.Evade = Button_Click.Evade
	Global.Upgrades.BasicWeapon = Button_Click.Basic_Weapon
	Global.Upgrades.BasicDefense = Button_Click.Basic_Defense
	Global.Upgrades.CombatTraining = Button_Click.Combat_Training
	Global.Upgrades.AdvanceWeapon = Button_Click.Advance_Weapon
	Global.Upgrades.AdvanceDefesne = Button_Click.Advance_Defense
	Global.Upgrades.AdvanceTraining = Button_Click.Advance_Training
	#update global currency 
	Global.currency = actual_currency
	#Goes back to game
	Global.goto_scene(Global.Scene.OVERWORLD)
