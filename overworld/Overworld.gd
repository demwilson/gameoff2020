extends Node2D

const PERSIST = true
const PLAYER_START_HP = 5

var counter = 0

# node references
onready var tile_map = $TileMap
onready var player = $PlayerRoot/Player
onready var loot_list = $GUI/Loot/LootList

# game state
var player_tile
var score = 0

func _ready():
	place_player()
	
func place_player():
	player.position = tile_map.playerStartPosition
	$PlayerRoot/Anchor.set_start_position(player.position)
	print("The player starts at: " + str(player.position))
	tile_map.isGeneratingNewLevel = false

func _process(delta):
	if Settings.debug:
		$GUI/TilePos.visible = true
		$GUI/MousePos.visible = true
		$GUI/Counter.visible = true
		$GUI/StepCount.visible = true
		$GUI/StepToFight.visible = true
		var cpos = $TileMap.world_to_map(player.position)
		$GUI/TilePos.text = str(cpos)
		var mpos = $TileMap.world_to_map(get_global_mouse_position())
		$GUI/MousePos.text = str(mpos)
		counter += delta
		$GUI/Counter.text = "Counter: " + str(counter)
		$GUI/StepCount.text = "Steps Taken: " + str(player.stepsTaken)
		$GUI/StepToFight.text = "StepsToFight: " + str(player.stepsToTriggerCombat)

func _input(event):
	if !event.is_pressed():
		return
	elif event.is_action("stats_profile"):
		Global.goto_scene(Global.Scene.STATS)

func win_event():
	set_audio(false)
	$GUI/Win.visible = true
	
func set_audio(value):
	player.get_node("AudioStreamPlayer2D").stream_paused = !value

func _on_Restart_pressed():
	$GUI/Win/Restart.disabled = true
	tile_map.levelNum = 0
	score = 0
	tile_map.build_level()
	tile_map.gameOver = false
	place_player()
	set_audio(true)
	$GUI/Win.visible = false
	$GUI/Win/Restart.disabled = false

func get_loot_for_chest(floorLevel):
	loot_list.clear()
	# generate list of items
	var loot = Global.items.generate_loot(Global.current_level, Global.player)
	# Add to UI
	Global.populate_loot_list(loot_list, loot)
	#show Loot Screen
	$GUI/Loot.visible = true

func _on_LootAccept_pressed():
	$GUI/Loot.visible = false
	#allow player movement again
	player.set_can_move(true)
	#allow collision
	tile_map.chestIsOpen = false

func trigger_combat():
	Global.goto_scene(Global.Scene.COMBAT)	
