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
}

var TEXT_COLOR = {
	"DAMAGE": "ff3131",
	"HEAL": "2eff27",
	"TEXT": "000000",
}

const TEXTURE_FILE_EXTENSION = ".png"
const ANIMATION_FILE_EXTENSION = ".tres"
const BASE_STAT_VALUE = 1
const STAT_STEP = 0.5
const OXYGEN_STEP = 5
const HEALTH_STEP = 5

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
var floor_level = 1
var currency = 0

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
		Move.new("Basic Attack", 1, Move.MoveType.DAMAGE, Move.AnimationPath.BASIC_ATTACK, 0.5, 1, [4, 2], [90, 2]),
		Move.new("Firebolt", 1, Move.MoveType.DAMAGE, Move.AnimationPath.FIREBOLT, 0.8, 1.2, [8, 2], [95, 0]),
		Move.new("Fireball", 2, Move.MoveType.DAMAGE, Move.AnimationPath.FIREBOLT, 1, 2, [25, 4], [70, 5], Moves.MoveList.FIREBOLT),
		Move.new("Heal", 1, Move.MoveType.HEAL, Move.AnimationPath.HEAL, 2, 3, [1, 3]),
	]
	var available_items = [
		Item.new(0, "Crowbar", Item.ItemTier.GAME_START, Item.ItemType.MOVE, "You swing the crowbar.", Moves.MoveList.BASIC_ATTACK),
		Item.new(1, "Flimsy Sword", Item.ItemTier.LEVEL_ONE, Item.ItemType.BONUS, "This is an almost useless sword.", [Creature.Stats.ATTACK, 1]),
		Item.new(2, "Ruler", Item.ItemTier.LEVEL_ONE, Item.ItemType.BONUS, "Helps with measurements.", [Creature.Stats.ACCURACY, 1]),
		Item.new(3, "Sandals", Item.ItemTier.LEVEL_ONE, Item.ItemType.BONUS, "Better than walking barefoot.", [Creature.Stats.SPEED, 1]),
		Item.new(4, "Flimsy Buckler", Item.ItemTier.LEVEL_ONE, Item.ItemType.BONUS, "Only a shield in the most technical sense.", [Creature.Stats.DEFENSE, 1]),
		Item.new(5, "Tattered Cloak", Item.ItemTier.LEVEL_ONE, Item.ItemType.BONUS, "Kinda catches the wind.", [Creature.Stats.EVADE, 1]),
		Item.new(6, "Cybernetic Eye", Item.ItemTier.LEVEL_ONE, Item.ItemType.STAT, "This eye knows where things are even if you don't.", [Creature.Stats.ACCURACY, 2]),
		Item.new(7, "Firebolt", Item.ItemTier.LEVEL_ONE, Item.ItemType.MOVE, "This launches a bolt of fire at your enemy!", Moves.MoveList.FIREBOLT),
		Item.new(8, "Friendly Robot Servant", Item.ItemTier.LEVEL_ONE, Item.ItemType.ALLY, "This robot will fight for you.", Enemies.EnemyList.ROBOT_T1),
		Item.new(9, "Basic Phaser", Item.ItemTier.LEVEL_TWO, Item.ItemType.BONUS, "Point and pull the trigger.", [Creature.Stats.ATTACK, 5]),
		Item.new(10, "Aged Sight", Item.ItemTier.LEVEL_TWO, Item.ItemType.BONUS, "It still helps.", [Creature.Stats.ACCURACY, 5]),
		Item.new(11, "Boots", Item.ItemTier.LEVEL_TWO, Item.ItemType.BONUS, "Comfortable boots help with movement.", [Creature.Stats.SPEED, 3]),
		Item.new(12, "Fiber Mesh", Item.ItemTier.LEVEL_TWO, Item.ItemType.BONUS, "Pretty resilient material.", [Creature.Stats.DEFENSE, 5]),
		Item.new(13, "Proximity Sensor", Item.ItemTier.LEVEL_TWO, Item.ItemType.BONUS, "You know when they are close.", [Creature.Stats.EVADE, 5]),
		Item.new(14, "Fireball", Item.ItemTier.LEVEL_TWO, Item.ItemType.MOVE, "This launches a large ball of fire at your enemy!", Moves.MoveList.FIREBALL),
		Item.new(15, "Heal", Item.ItemTier.LEVEL_ONE, Item.ItemType.MOVE, "This heals you. It's amazing!", Moves.MoveList.HEAL),
	]
	var available_enemies = [
		Enemy.new(1, "Guard Dog", Creature.CreatureSize.MEDIUM, 20, 20, Creature.Stats.new([2, 2, 2, 0, 1]), Creature.Stats.new([0, 0, 0, 0, 0]), Creature.BasePath.DOG, Creature.Behavior.REVENGE, [Moves.MoveList.BASIC_ATTACK]),
		Enemy.new(2, "Mutated Dog", Creature.CreatureSize.MEDIUM, 75, 75, Creature.Stats.new([4, 4, 3, 1, 3]), Creature.Stats.new([10, 0, 0, 2, 5]), Creature.BasePath.DOG, Creature.Behavior.FOCUSED, [Moves.MoveList.BASIC_ATTACK]),
		Enemy.new(1, "Large Bug", Creature.CreatureSize.MEDIUM, 10, 10, Creature.Stats.new([1, 1, 2, 0, 2]), Creature.Stats.new([0, 4, 0, 0, 4]), Creature.BasePath.BUG, Creature.Behavior.STUPID, [Moves.MoveList.BASIC_ATTACK]),
		Enemy.new(2, "Mutated Bug", Creature.CreatureSize.MEDIUM, 150, 150, Creature.Stats.new([5, 2, 1, 5, 0]), Creature.Stats.new([4, 4, 0, 1, 4]), Creature.BasePath.BUG, Creature.Behavior.STUPID, [Moves.MoveList.BASIC_ATTACK]),
		Enemy.new(1, "Robot Servant", Creature.CreatureSize.LARGE_TALL, 35, 35, Creature.Stats.new(Creature.BASE_STATS), Creature.Stats.new(Creature.BASE_BONUSES), Creature.BasePath.ROBOT, Creature.Behavior.STUPID, [Moves.MoveList.BASIC_ATTACK]),
		Enemy.new(2, "Robot Guard", Creature.CreatureSize.LARGE_TALL, 90, 90, Creature.Stats.new([3, 3, 3, 3, 3]), Creature.Stats.new([5, 5, 5, 5, 5]), Creature.BasePath.ROBOT, Creature.Behavior.FOCUSED, [Moves.MoveList.BASIC_ATTACK]),
		Enemy.new(0, "Boss", Creature.CreatureSize.LARGE_TALL, 300, 300, Creature.Stats.new([4, 4, 4, 4, 4]), Creature.Stats.new([3, 3, 3, 3, 3]), Creature.BasePath.TARDIGRADE, Creature.Behavior.BOSS, [Moves.MoveList.BASIC_ATTACK]),
	]

	moves = Moves.new(available_moves)
	items = Items.new(available_items)
	enemies = Enemies.new(available_enemies)

	# Build player after initializing everything
	build_player()

func build_player():
	# Stats
	# TODO: Add health upgrade
	var max_health = BASE_HEALTH + (HEALTH_STEP * Upgrades.Health)
	var current_health = max_health
	var max_oxygen = BASE_OXYGEN + (OXYGEN_STEP * Upgrades.Oxygen)
	var current_oxygen = max_oxygen
	var attack = BASE_STAT_VALUE + (STAT_STEP * Upgrades.Attack)
	var accuracy = BASE_STAT_VALUE + (STAT_STEP * Upgrades.Accuracy)
	var speed = BASE_STAT_VALUE + (STAT_STEP * Upgrades.Speed)
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

func populate_loot_list(loot_list, loot):
	var entries = []
	match loot.type:
		Items.LootType.ITEM:
			for item in loot.items:
				entries.append(item.name)
		Items.LootType.CURRENCY:
			entries.append(str(loot.items) + " " + Global.CURRENCY_TEXT)
		Items.LootType.OXYGEN:
			entries.append(str(loot.items) + " " + Global.OXYGEN_TEXT)
	for entry in entries:
		loot_list.add_item(entry, null, false)
