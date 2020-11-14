extends Node

const Creature = preload("res://game/Creature.gd")
const GlobalPlayer = preload("res://game/GlobalPlayer.gd")
const Item = preload("res://game/Item.gd")
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
	STATS
}

var TEXT_COLOR = {
	"DAMAGE": "ff3131",
	"HEAL": "2eff27",
}

# A list of scenes that are persisted, default null for each
var persisted_scenes = [null]
var previous_scene = null
var current_scene = null

# game mechanics
const PLAYER_NAME = "Astronaut"
const BASE_HEALTH = 100
const BASE_OXYGEN = 30
var player = null
var moves = null
var current_level = 1

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	player = build_player()
	moves = Moves.new()

func build_player():
	# TODO: Add upgrades
	var player_stats = Creature.Stats.new(Creature.BASE_STATS)
	var player_bonuses = Creature.Stats.new()
	
	# These do not exist yet.
	# Item.new("Friendly Robot Servant", Item.ItemType.ALLY, "This robot will fight for you.", Enemy.RobotServant)
	var player_items = [
		Item.new("Basic Attack", Item.ItemType.MOVE, "This is a basic attack.", Moves.MoveList.BASIC_ATTACK),
		Item.new("Flimsy Sword", Item.ItemType.BONUS, "This is an almost useless sword.", [Creature.Stats.ATTACK, 1]),
		Item.new("Cybernetic Eye", Item.ItemType.STAT, "This eye knows where things are even if you don't.", [Creature.Stats.ACCURACY, 2]),
		Item.new("Firebolt", Item.ItemType.MOVE, "This launches a bolt of fire at your enemy!", Moves.MoveList.FIREBOLT),
	]
	return GlobalPlayer.new(PLAYER_NAME, BASE_HEALTH, BASE_HEALTH, BASE_OXYGEN, BASE_OXYGEN, player_stats, player_bonuses, player_items)

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
			call_deferred("_deferred_goto_scene", Scene.OVERWORLD, "res://overworld/Overworld.tscn")
		Scene.TITLE:
			_deferred_goto_scene(Scene.COMBAT, "res://Title.tscn")
		Scene.COMBAT:
			_deferred_goto_scene(Scene.COMBAT, "res://combat/Combat.tscn")
		Scene.STATS:
			_deferred_goto_scene(Scene.STATS, "res://Stats.tscn")
		Scene.GAME_OVER:
			#call_deferred("_deferred_goto_scene", Scene.OVERWORLD, "res://GameOver.tscn")
			call_deferred(Scene.COMBAT, "res://Title.tscn")

func _deferred_goto_scene(scene, path):
	# stop/start processing
	var overworld_node = persisted_scenes[Scene.OVERWORLD]
	if overworld_node != null:
		if scene != Scene.OVERWORLD:
			stop_processing(overworld_node)
		else:
			overworld_node.player.set_can_move(true)
			start_processing(overworld_node)
		overworld_node.toggle_audio()

	# create/retrieve scene
	match scene:
		Scene.OVERWORLD:
			current_scene.free()
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
func start_processing(node):
	node.set_process(true)
	node.set_process_input(true)

func is_scene_persisted(scene):
	return scene == Scene.OVERWORLD || scene == Scene.MENU
func persist_scene(scene, scene_node):
	persisted_scenes[scene] = scene_node

func log(level, msg):
	if level <= Settings.debug:
		print(msg)
