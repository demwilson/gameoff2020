extends Node

const Creature = preload("res://game/Creature.gd")
const GlobalPlayer = preload("res://game/GlobalPlayer.gd")
const Enemy = preload("res://game/Enemy.gd")
const Enemies = preload("res://game/Enemies.gd")
const Item = preload("res://game/Item.gd")
const Items = preload("res://game/Items.gd")
const Move = preload("res://game/Move.gd")
const Moves = preload("res://game/Moves.gd")
const Stats = preload("res://game/Stats.gd")

# Persisted scenes must be first in the enum
enum Scene {
	# persisted
	OVERWORLD,
	MENU,
	# normal
	TITLE,
	COMBAT,
	STATS,
	COMBAT_WIN,
	GAME_OVER,
	GROUND_CONTROL,
	SETTINGS,
	LOOT_WINDOW
}

var TEXT_COLOR = {
	"DAMAGE": "ff3131",
	"HEAL": "2eff27",
	"TEXT": "000000",
}

const PLAYER_POSITION = 0
const TEXTURE_FILE_EXTENSION = ".png"
const ANIMATION_FILE_EXTENSION = ".tres"
const BASE_STAT_VALUE = 0
const BASE_ATTACK_VALUE = 3
const BASE_ACCURACY_VALUE = 1
const BASE_SPEED_VALUE = 2
const STAT_STEP = 1
const OXYGEN_STEP = 50
const HEALTH_STEP = 20

# A list of scenes that are persisted, default null for each
var persisted_scenes = [null]
var current_scene_id = null
var current_scene = null


#Upgraded stats
var Upgrades = {
	"Oxygen": 0,
	"Health": 0,
	"Attack": 0,
	"Accuracy": 0,
	"Speed": 0,
	"Defense": 0,
	"Evade": 0,
	"BasicWeapon": 0,
	"BasicDefense": 0,
	"CombatTraining": 0,
	"AdvanceWeapon": 0,
	"AdvanceDefense": 0,
	"AdvanceTraining": 0,
}

# game mechanics
const PLAYER_NAME = "Astronaut"
const BASE_HEALTH = 100
const BASE_OXYGEN = 200
const CURRENCY_TEXT = "Moon Rocks"
const OXYGEN_TEXT = "Units of Oxygen"
var player = null
var moves = null
var items = null
var enemies = null
var last_combat_enemies = 0
var floor_level = 1
var currency = 0
var roll_up_percentage = 1
var boss_fight = false

# Debugging purposes
var random
var current_seed
var seed_value = null

func _ready():
	# Add debugging settings here
	if Settings.debug >= Settings.LogLevel.TRACE:
		currency = 6000
		# Uncomment to force a seed value
		# seed_value = -7489110890573097118

	# Set RNG value and get seed.
	random = RandomNumberGenerator.new()
	if seed_value:
		random.set_seed(seed_value)
	else:
		random.randomize()
	current_seed = random.get_seed()
	self.log(Settings.LogLevel.DEBUG, "[Global] Random Seed: " + str(current_seed) + " | DEBUG Seed: " + str(seed_value))

	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	var available_moves = [
		Move.new("Weak Swing", 0, Move.MoveType.DAMAGE, Move.AnimationPath.BASIC_ATTACK, 0.5, 1, [1, 2], [90, 0]),
		Move.new("Basic Swing", 1, Move.MoveType.DAMAGE, Move.AnimationPath.BASIC_ATTACK, 0.7, 1.1, [2, 2], [85, 3]),
		Move.new("Solid Swing", 2, Move.MoveType.DAMAGE, Move.AnimationPath.BASIC_ATTACK, 0.75, 1.25, [2, 3], [80, 6], Moves.MoveList.MELEE_T1),
		Move.new("Masterful Swing", 3, Move.MoveType.DAMAGE, Move.AnimationPath.BASIC_ATTACK, 1, 1.5, [3, 4], [75, 9], Moves.MoveList.MELEE_T2),
		Move.new("Firebolt", 1, Move.MoveType.DAMAGE, Move.AnimationPath.FIREBOLT, 0.8, 1.2, [8, 2], [95, 0]),
		Move.new("Fireball", 2, Move.MoveType.DAMAGE, Move.AnimationPath.FIREBOLT, 1, 2, [25, 4], [85, 3], Moves.MoveList.PSY_T1),
		Move.new("Immolate", 3, Move.MoveType.DAMAGE, Move.AnimationPath.FIREBOLT, 1, 2, [50, 8], [70, 5], Moves.MoveList.PSY_T2),
		Move.new("Med Pack", 1, Move.MoveType.HEAL, Move.AnimationPath.HEAL, 1, 2, [5, 2]),
		Move.new("Stim Pack", 2, Move.MoveType.HEAL, Move.AnimationPath.HEAL, 2, 3, [10, 3], Moves.MoveList.HEAL_T1),
		Move.new("Healing Nanites", 3, Move.MoveType.HEAL, Move.AnimationPath.HEAL, 2, 3, [25, 6], Moves.MoveList.HEAL_T2),
	]
	var available_items = [
		# Game Start
		Item.new(0, "Crowbar", Item.ItemTier.GAME_START, Item.ItemType.MOVE, "You swing the crowbar.", Moves.MoveList.MELEE_T0),

		# T1 Bonus Items
		Item.new(1, "Flimsy Sword", Item.ItemTier.LEVEL_ONE, Item.ItemType.BONUS, "This is an almost useless sword.", [Creature.Stats.ATTACK, 1]),
		Item.new(2, "Ruler", Item.ItemTier.LEVEL_ONE, Item.ItemType.BONUS, "Helps with measurements.", [Creature.Stats.ACCURACY, 1]),
		# No bonuses allowed for speed
		Item.new(3, "Flimsy Buckler", Item.ItemTier.LEVEL_ONE, Item.ItemType.BONUS, "Only a shield in the most technical sense.", [Creature.Stats.DEFENSE, 1]),
		Item.new(4, "Tattered Cloak", Item.ItemTier.LEVEL_ONE, Item.ItemType.BONUS, "Kinda catches their attention.", [Creature.Stats.EVADE, 1]),
		# Basic Stat Items
		Item.new(5, "Strength Enhancers", Item.ItemTier.LEVEL_ONE, Item.ItemType.STAT, "You immediately feel stronger.", [Creature.Stats.ATTACK, 1]),
		Item.new(6, "Visual Overlay", Item.ItemTier.LEVEL_ONE, Item.ItemType.STAT, "Does the math for you.", [Creature.Stats.ACCURACY, 1]),
		Item.new(7, "Shock Absorbers", Item.ItemTier.LEVEL_ONE, Item.ItemType.STAT, "You can feel the spring in your step.", [Creature.Stats.SPEED, 1]),
		Item.new(8, "Fiber Mesh", Item.ItemTier.LEVEL_ONE, Item.ItemType.STAT, "Pretty resilient material.", [Creature.Stats.DEFENSE, 1]),
		Item.new(9, "Suit Awareness System", Item.ItemTier.LEVEL_ONE, Item.ItemType.STAT, "The suit doesn't want to die either.", [Creature.Stats.EVADE, 1]),
		# Basic Allies
		Item.new(10, "Friendly Robot Servant", Item.ItemTier.LEVEL_ONE, Item.ItemType.ALLY, "This robot will fight for you.", Enemies.EnemyList.ROBOT_T1),
		# Basic Moves
		Item.new(11, "Space Wrench", Item.ItemTier.GAME_START, Item.ItemType.MOVE, "You swing the space wrench.", Moves.MoveList.MELEE_T1),
		Item.new(12, "Psychic Fire", Item.ItemTier.LEVEL_ONE, Item.ItemType.MOVE, "You can make fire with your mind!", Moves.MoveList.PSY_T1),
		Item.new(13, "Med Kit", Item.ItemTier.LEVEL_ONE, Item.ItemType.MOVE, "Patching yourself up when you need it!", Moves.MoveList.HEAL_T1),

		# T2 Bonus Items
		Item.new(14, "Basic Phaser", Item.ItemTier.LEVEL_TWO, Item.ItemType.BONUS, "Point and pull the trigger.", [Creature.Stats.ATTACK, 4]),
		Item.new(15, "Aged Sight", Item.ItemTier.LEVEL_TWO, Item.ItemType.BONUS, "It still helps.", [Creature.Stats.ACCURACY, 4]),
		# No bonuses allowed for speed
		Item.new(16, "Basic Energy Shield", Item.ItemTier.LEVEL_TWO, Item.ItemType.BONUS, "It will absorb some of the blow.", [Creature.Stats.DEFENSE, 4]),
		Item.new(17, "Proximity Sensor", Item.ItemTier.LEVEL_TWO, Item.ItemType.BONUS, "You will know when they are close.", [Creature.Stats.EVADE, 4]),
		# Advanced Stat Items
		Item.new(18, "Strength Amplifiers", Item.ItemTier.LEVEL_TWO, Item.ItemType.STAT, "Now you know true strength.", [Creature.Stats.ATTACK, 2]),
		Item.new(19, "Cybernetic Eye", Item.ItemTier.LEVEL_TWO, Item.ItemType.STAT, "This eye knows where things are even if you don't.", [Creature.Stats.ACCURACY, 2]),
		Item.new(20, "Thrusters", Item.ItemTier.LEVEL_TWO, Item.ItemType.STAT, "They get you where you need to be.", [Creature.Stats.SPEED, 2]),
		Item.new(21, "Steel Mesh", Item.ItemTier.LEVEL_TWO, Item.ItemType.STAT, "This will stop almost everything.", [Creature.Stats.DEFENSE, 2]),
		Item.new(22, "Automated Evasion Suit", Item.ItemTier.LEVEL_TWO, Item.ItemType.STAT, "Don't worry, the suit will handle it.", [Creature.Stats.EVADE, 2]),
		# Basic Allies
		Item.new(23, "Friendly Robot Guard", Item.ItemTier.LEVEL_TWO, Item.ItemType.ALLY, "This robot will fight for you.", Enemies.EnemyList.ROBOT_T2),
		# Advanced Moves
		Item.new(24, "Space Machete", Item.ItemTier.LEVEL_TWO, Item.ItemType.MOVE, "You swing the space machete.", Moves.MoveList.MELEE_T2),
		Item.new(25, "Expanded Psychic Fire", Item.ItemTier.LEVEL_TWO, Item.ItemType.MOVE, "More fire solves most problems.", Moves.MoveList.PSY_T2),
		Item.new(26, "Stim Injections", Item.ItemTier.LEVEL_ONE, Item.ItemType.MOVE, "The injections make you feel invincible!", Moves.MoveList.HEAL_T2),

		# T3 Bonus Items
		Item.new(27, "Plasma Sabre", Item.ItemTier.LEVEL_THREE, Item.ItemType.BONUS, "It cuts ALL THE THINGS!", [Creature.Stats.ATTACK, 8]),
		Item.new(28, "Locking System", Item.ItemTier.LEVEL_THREE, Item.ItemType.BONUS, "Nothing will escape you.", [Creature.Stats.ACCURACY, 8]),
		# No bonuses allowed for speed
		Item.new(29, "Plasteel Mesh", Item.ItemTier.LEVEL_THREE, Item.ItemType.BONUS, "It will absorb most of the blow.", [Creature.Stats.DEFENSE, 8]),
		Item.new(30, "Foresight Implant", Item.ItemTier.LEVEL_THREE, Item.ItemType.BONUS, "See what happens before you make a decision.", [Creature.Stats.EVADE, 8]),
		# Advanced Stat Items
		Item.new(31, "Quantum Strength", Item.ItemTier.LEVEL_THREE, Item.ItemType.STAT, "Oh no... now you got math involved.", [Creature.Stats.ATTACK, 4]),
		Item.new(32, "Third Eye", Item.ItemTier.LEVEL_THREE, Item.ItemType.STAT, "Nothing can hide.", [Creature.Stats.ACCURACY, 4]),
		Item.new(33, "Chrono Boots", Item.ItemTier.LEVEL_THREE, Item.ItemType.STAT, "Time is relative.", [Creature.Stats.SPEED, 4]),
		Item.new(34, "Plasteel Mesh", Item.ItemTier.LEVEL_THREE, Item.ItemType.STAT, "This will stop almost everything.", [Creature.Stats.DEFENSE, 4]),
		Item.new(35, "Essokinesis Implant", Item.ItemTier.LEVEL_THREE, Item.ItemType.STAT, "In some reality, somewhere, you're not getting hit.", [Creature.Stats.EVADE, 4]),
		# Advanced Moves
		Item.new(36, "Mono Blade", Item.ItemTier.LEVEL_THREE, Item.ItemType.MOVE, "You swing the mono balde.", Moves.MoveList.MELEE_T3),
		Item.new(37, "Psychic Immolation", Item.ItemTier.LEVEL_THREE, Item.ItemType.MOVE, "Let them live in the flames!", Moves.MoveList.PSY_T3),
		Item.new(38, "Healing Nanites", Item.ItemTier.LEVEL_THREE, Item.ItemType.MOVE, "Healing yourself is below you.", Moves.MoveList.HEAL_T3),
	]
	var available_enemies = [
		Enemy.new(
			1, "Guard Dog", Creature.CreatureSize.MEDIUM, 20, 20, 
			Creature.Stats.new([2, 2, 2, 0, 1]),
			Creature.Stats.new([0, 3, 0, 0, 0]),
			Creature.BasePath.DOG, Creature.Behavior.PACK,
			[Moves.MoveList.MELEE_T1]
		),
		Enemy.new(
			2, "Mutated Dog", Creature.CreatureSize.MEDIUM, 60, 60, 
			Creature.Stats.new([3, 3, 3, 1, 3]),
			Creature.Stats.new([5, 6, 0, 2, 5]),
			Creature.BasePath.DOG, Creature.Behavior.PACK,
			[Moves.MoveList.MELEE_T2]
		),
		Enemy.new(
			1, "Large Bug", Creature.CreatureSize.MEDIUM, 10, 10,
			Creature.Stats.new([1, 1, 2, 0, 2]),
			Creature.Stats.new([0, 4, 0, 0, 4]),
			Creature.BasePath.BUG, Creature.Behavior.FOCUSED,
			[Moves.MoveList.MELEE_T1]
		),
		Enemy.new(
			2, "Mutated Bug", Creature.CreatureSize.MEDIUM, 35, 35,
			Creature.Stats.new([2, 2, 3, 1, 3]),
			Creature.Stats.new([2, 4, 0, 1, 4]),
			Creature.BasePath.BUG, Creature.Behavior.STUPID,
			[Moves.MoveList.MELEE_T2]
		),
		Enemy.new(
			1, "Robot Servant", Creature.CreatureSize.LARGE_TALL, 35, 35,
			Creature.Stats.new(Creature.BASE_STATS),
			Creature.Stats.new(Creature.BASE_BONUSES),
			Creature.BasePath.ROBOT, Creature.Behavior.STUPID,
			[Moves.MoveList.MELEE_T2]
		),
		Enemy.new(
			2, "Robot Guard", Creature.CreatureSize.LARGE_TALL, 90, 90,
			Creature.Stats.new([3, 3, 3, 3, 3]),
			Creature.Stats.new([4, 4, 0, 4, 4]),
			Creature.BasePath.ROBOT, Creature.Behavior.FOCUSED,
			[Moves.MoveList.MELEE_T3]
		),
		Enemy.new(
			0, "Spliced Tardigrade", Creature.CreatureSize.LARGE_TALL, 200, 200,
			Creature.Stats.new([5, 5, 5, 5, 5]),
			Creature.Stats.new([5, 5, 0, 5, 5]),
			Creature.BasePath.TARDIGRADE, Creature.Behavior.BOSS,
			[Moves.MoveList.MELEE_T3]
		),
	]

	moves = Moves.new(available_moves)
	items = Items.new(available_items)
	enemies = Enemies.new(available_enemies)

	# Build player after initializing everything
	build_player()

func build_player():
	# Stats
	var max_health = BASE_HEALTH + (HEALTH_STEP * Upgrades.Health)
	var current_health = max_health
	var max_oxygen = BASE_OXYGEN + (OXYGEN_STEP * Upgrades.Oxygen)
	var current_oxygen = max_oxygen
	var attack = BASE_ATTACK_VALUE + (STAT_STEP * Upgrades.Attack)
	var accuracy = BASE_ACCURACY_VALUE + (STAT_STEP * Upgrades.Accuracy)
	var speed = BASE_SPEED_VALUE + (STAT_STEP * Upgrades.Speed)
	var defense = BASE_STAT_VALUE + (STAT_STEP * Upgrades.Defense)
	var evade = BASE_STAT_VALUE + (STAT_STEP * Upgrades.Evade)

	var player_stats = Creature.Stats.new([attack, accuracy, speed, defense, evade])
	var player_bonuses = Creature.Stats.new()

	# Items
	var player_items = [Items.ItemList.CROWBAR]
	# Add attack-based item (T1)
	if Upgrades.BasicWeapon:
		var item = items.get_random_item(Item.ItemTier.LEVEL_ONE, Item.ItemType.BONUS, Stats.ATTACK)
		player_items.append(item.id)
	# Add defense-based item (T1)
	if Upgrades.BasicDefense:
		var item = items.get_random_item(Item.ItemTier.LEVEL_ONE, Item.ItemType.BONUS, Stats.DEFENSE)
		player_items.append(item.id)
	# Add move-based item (T1)
	if Upgrades.CombatTraining:
		var item = items.get_random_item(Item.ItemTier.LEVEL_ONE, Item.ItemType.MOVE)
		player_items.append(item.id)
	# Add attack-based item (T2)
	if Upgrades.AdvanceWeapon:
		var item = items.get_random_item(Item.ItemTier.LEVEL_TWO, Item.ItemType.BONUS, Stats.ATTACK)
		player_items.append(item.id)
	# Add defense-based item (T2)
	if Upgrades.AdvanceDefense:
		var item = items.get_random_item(Item.ItemTier.LEVEL_TWO, Item.ItemType.BONUS, Stats.DEFENSE)
		player_items.append(item.id)
	# Add move-based item (T2)
	if Upgrades.AdvanceTraining:
		var item = items.get_random_item(Item.ItemTier.LEVEL_TWO, Item.ItemType.MOVE)
		player_items.append(item.id)

	player = GlobalPlayer.new(
		PLAYER_NAME,
		Creature.CreatureSize.LARGE_TALL,
		max_health,
		current_health,
		max_oxygen,
		current_oxygen,
		player_stats,
		player_bonuses,
		player_items,
		Creature.BasePath.PLAYER
	)

func goto_scene(target_scene, function_call = null):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:
	match target_scene:
		Scene.OVERWORLD:
			call_deferred("_deferred_goto_scene", target_scene, "res://overworld/Overworld.tscn", function_call)
		Scene.TITLE:
			_deferred_goto_scene(target_scene, "res://Title.tscn")
		Scene.COMBAT:
			_deferred_goto_scene(target_scene, "res://combat/Combat.tscn")
		Scene.STATS:
			_deferred_goto_scene(target_scene, "res://Stats.tscn")
		Scene.GAME_OVER:
			call_deferred("_deferred_goto_scene", target_scene, "res://ground_control/GroundControl.tscn")
		Scene.COMBAT_WIN:
			call_deferred("_deferred_goto_scene", target_scene, "res://combat/CombatWin.tscn")
		Scene.GROUND_CONTROL:
			call_deferred("_deferred_goto_scene", target_scene, "res://ground_control/GroundControl.tscn")
		Scene.SETTINGS:
			call_deferred("_deferred_goto_scene", target_scene, "res://settings/Settings.tscn")
		Scene.LOOT_WINDOW:
			call_deferred("_deferred_goto_scene", target_scene, "res://loot_window/LootWindow.tscn")

func _deferred_goto_scene(scene, path, function_call = null):
	# stop/start processing
	var overworld_node = persisted_scenes[Scene.OVERWORLD]
	if overworld_node != null:
		if scene != Scene.OVERWORLD:
			overworld_node.set_ui_visible(false)
			stop_processing(overworld_node)
		else:
			overworld_node.set_ui_visible(true)
			overworld_node.player.set_can_move(true)
			start_processing(overworld_node)

	if current_scene_id && current_scene_id != Scene.OVERWORLD:
		current_scene.free()
	# create/retrieve scene
	current_scene_id = scene
	match scene:
		Scene.OVERWORLD:
			if overworld_node:
				current_scene = persisted_scenes[Scene.OVERWORLD]
				get_tree().set_current_scene(current_scene)
			else:
				continue
		_:
			load_new_scene(scene, path)
	
	if function_call != null && current_scene.has_method(function_call):
		current_scene.call(function_call)
		
func load_new_scene(scene, path):
	# Load the new scene.
	var s = ResourceLoader.load(path)
	# Instance the new scene.
	current_scene = s.instance()
	if is_scene_persisted(scene):
		persist_scene(scene, current_scene)
	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)
	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)

func stop_processing(node):
	node.set_process(false)
	node.set_process_input(false)
	if node.has_method("set_audio"):
		node.set_audio(false)
func start_processing(node):
	node.set_process(true)
	node.set_process_input(true)
	if node.has_method("set_audio"):
		node.set_audio(true)

func is_scene_persisted(scene):
	return scene == Scene.OVERWORLD || scene == Scene.MENU
func persist_scene(scene, scene_node):
	persisted_scenes[scene] = scene_node

func log(level, msg):
	if level <= Settings.debug:
		print(msg)

# Useful functions
static func sum_array(array):
	var sum = 0
	for element in array:
		 sum += element
	return sum

func get_random_type_by_weight(weight_list):
	var total_weight = sum_array(weight_list)
	var rand = 1 + (Global.random.randi() % total_weight)
	for position in range(weight_list.size()):
		var chance = weight_list[position]
		if rand <= chance:
			return position
		rand -= chance

func populate_loot_list(loot_list, loot_bag):
	for loot in loot_bag:
		match loot.type:
			Items.LootType.GEAR:
				loot_list.add_item(loot.item.name, null, false)
				loot_list.set_item_tooltip(loot_list.get_item_count()-1, loot.item.get_description())
			Items.LootType.CURRENCY:
				loot_list.add_item(str(loot.item) + " " + Global.CURRENCY_TEXT, null, false)
			Items.LootType.OXYGEN:
				loot_list.add_item(str(loot.item) + " " + Global.OXYGEN_TEXT, null, false)
