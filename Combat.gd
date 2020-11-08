extends Node2D

var CombatCreature = preload("res://CombatCreature.gd")

const ACTION_AVAILABLE_TICKS = 5.0
const MAX_ENEMIES = 3
const MAX_ALLIES = 3

var counter = 0
var enemies = []
var allies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	# Populate the combatants
	for i in range(MAX_ENEMIES):
		var creature = CombatCreature.CombatCreature.new("Monster" + str(i), 50, 50)
		enemies.append(creature)
		var ui_name = get_node("CanvasLayer/Enemy" + str(i))
		ui_name.visible = true
		
	for i in range(1):
		var creature = CombatCreature.CombatCreature.new("Astronaut", 50, 50, 3, 2, 1.5, 1, 4)
		allies.append(creature)
		var ui_name = get_node("CanvasLayer/Ally" + str(i))
		ui_name.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	counter += delta
	check_end_combat()

	for i in range(enemies.size()):
		var creature = enemies[i]
		if creature.is_active():
			if creature.get_ticks() >= ACTION_AVAILABLE_TICKS:
				attack(creature, allies[0])
			else:
				creature.add_ticks(delta)
			
		var ui_name = get_node("CanvasLayer/Enemy" + str(i))
		ui_name.text = creature.get_name()
		var ui_health = get_node("CanvasLayer/Enemy" + str(i) + "/Health")
		ui_health.value = creature.get_health_percentage()
		var ui_ticks = get_node("CanvasLayer/Enemy" + str(i) + "/Ticks")
		ui_ticks.value = creature.get_ticks()

	for i in range(allies.size()):
		var creature = allies[i]
		if creature.is_active():
			if creature.get_ticks() >= ACTION_AVAILABLE_TICKS:
				var target = null
				for j in range(enemies.size()):
					var potential_target = enemies[j]
					if potential_target.is_active():
						target = potential_target
						break

				attack(creature, target)
			else:
				creature.add_ticks(delta)
		var ui_name = get_node("CanvasLayer/Ally" + str(i))
		ui_name.text = creature.get_name()
		var ui_health = get_node("CanvasLayer/Ally" + str(i) + "/Health")
		ui_health.value = creature.get_health_percentage()
		var ui_ticks = get_node("CanvasLayer/Ally" + str(i) + "/Ticks")
		ui_ticks.value = creature.get_ticks()

	# Update canvas
	$CanvasLayer/Ticks.text = "Ticks: " + str(counter)

func _input(event):
	if !event.is_pressed():
		return
	if event.is_action("map_change_again"):
		Global.goto_scene(Global.Scene.OVERWORLD)

func check_end_combat():
	var dead_enemies = 0
	var dead_allies = 0
	for creature in allies:
		if !creature.is_active():
			dead_allies += 1
	if dead_allies == allies.size():
		return Global.goto_scene(Global.Scene.GAME_OVER)
	for creature in enemies:
		if !creature.is_active():
			dead_enemies += 1
	if dead_enemies == enemies.size():
		self.set_process(false)
		$CanvasLayer/Win.visible = true

func attack(attacker, target):
	var log_arr = []
	log_arr.append("ATTACKER: " + attacker.get_name())
	log_arr.append("TARGET: " + target.get_name())
	# get move
	var move = attacker.get_move()
	log_arr.append("MOVE: " + move.name)
	# check for a hit
	var accuracy = move.accuracy.call_func(attacker.get_stat("accuracy"), attacker.get_bonus("accuracy"))
	var target_hit = false
	var target_dodged = false
	var damaged_mitigated = false
	if check_to_hit(accuracy):
		target_hit = true
		log_arr.append("ATTACK HIT!")
		# check for a dodge
		if check_to_dodge(target.get_stat("dodge"), target.get_bonus("dodge"), move.level):
			target_dodged = true
			log_arr.append("ATTACK DODGED!")

	if target_hit && !target_dodged:
		# get the damage range
		var minimum = move.damage.call_func(attacker.get_stat("attack"), attacker.get_bonus("attack"), move.low)
		var maximum = move.damage.call_func(attacker.get_stat("attack"), attacker.get_bonus("attack"), move.high)
		# get raw damage
		var raw_damage = calculate_damage(minimum, maximum)
		var raw_defense = calculate_defense(target.get_stat("defense"), target.get_bonus("defense"))
		# mitigate damage
		var damage = raw_damage - raw_defense
		if damage <= 0:
			damaged_mitigated = true
			log_arr.append("DAMAGE MITIGATED!")
		else:
			# apply damage
			target.add_health(-damage)
			log_arr.append("DAMAGE: " + str(damage))
	# reset ticks
	attacker.set_ticks(0)

	# Logging stuff
	var log_string = PoolStringArray(log_arr).join(" | ")
	Global.log(Settings.LogLevel.INFO, log_string)

func check_to_hit(accuracy):
	var processed = accuracy
	if accuracy > 99.9:
		processed = 99.9
	elif accuracy < 0.1:
		processed = 0.1
	var rand = randf() * 100
	var hit_target = rand <= processed
	Global.log(Settings.LogLevel.TRACE, "[check_to_hit] ACCURACY: " + str(accuracy) + " | PROCESSED: " + str(processed) + " | RAND: " + str(rand))
	return hit_target

func check_to_dodge(dodge, bonus_dodge, move_level):
	var processed = pow(dodge, 2) + bonus_dodge
	if processed > 60:
		processed = 60
	var rand = randf() * 100
	var dodged = rand <= processed
	Global.log(Settings.LogLevel.TRACE, "[check_to_dodge] DODGE: " + str(dodge) + " | BONUS: " + str(bonus_dodge) + " | PROCESSED: " + str(processed) + " | RAND: " + str(rand))
	return dodged

func calculate_damage(min_damage, max_damage):
	var rand = 1 + randi() % int(max_damage - min_damage) + int(min_damage)
	Global.log(Settings.LogLevel.TRACE, "[calculate_damage] MIN: " + str(min_damage) + " | MAX: " + str(max_damage) + " | RAND: " + str(rand))
	return rand

func calculate_defense(defense, bonus_defense):
	var processed = pow(2, defense) + bonus_defense
	Global.log(Settings.LogLevel.TRACE, "[calculate_defense] RAW: " + str(defense) + " | BONUS: " + str(bonus_defense) + " | processed: " + str(processed))
	return processed

func _on_Button_pressed():
	Global.goto_scene(Global.Scene.OVERWORLD)
