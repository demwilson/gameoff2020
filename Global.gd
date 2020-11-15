extends Node

const Creature = preload("res://game/Creature.gd")
const GlobalPlayer = preload("res://game/GlobalPlayer.gd")
const Item = preload("res://game/Item.gd")
const Items = preload("res://game/Items.gd")
const Move = preload("res://game/Move.gd")
const Moves = preload("res://game/Moves.gd")

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
}

var TEXT_COLOR = {
	"DAMAGE": "ff3131",
	"HEAL": "2eff27",
}

# A list of scenes that are persisted, default null for each
var persisted_scenes = [null]
var current_scene_id = null
var current_scene = null


#Upgraded stats
var Upgrades = {
	"Oxygen": 0,
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
const BASE_OXYGEN = 30
const CURRENCY_TEXT = "Currency"
const OXYGEN_TEXT = "Oxygen"
var player = null
var moves = null
var items = null
var current_level = 1
var currency = 6000

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	var available_moves = [
		Move.new("Basic Attack", 1, Move.MoveType.DAMAGE, 1, 2, [0, 2], [90, 1, 2]),
		Move.new("Firebolt", 1, Move.MoveType.DAMAGE, 1, 5, [0, 2], [95, 0, 1]),
		Move.new("Fireball", 2, Move.MoveType.DAMAGE, 1, 2, [25, 2], [50, 4, 1.5], Moves.MoveList.FIREBOLT),
		Move.new("Heal", 1, Move.MoveType.HEAL, 1, 2, [0, 2]),
	]
	# This doesn't exist yet. Requires monsters/creatures.
	# Item.new("Friendly Robot Servant", Item.ItemType.ALLY, "This robot will fight for you.", Enemy.RobotServant)
	var available_items = [
		Item.new(0, "Basic Attack", Item.ItemTier.LEVEL_ONE, Item.ItemType.MOVE, "This is a basic attack.", Moves.MoveList.BASIC_ATTACK),
		Item.new(1, "Flimsy Sword", Item.ItemTier.LEVEL_ONE, Item.ItemType.BONUS, "This is an almost useless sword.", [Creature.Stats.ATTACK, 1]),
		Item.new(2, "Cybernetic Eye", Item.ItemTier.LEVEL_ONE, Item.ItemType.STAT, "This eye knows where things are even if you don't.", [Creature.Stats.ACCURACY, 2]),
		Item.new(3, "Firebolt", Item.ItemTier.LEVEL_ONE, Item.ItemType.MOVE, "This launches a bolt of fire at your enemy!", Moves.MoveList.FIREBOLT),
	]

	moves = Moves.new(available_moves)
	items = Items.new(available_items)

	# Build player after initializing everything
	build_player()

func build_player():
	# TODO: Add upgrades
#	var player_stats = Creature.Stats.new(Creature.BASE_STATS)
	var player_stats = Creature.Stats.new([5,5,5,5,5])
	var player_bonuses = Creature.Stats.new()

	var player_items = [
		Items.ItemList.CROWBAR,
		Items.ItemList.FLIMSY_SWORD,
		Items.ItemList.CYBERNETIC_EYE,
		Items.ItemList.FIREBOLT,
	]
	player = GlobalPlayer.new(PLAYER_NAME, BASE_HEALTH, BASE_HEALTH, BASE_OXYGEN, BASE_OXYGEN, player_stats, player_bonuses, player_items)

func goto_scene(target_scene):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:
	match target_scene:
		Scene.OVERWORLD:
			call_deferred("_deferred_goto_scene", target_scene, "res://overworld/Overworld.tscn")
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

func _deferred_goto_scene(scene, path):
	# stop/start processing
	var overworld_node = persisted_scenes[Scene.OVERWORLD]
	if overworld_node != null:
		if scene != Scene.OVERWORLD:
			stop_processing(overworld_node)
		else:
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
