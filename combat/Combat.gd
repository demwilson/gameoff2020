extends Node2D

var EnemyScene = preload("res://combat/enemies/CombatEnemy.tscn")
var CombatCreature = preload("res://combat/CombatCreature.gd")
var CombatEvent = preload("res://combat/CombatEvent.gd")
var FloatingText = preload("res://combat/FloatingText.tscn")

const COMBAT_POSITION_SPACING = 64
const ENEMY_POSITION_X = 80
const ENEMY_POSITION_Y = 88

const ALLY_POSITION_X = 528
const ALLY_POSITION_Y = 88

const MAX_ANIMATION_TIMER = 2.0
const ACTION_AVAILABLE_TICKS = 5.0
const MAX_ENEMIES = 3
const MAX_ALLIES = 3

const EVADE_PROCESSED_MAX = 60
const ACCURACY_PROCESSED_MIN = 0.1
const ACCURACY_PROCESSED_MAX = 99.9
const PERCENT_MULTIPLIER = 100

var counter = 0
var enemies = []
var allies = []

var action_queue = []
var animation_wait = 0
var animation_ticks = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	# Populate the combatants
#	for i in range(1):
	for i in range(MAX_ENEMIES):
		var creature_scene = EnemyScene.instance()
		creature_scene.set("position", Vector2(ENEMY_POSITION_X, ENEMY_POSITION_Y + i * COMBAT_POSITION_SPACING))
		creature_scene.show_health = true
		creature_scene.show_ticks = true
		var creature = CombatCreature.CombatCreature.new("Monster" + str(i), creature_scene, 50, 50, 1, 2, (i + 1), 1, 1)
		enemies.append(creature)
		$CanvasLayer.add_child(creature.scene)

	for i in range(1):
		var creature_scene = EnemyScene.instance()
		creature_scene.set("position", Vector2(ALLY_POSITION_X, (i + 1) * ALLY_POSITION_Y))
		creature_scene.show_name = true
		creature_scene.show_health = true
		creature_scene.show_ticks = true
		creature_scene.texture_path = true
		var creature = CombatCreature.CombatCreature.new(Global.PLAYER_NAME, creature_scene, 50, 50, 3, 2, 1.5, 1, 4)
		allies.append(creature)
		$CanvasLayer.add_child(creature.scene)

	OS.set_window_size(Vector2(1280, 720))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# game ticks
	counter += delta
	$CanvasLayer/Background/Ticks.text = "Ticks: " + str(counter)

	# animation ticks
	if animation_wait > 0:
		if animation_ticks < animation_wait:
			animation_ticks += delta
		else:
			animation_wait = 0
			animation_ticks = 0
	$CanvasLayer/AnimationTicks.text = "Animation Ticks:\n" + str(animation_ticks) + "\n\nQueue Size:\n" + str(action_queue.size())

	# actual processing
	check_end_combat()
	check_action_queue()
	for i in range(enemies.size()):
		var creature = enemies[i]
		if creature.is_active():
			if creature.get_ticks() >= ACTION_AVAILABLE_TICKS && !creature.is_queued:
				var target = allies[0]
				action_queue.append(CombatEvent.CombatEvent.new(Global.AttackType.DAMAGE, creature, target))
				creature.is_queued = true
			else:
				creature.add_ticks(delta)
		creature.update_health_percentage()
		creature.update_ticks()

	for i in range(allies.size()):
		var creature = allies[i]
		if creature.is_active():
			if creature.get_ticks() >= ACTION_AVAILABLE_TICKS && !creature.is_queued:
				var target = null
				while target == null:
					var target_position = randi() % enemies.size()
					var potential_target = enemies[target_position]
					if potential_target.is_active():
						target = potential_target
				action_queue.append(CombatEvent.CombatEvent.new(Global.AttackType.DAMAGE, creature, target))
				creature.is_queued = true
			else:
				creature.add_ticks(delta)
		creature.update_health_percentage()
		creature.update_ticks()


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
		# TODO: Show win screen
		return Global.goto_scene(Global.Scene.OVERWORLD)

func check_action_queue():
	if action_queue.size() == 0 || animation_wait > 0:
		return
	animation_wait = MAX_ANIMATION_TIMER
	var combat_action = action_queue.pop_front()
	match combat_action.action_type:
		Global.AttackType.DAMAGE:
			attack(combat_action.creature, combat_action.target)

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
	var target_evaded = false
	var damaged_mitigated = false
	if check_to_hit(accuracy):
		target_hit = true
		log_arr.append("ATTACK HIT!")
		# check for a evade
		if check_to_evade(target.get_stat("evade"), target.get_bonus("evade"), move.level):
			target_evaded = true
			log_arr.append("ATTACK EVADED!")
			# TODO: Avoided text

	if target_hit && !target_evaded:
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
			# TODO: Mitigated text
		else:
			# apply damage
			target.add_health(-damage)
			# Floating damage
			var damage_text = FloatingText.instance()
			damage_text.amount = damage
			damage_text.type = Global.AttackType.DAMAGE
			target.scene.add_child(damage_text)
			log_arr.append("DAMAGE: " + str(damage))

	# TODO: target has died
	if !target.is_active():
		target.scene.stop_animation()

	# reset ticks
	attacker.set_ticks(0)
	attacker.is_queued = false

	# Logging stuff
	var log_string = PoolStringArray(log_arr).join(" | ")
	Global.log(Settings.LogLevel.INFO, log_string)

func check_to_hit(accuracy):
	var processed = accuracy
	if accuracy > ACCURACY_PROCESSED_MAX:
		processed = ACCURACY_PROCESSED_MAX
	elif accuracy < ACCURACY_PROCESSED_MIN:
		processed = ACCURACY_PROCESSED_MIN
	var rand = randf() * PERCENT_MULTIPLIER
	var hit_target = rand <= processed
	Global.log(Settings.LogLevel.TRACE, "[check_to_hit] ACCURACY: " + str(accuracy) + " | PROCESSED: " + str(processed) + " | RAND: " + str(rand))
	return hit_target

func check_to_evade(evade, bonus_evade, move_level):
	var processed = pow(evade, 2) + bonus_evade - pow(move_level, 2)
	if processed > EVADE_PROCESSED_MAX:
		processed = EVADE_PROCESSED_MAX
	var rand = randf() * PERCENT_MULTIPLIER
	var evaded = rand <= processed
	Global.log(Settings.LogLevel.TRACE, "[check_to_evade] EVADE: " + str(evade) + " | BONUS: " + str(bonus_evade) + " | PROCESSED: " + str(processed) + " | RAND: " + str(rand))
	return evaded

func calculate_damage(min_damage, max_damage):
	var rand = 1 + randi() % int(max_damage - min_damage) + int(min_damage)
	Global.log(Settings.LogLevel.TRACE, "[calculate_damage] MIN: " + str(min_damage) + " | MAX: " + str(max_damage) + " | RAND: " + str(rand))
	return rand

func calculate_defense(defense, bonus_defense):
	var processed = pow(2, defense) + bonus_defense
	Global.log(Settings.LogLevel.TRACE, "[calculate_defense] RAW: " + str(defense) + " | BONUS: " + str(bonus_defense) + " | processed: " + str(processed))
	return processed
