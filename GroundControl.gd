extends Node2D

#Count on button clicks
var Buttons = {
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

func _ready():
	actual_currency = Global.BaseStats.Currency
	initialize_cost()
	$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
	
	
	
func initialize_cost():
	oxygen_cost = get_cost(UpgradeType.OXYGEN, Buttons.Oxygen)
	attack_cost = get_cost(UpgradeType.ATTACK, Buttons.Attack)
	accuracy_cost = get_cost(UpgradeType.ACCURACY, Buttons.Accuracy)
	defense_cost = get_cost(UpgradeType.DEFENSE, Buttons.Defense)
	speed_cost = get_cost(UpgradeType.SPEED, Buttons.Speed)
	evade_cost = get_cost(UpgradeType.EVADE, Buttons.Evade)
	basic_weapon_cost= get_cost(UpgradeType.BASICWEAPONS, Buttons.Basic_Weapon)
	basic_defense_cost= get_cost(UpgradeType.BASICDEFENSE, Buttons.Basic_Defense)
	combat_training_cost= get_cost(UpgradeType.COMBATTRAINING, Buttons.Combat_Training)
	advance_weapon_cost= get_cost(UpgradeType.ADVANCEWEAPONS, Buttons.Advance_Weapon)
	advance_defense_cost= get_cost(UpgradeType.ADVANCEDEFENSE, Buttons.Advance_Defense)
	advance_combat_cost= get_cost(UpgradeType.ADVANCETRAINING, Buttons.Advance_Training)

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
	if Buttons.Oxygen < 5:
		if can_spend(get_cost(UpgradeType.OXYGEN, Buttons.Oxygen)):
			spend_currency(get_cost(UpgradeType.OXYGEN, Buttons.Oxygen))
			Buttons.Oxygen += 1
			get_cost(UpgradeType.OXYGEN, Buttons.Oxygen)
			print('currency '+str(actual_currency))
			$CanvasLayer/OxygenButton/OxygenCount.text = str(Buttons.Oxygen) + "/5"
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
			$CanvasLayer/OxygenButton.text = 'Oxygen: '+ str(get_cost(UpgradeType.OXYGEN, Buttons.Oxygen))
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true

#ATTACK UPGRADE PURCHASE
func attack_upgrade():
	if Buttons.Attack < 4:
		if can_spend(get_cost(UpgradeType.ATTACK, Buttons.Attack)):
			spend_currency(get_cost(UpgradeType.ATTACK, Buttons.Attack))
			Buttons.Attack += 1
			get_cost(UpgradeType.ATTACK, Buttons.Attack)
			print(get_cost(UpgradeType.ATTACK, Buttons.Attack))
			print('currency '+str(actual_currency))
			$CanvasLayer/Tier1/AttackButton/AttackCount.text = str(Buttons.Attack) + "/4"
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true

#ACCURACY UPGRADE PURCHASE
func accuracy_upgrade():
	if Buttons.Accuracy < 4:
		if can_spend(get_cost(UpgradeType.ACCURACY, Buttons.Accuracy)):
			spend_currency(get_cost(UpgradeType.ACCURACY, Buttons.Accuracy))
			Buttons.Accuracy += 1
			get_cost(UpgradeType.ACCURACY, Buttons.Accuracy)
			print(get_cost(UpgradeType.ACCURACY, Buttons.Accuracy))
			$CanvasLayer/Tier1/AccuracyButton/AccuracyCount.text = str(Buttons.Accuracy) + "/4"
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true

#DEFENSE UPGRADE PURCHASE
func defense_upgrade():
	if Buttons.Defense < 4:
		if can_spend(get_cost(UpgradeType.DEFENSE, Buttons.Defense)):
			spend_currency(get_cost(UpgradeType.DEFENSE, Buttons.Defense))
			Buttons.Defense += 1
			get_cost(UpgradeType.DEFENSE, Buttons.Defense)
			print(get_cost(UpgradeType.DEFENSE, Buttons.Defense))
			$CanvasLayer/Tier1/DefenseButton/DefenseCount.text = str(Buttons.Defense) + "/4"
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true
			
func speed_upgrade():
	if Buttons.Speed < 4:
		if can_spend(get_cost(UpgradeType.SPEED, Buttons.Speed)):
			spend_currency(get_cost(UpgradeType.SPEED, Buttons.Speed))
			Buttons.Speed += 1
			get_cost(UpgradeType.SPEED, Buttons.Speed)
			print(get_cost(UpgradeType.SPEED, Buttons.Speed))
			$CanvasLayer/Tier2/SpeedButton/SpeedCount.text = str(Buttons.Speed) + "/4"
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true
			
func evade_upgrade():
	if Buttons.Evade < 4:
		if can_spend(get_cost(UpgradeType.EVADE, Buttons.Evade)):
			spend_currency(get_cost(UpgradeType.EVADE, Buttons.Evade))
			Buttons.Evade += 1
			get_cost(UpgradeType.EVADE, Buttons.Evade)
			print(get_cost(UpgradeType.EVADE, Buttons.Evade))
			$CanvasLayer/Tier2/EvadeButton/EvadeCount.text = str(Buttons.Evade) + "/4"
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true
			
func basic_weapon_upgrade():
	if Buttons.Basic_Weapon < 1:
		if can_spend(get_cost(UpgradeType.BASICWEAPONS, Buttons.Basic_Weapon)):
			spend_currency(get_cost(UpgradeType.BASICWEAPONS, Buttons.Basic_Weapon))
			Buttons.Basic_Weapon += 1
			get_cost(UpgradeType.BASICWEAPONS, Buttons.Basic_Weapon)
			print(get_cost(UpgradeType.BASICWEAPONS, Buttons.Basic_Weapon))
			$CanvasLayer/Tier3/BasicWpnButton/BasicWpnCount.text = str(Buttons.Basic_Weapon) + "/1"
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true
			
func basic_defense_upgrade():
	if Buttons.Basic_Defense < 1:
		if can_spend(get_cost(UpgradeType.BASICDEFENSE, Buttons.Basic_Defense)):
			spend_currency(get_cost(UpgradeType.BASICDEFENSE, Buttons.Basic_Defense))
			Buttons.Basic_Defense += 1
			get_cost(UpgradeType.BASICDEFENSE, Buttons.Basic_Defense)
			print(get_cost(UpgradeType.BASICDEFENSE, Buttons.Basic_Defense))
			$CanvasLayer/Tier3/BasicDefButton/BasicDefenseCount.text = str(Buttons.Basic_Defense) + "/1"
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true
func combat_training_upgrade():
	if Buttons.Combat_Training < 1:
		if can_spend(get_cost(UpgradeType.COMBATTRAINING, Buttons.Combat_Training)):
			spend_currency(get_cost(UpgradeType.COMBATTRAINING, Buttons.Combat_Training))
			Buttons.Combat_Training += 1
			get_cost(UpgradeType.COMBATTRAINING, Buttons.Combat_Training)
			print(get_cost(UpgradeType.COMBATTRAINING, Buttons.Combat_Training))
			$CanvasLayer/Tier3/CombatTrnButton/CombatTrnCount.text = str(Buttons.Combat_Training) + "/1"
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true
			
func advanced_weapon():
	if Buttons.Advance_Weapon < 1:
		if can_spend(get_cost(UpgradeType.ADVANCEWEAPONS, Buttons.Advance_Weapon)):
			spend_currency(get_cost(UpgradeType.ADVANCEWEAPONS, Buttons.Advance_Weapon))
			Buttons.Advance_Weapon += 1
			get_cost(UpgradeType.ADVANCEWEAPONS, Buttons.Advance_Weapon)
			print(get_cost(UpgradeType.ADVANCEWEAPONS, Buttons.Advance_Weapon))
			$CanvasLayer/Tier4/AdvWpnButton/AdvWpnCount.text = str(Buttons.Advance_Weapon) + "/1"
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true
			
func advance_defense():
	if Buttons.Advance_Defense < 1:
		if can_spend(get_cost(UpgradeType.ADVANCEDEFENSE, Buttons.Advance_Defense)):
			spend_currency(get_cost(UpgradeType.ADVANCEDEFENSE, Buttons.Advance_Defense))
			Buttons.Advance_Defense += 1
			get_cost(UpgradeType.ADVANCEDEFENSE, Buttons.Advance_Defense)
			print(get_cost(UpgradeType.ADVANCEDEFENSE, Buttons.Advance_Defense))
			$CanvasLayer/Tier4/AdvDefButton/AdvDefCount.text = str(Buttons.Advance_Defense) + "/1"
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true

func advance_training():
	if Buttons.Advance_Training < 1:
		if can_spend(get_cost(UpgradeType.ADVANCETRAINING, Buttons.Advance_Training)):
			spend_currency(get_cost(UpgradeType.ADVANCETRAINING, Buttons.Advance_Training))
			Buttons.Advance_Training += 1
			get_cost(UpgradeType.ADVANCETRAINING, Buttons.Advance_Training)
			print(get_cost(UpgradeType.ADVANCETRAINING, Buttons.Advance_Training))
			$CanvasLayer/Tier4/AdvTrnButton/AdvTrnCount.text = str(Buttons.Advance_Training) + "/1"
			tier_list()
			$CanvasLayer/Currency.text = "Currency: " + str(actual_currency)
		else:
			#if false shows an alert 
			$CanvasLayer/Alert.visible = true
#TIERS
func tier_list():
	if Buttons.Oxygen >= 1:
		$CanvasLayer/Tier1.visible = true
	if Buttons.Attack >= 1 && Buttons.Accuracy >=1 && Buttons.Defense >= 1:
		$CanvasLayer/Tier2.visible = true
	if Buttons.Speed >= 1 && Buttons.Evade >= 1:
		$CanvasLayer/Tier3.visible = true
	if Buttons.Basic_Weapon >= 1 && Buttons.Basic_Defense >=1 && Buttons.Combat_Training >= 1:
		$CanvasLayer/Tier4.visible = true
		
##### Buttons
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
	
#TODO
#Apply button to go back to apply the changes and go back to the game
#Global.goto_scene(Global.Scene.OVERWORLD)
