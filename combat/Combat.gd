extends Node2D

enum CombatAnimationState {
	INITIAL_STATE = 0,
	INACTIVE = 0,
	MOVING_FORWARD = 1,
	ANIMATING = 2,
	MOVING_BACKWARD = 3,
	COMPLETE = 4,
}

const PauseOverlay = preload("res://PauseOverlay.tscn")
const Creature = preload("res://game/Creature.gd")
const Move = preload("res://game/Move.gd")
var EnemyScene = preload("res://combat/enemies/CombatEnemy.tscn")
var CombatCreature = preload("res://combat/CombatCreature.gd")
var CombatEvent = preload("res://combat/CombatEvent.gd")
var FloatingText = preload("res://combat/FloatingText.tscn")

onready var CombatantBox = $CanvasLayer/CombatantBox
onready var CombatInstructions = $CanvasLayer/CombatMenu/Instructions
onready var MoveSelectionArrow = $CanvasLayer/CombatMenu/Menu/VBoxContainer/ColorRect/MoveSelectionArrow
onready var TargetSelectionArrow = $CanvasLayer/TargetSelectionArrow
onready var MoveNameLabels = [
	$CanvasLayer/CombatMenu/Menu/VBoxContainer/ColorRect/MoveName0,
	$CanvasLayer/CombatMenu/Menu/VBoxContainer/ColorRect/MoveName1,
	$CanvasLayer/CombatMenu/Menu/VBoxContainer/ColorRect/MoveName2,
	$CanvasLayer/CombatMenu/Menu/VBoxContainer/ColorRect/MoveName3,
	$CanvasLayer/CombatMenu/Menu/VBoxContainer/ColorRect/MoveName4,
	$CanvasLayer/CombatMenu/Menu/VBoxContainer/ColorRect/MoveName5,
]

const COMBAT_ARROW_RIGHT = preload("res://assets/combat_arrow_right.png")
const COMBAT_ARROW_DOWN = preload("res://assets/combat_arrow_down.png")

const MAX_PERCENTAGE = 100.0
const MIN_DAMAGE = 0
const MIN_ENEMIES = 1
const ENEMY_COUNT_STEP = 1
const ENEMY_COUNT_TIER_ONE = 5
const ENEMY_COUNT_TIER_TWO = 10
const MAX_ENEMIES = 3

const MAX_ANIMATION_TIMER = 1.2
const ACTION_AVAILABLE_TICKS = 6.0
const MAX_ALLIES = 3
const PLAYER_POSITION = 0

const EVADE_PROCESSED_MAX = 60
const ACCURACY_PROCESSED_MIN = 0.1
const ACCURACY_PROCESSED_MAX = 99.9
const PERCENT_MULTIPLIER = 100

const MENU_ARROW_POSITION = 0
const TARGET_ARROW_POSITION = 1
const FIRST_POSITION = 0
const STEP_AMOUNT = 1
const MOVE_COLUMN_COUNT = 3
const COMBAT_ARROW_DOWN_OFFSET = Vector2(-16, -64)

const ATTACK_ANIMATION_STEP = 1
const BLOCKED_TEXT = "BLOCKED"
const EVADED_TEXT = "EVADED"
const MISSED_TEXT = "MISSED"

var counter = 0
var enemies = []
var enemy_positions = [
	Vector2(48, 136),
	Vector2(48, 216),
	Vector2(136, 176),
]
var allies = []
var ally_positions = [
	Vector2(592, 136),
	Vector2(592, 216),
	Vector2(512, 176),
]
var menu_positions = [
	[Vector2(8, 0), Vector2(48, 0)],
	[Vector2(8, 32), Vector2(48, 32)],
	[Vector2(8, 64), Vector2(48, 64)],
	[Vector2(128, 0), Vector2(168, 0)],
	[Vector2(128, 32), Vector2(168, 32)],
	[Vector2(128, 64), Vector2(168, 64)],
]

var action_queue = []
var animation_lock = false
var animation_ticks = 0
var attack_animation_state = CombatAnimationState.INACTIVE
var _current_combat_action = null

# Menuing
enum MenuPhase {
	NONE,
	MOVE_SELECT,
	TARGET_SELECT,
}
var pause_overlay = null
var _phase = MenuPhase.NONE
var _menu_move = null
var _menu_target = null
var _menu_creature = null
var _creature_moves = null
var _hover = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Populate the combatants
	var num_enemies = get_combat_enemies(Global.player.get_combat_count())
	for i in range(num_enemies):
		var position = enemy_positions[i]
		var enemy = Global.enemies.get_random_enemy_by_tier_level(Global.floor_level)
		# Setup Scene
		var creature_scene = EnemyScene.instance()
		creature_scene.set("position", position)
		creature_scene.creature_name = enemy.get_name()
		creature_scene.show_name = true
		creature_scene.creature_size = enemy.size
		creature_scene.texture_path = Creature.file_paths[enemy.get_base_path()] + str(enemy.get_tier())
		creature_scene.idle_path = Creature.file_paths[enemy.get_base_path()] + str(enemy.get_tier()) + Global.ANIMATION_FILE_EXTENSION
		creature_scene.connect("animation_step_complete", self, "next_animation_step")
		var creature = CombatCreature.new(
			CombatCreature.CombatantType.ENEMY,
			enemy.get_name(),
			creature_scene,
			enemy.size,
			enemy.get_max_health(),
			enemy.get_health(),
			enemy.get_moves(),
			enemy.get_stats(),
			enemy.get_bonuses(),
			enemy.get_base_path(),
			enemy.get_behavior()
		)
		enemies.append(creature)
		CombatantBox.add_child(creature.scene)

	var ally_list = Global.player.get_allies()
	ally_list.push_front(Global.player)
	var num_allies = min(ally_list.size(), MAX_ALLIES)
	for i in range(num_allies):
		var position = ally_positions[i]
		var creature = null
		var ally = ally_list[i]
		if typeof(ally) != TYPE_INT:
			ally = Global.player
		else:
			ally = Global.enemies.get_enemy_by_id(ally)
		# Setup Scene
		var creature_scene = EnemyScene.instance()
		creature_scene.set("position", position)
		creature_scene.creature_name = ally.get_name()
		creature_scene.show_name = true
		creature_scene.creature_size = ally.size
		creature_scene.texture_path = Creature.file_paths[ally.get_base_path()] + str(ally.get_tier())
		creature_scene.idle_path = Creature.file_paths[ally.get_base_path()] + str(ally.get_tier()) + Global.ANIMATION_FILE_EXTENSION
		creature_scene.connect("animation_step_complete", self, "next_animation_step")
		creature = CombatCreature.new(
			CombatCreature.CombatantType.ALLY,
			ally.get_name(),
			creature_scene,
			ally.size,
			ally.get_max_health(),
			ally.get_health(),
			ally.get_moves(),
			ally.get_stats(),
			ally.get_bonuses(),
			ally.get_base_path(),
			ally.get_behavior()
		)
		allies.append(creature)
		CombatantBox.add_child(creature.scene)
	
	OS.set_window_size(Vector2(1280, 720))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# game ticks
	counter += delta
	$CanvasLayer/Background/Ticks.text = "Ticks: " + str(counter)

	# actual processing
	if animation_lock:
		animation_ticks += delta
	else:
		animation_ticks = 0
	$CanvasLayer/AnimationTicks.text = "Animation Ticks:\n" + str(animation_ticks) + "\n\nQueue Size:\n" + str(action_queue.size())

	# actual processing
	for i in range(allies.size()):
		var creature = allies[i]
		if creature.is_alive():
			if creature.get_ticks() >= ACTION_AVAILABLE_TICKS && !creature.is_queued:
				if creature.get_behavior() == Creature.Behavior.PLAYER:
					show_move_options(creature)
				else:
					var move_id = creature.get_move()
					var move = Global.moves.get_move_by_id(move_id)
					var target = creature.choose_target(move, enemies)
					action_queue.append(CombatEvent.new(move, creature, target))
				creature.is_queued = true
			else:
				creature.add_ticks(delta)
		creature.update_health_percentage()
		creature.update_ticks()

		# UI Updates
		var ui_node = get_node("CanvasLayer/CombatMenu/Allies/VBoxContainer/Ally" + str(i))
		ui_node.visible = true
		var ui_name = get_node("CanvasLayer/CombatMenu/Allies/VBoxContainer/Ally" + str(i) + "/Name")
		ui_name.text = creature.get_name()
		var ui_health = get_node("CanvasLayer/CombatMenu/Allies/VBoxContainer/Ally" + str(i) + "/Health")
		ui_health.text = str(creature.get_health()) + " / " + str(creature.get_max_health())
		var ui_ticks = get_node("CanvasLayer/CombatMenu/Allies/VBoxContainer/Ally" + str(i) + "/Ticks")
		ui_ticks.value = creature.get_ticks()
	for i in range(enemies.size()):
		var creature = enemies[i]
		if creature.is_alive():
			if creature.get_ticks() >= ACTION_AVAILABLE_TICKS && !creature.is_queued:
				var move_id = creature.get_move()
				var move = Global.moves.get_move_by_id(move_id)
				var target = creature.choose_target(move, allies)
				action_queue.append(CombatEvent.new(move, creature, target))
				creature.is_queued = true
			else:
				creature.add_ticks(delta)
		creature.update_health_percentage()
		creature.update_ticks()

		# UI Updates
		var ui_text = get_node("CanvasLayer/CombatMenu/Enemies/VBoxContainer/Enemy" + str(i))
		ui_text.text = creature.get_name()
		ui_text.visible = true
	check_end_combat()
	check_action_queue()

func _input(event):
	if !event.is_pressed():
		return
	if event.is_action("map_change_again"):
		Global.goto_scene(Global.Scene.OVERWORLD)
	elif event.is_action("pause"):
		if !pause_overlay:
			pause_overlay = PauseOverlay.instance()
			self.add_child(pause_overlay)
			get_tree().paused = true
	elif _phase != MenuPhase.NONE:
		if event.is_action("up"):
			update_hover(-STEP_AMOUNT)
		elif event.is_action("down"):
			update_hover(STEP_AMOUNT)
		elif event.is_action("left"):
			update_hover(-STEP_AMOUNT * MOVE_COLUMN_COUNT)
		elif event.is_action("right"):
			update_hover(STEP_AMOUNT * MOVE_COLUMN_COUNT)
		elif event.is_action("ui_accept"):
			if _phase == MenuPhase.MOVE_SELECT:
				var move = _creature_moves[_hover]
				_menu_move = move
				_phase = MenuPhase.TARGET_SELECT
				MoveSelectionArrow.visible = false
				_hover = FIRST_POSITION
				update_selection_arrow(_hover)
				TargetSelectionArrow.visible = true
			elif _phase == MenuPhase.TARGET_SELECT:
				var targeted_list = get_target_list(_menu_move)
				_menu_target = targeted_list[_hover]
				add_selected_move_to_queue()
				reset_menuing()

func update_hover(amount):
	_hover += amount
	var list_size = null
	match _phase:
		MenuPhase.MOVE_SELECT:
			list_size = _creature_moves.size()
		MenuPhase.TARGET_SELECT:
			var targeted_list = get_target_list(_menu_move)
			list_size = targeted_list.size()
	if _hover >= list_size:
		_hover = FIRST_POSITION
	elif _hover < FIRST_POSITION:
		_hover = list_size - STEP_AMOUNT
	update_selection_arrow(_hover)

func get_target_list(move):
	var targeted_list = null
	match move.type:
		Move.MoveType.DAMAGE:
			targeted_list = enemies
		Move.MoveType.HEAL:
			targeted_list = allies
	return targeted_list

func add_selected_move_to_queue():
	action_queue.append(CombatEvent.new(_menu_move, _menu_creature, _menu_target))

func show_move_options(creature):
	_phase = MenuPhase.MOVE_SELECT
	_menu_creature = creature
	CombatInstructions.text = "Select Attack"
	# Get move ids
	var move_ids = creature.get_moves()
	# Get moves
	var moves = []
	for move_id in move_ids:
		var move = Global.moves.get_move_by_id(move_id)
		moves.append(move)
	_creature_moves = moves
	# Load moves
	for i in range(moves.size()):
		MoveNameLabels[i].text = moves[i].name
		MoveNameLabels[i].visible = true
	# Show menu
	CombatInstructions.visible = true
	update_selection_arrow(_hover)
	MoveSelectionArrow.texture = COMBAT_ARROW_RIGHT
	MoveSelectionArrow.visible = true

func reset_menuing():
	for i in range(MoveNameLabels.size()):
		MoveNameLabels[i].text = ""
		MoveNameLabels[i].visible = false
	_menu_creature = null
	_menu_move = null
	_phase = MenuPhase.NONE
	_hover = 0
	CombatInstructions.visible = false
	TargetSelectionArrow.visible = false
	MoveSelectionArrow.visible = false

func update_selection_arrow(position):
	match _phase:
		MenuPhase.MOVE_SELECT:
			MoveSelectionArrow.rect_position = menu_positions[position][MENU_ARROW_POSITION]
		MenuPhase.TARGET_SELECT:
			var targeted_list = get_target_list(_menu_move)
			var creature_location = targeted_list[position].scene.position
			var altered_position = creature_location + COMBAT_ARROW_DOWN_OFFSET
			TargetSelectionArrow.rect_position = altered_position

func check_end_combat():
	# Combat cannot end during animation
	if animation_lock:
		return

	var dead_enemies = 0
	if !allies[PLAYER_POSITION].is_alive():
		return Global.goto_scene(Global.Scene.GAME_OVER)

	for creature in enemies:
		if !creature.is_alive():
			dead_enemies += 1
	if dead_enemies == enemies.size():
		save_player_changes(allies[PLAYER_POSITION])
		Global.last_combat_enemies = enemies.size()
		self.set_process(false)
		return Global.goto_scene(Global.Scene.LOOT_WINDOW)

func save_player_changes(combat_player):
	Global.player.set_health(combat_player.get_health())

func check_action_queue():
	if action_queue.size() == 0 || animation_lock:
		return
	_current_combat_action = action_queue.pop_front()
	_current_combat_action = confirm_combat_action(_current_combat_action)
	if _current_combat_action == null:
		return
	animation_lock = true
	attack_animation_state = CombatAnimationState.INITIAL_STATE
	next_animation_step()

func confirm_combat_action(combat_action):
	if !combat_action.creature.is_alive():
		return null
	if !_current_combat_action.target.is_alive():
		match combat_action.move.type:
			Move.MoveType.HEAL:
				return null
			Move.MoveType.DAMAGE:
				var target = null
				if combat_action.creature.type == CombatCreature.CombatantType.ENEMY:
					target = get_first_living_creature(allies)
				else:
					target = get_first_living_creature(enemies)
				if target:
						combat_action.target = target
	return combat_action

func get_first_living_creature(creature_list):
	for creature in creature_list:
		if creature.is_alive():
			return creature
	return null

func animation_process():
	match attack_animation_state:
		CombatAnimationState.MOVING_FORWARD:
			# move forward
			move_forward(_current_combat_action.creature)
		CombatAnimationState.ANIMATING:
			# run animation 1 time
			_current_combat_action.creature.scene.apply_animation(_current_combat_action.move)
			# do damage after animation
			execute_move(_current_combat_action.creature, _current_combat_action.target, _current_combat_action.move)
		CombatAnimationState.MOVING_BACKWARD:
			# move back to original position
			move_backward(_current_combat_action.creature)
		CombatAnimationState.COMPLETE:
			# clear animation_lock
			animation_lock = false

func move_forward(creature):
	creature.scene.move_forward(creature.type)
func move_backward(creature):
	creature.scene.move_backward()
func next_animation_step():
	attack_animation_state += ATTACK_ANIMATION_STEP
	animation_process()

func execute_move(attacker, target, move):
	var log_arr = []
	log_arr.append("ATTACKER: " + attacker.get_name())
	log_arr.append("TARGET: " + target.get_name())
	# get move
	log_arr.append("MOVE: " + move.name)
	match move.type:
		Move.MoveType.HEAL:
			var damage = get_damage(attacker, target, move)
			# apply healing
			target.add_health(damage)
			# show damage
			apply_floating_text(target, damage, move.type)
			log_arr.append("HEAL: " + str(damage))
		Move.MoveType.DAMAGE:
			# check for a hit
			var accuracy = Move.calculate_accuracy(move.accuracy, attacker.get_stat("accuracy"), attacker.get_bonus("accuracy"))
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
					apply_floating_text(target, EVADED_TEXT)
			else:
				log_arr.append("ATTACK MISSED!")
				apply_floating_text(target, MISSED_TEXT)

			if target_hit && !target_evaded:
				# get the damage range
				var minimum = Move.calculate_damage(move.damage, attacker.get_stat("attack"), attacker.get_bonus("attack"), move.low)
				var maximum = Move.calculate_damage(move.damage, attacker.get_stat("attack"), attacker.get_bonus("attack"), move.high)
				# get damage
				var damage = get_damage(attacker, target, move)
				if damage <= 0:
					damaged_mitigated = true
					log_arr.append("DAMAGE MITIGATED!")
					apply_floating_text(target, BLOCKED_TEXT)
				else:
					# apply damage
					target.add_health(-damage)
					# damaged animation
					target.scene.damage_creature()
					# show damage
					apply_floating_text(target, damage, move.type)
					log_arr.append("DAMAGE: " + str(damage))

	# TODO: target has died animation
	if !target.is_alive():
		target.scene.stop_animation()

	# reset ticks
	attacker.set_ticks(0)
	attacker.is_queued = false

	# Logging stuff
	var log_string = PoolStringArray(log_arr).join(" | ")
	Global.log(Settings.LogLevel.INFO, log_string)

func get_damage(attacker, target, move):
		# get the damage range
		var minimum = Move.calculate_damage(move.damage, attacker.get_stat("attack"), attacker.get_bonus("attack"), move.low)
		var maximum = Move.calculate_damage(move.damage, attacker.get_stat("attack"), attacker.get_bonus("attack"), move.high)
		# get raw damage
		var raw_damage = calculate_damage(minimum, maximum)
		var damage = raw_damage
		if move.type == Move.MoveType.DAMAGE:
			# calculate defense
			var raw_defense = calculate_defense(target.get_stat("defense"), target.get_bonus("defense"))
			var damage_percentage = (MAX_PERCENTAGE - raw_defense)
			var damage_multiplier = (damage_percentage / MAX_PERCENTAGE)
			# mitigate damage
			damage = max(MIN_DAMAGE, floor(raw_damage * damage_multiplier))
		return damage

func apply_floating_text(target, amount, type=null):
	# Floating damage
	var damage_text = FloatingText.instance()
	damage_text.amount = amount
	damage_text.type = type
	target.scene.add_child(damage_text)

func check_to_hit(accuracy):
	var processed = accuracy
	if accuracy > ACCURACY_PROCESSED_MAX:
		processed = ACCURACY_PROCESSED_MAX
	elif accuracy < ACCURACY_PROCESSED_MIN:
		processed = ACCURACY_PROCESSED_MIN
	var rand = Global.random.randf() * PERCENT_MULTIPLIER
	var hit_target = rand <= processed
	Global.log(Settings.LogLevel.TRACE, "[check_to_hit] ACCURACY: " + str(accuracy) + " | PROCESSED: " + str(processed) + " | RAND: " + str(rand))
	return hit_target

func check_to_evade(evade, bonus_evade, move_level):
	var processed = (evade * 2) + bonus_evade - (move_level * 2)
	if processed > EVADE_PROCESSED_MAX:
		processed = EVADE_PROCESSED_MAX
	var rand = Global.random.randf() * PERCENT_MULTIPLIER
	var evaded = rand <= processed
	Global.log(Settings.LogLevel.TRACE, "[check_to_evade] EVADE: " + str(evade) + " | BONUS: " + str(bonus_evade) + " | PROCESSED: " + str(processed) + " | RAND: " + str(rand))
	return evaded

func calculate_damage(min_damage, max_damage):
	var rand = 1 + Global.random.randi() % int(max_damage - min_damage) + int(min_damage)
	Global.log(Settings.LogLevel.TRACE, "[calculate_damage] MIN: " + str(min_damage) + " | MAX: " + str(max_damage) + " | RAND: " + str(rand))
	return rand

func calculate_defense(defense, bonus_defense):
	var processed = (defense * 2) + bonus_defense
	Global.log(Settings.LogLevel.TRACE, "[calculate_defense] RAW: " + str(defense) + " | BONUS: " + str(bonus_defense) + " | processed: " + str(processed))
	return processed

func get_combat_enemies(total_combats):
	var count = MIN_ENEMIES
	if total_combats > ENEMY_COUNT_TIER_TWO:
		count += 2 * ENEMY_COUNT_STEP
	elif total_combats > ENEMY_COUNT_TIER_ONE:
		count += ENEMY_COUNT_STEP
	return min(MAX_ENEMIES, 1 + Global.random.randi() % count)
