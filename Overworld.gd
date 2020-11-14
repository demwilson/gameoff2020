extends Node2D

const PERSIST = true
const PLAYER_START_HP = 5

var counter = 0

# node references
onready var tile_map = $TileMap
onready var player = $Player

# game state
var player_tile
var score = 0

func _ready():
	place_player()
	
func place_player():
	player.position = tile_map.playerStartPosition
	print("The player starts at: " + str(player.position))
	tile_map.isGeneratingNewLevel = false

func _process(delta):
	counter += delta
	$GUI/Counter.text = "Counter: " + str(counter)
#	#uncomment these lines to have player pos and mouse pos appear on canvas for testing
	if Settings.debug:
		$GUI/TilePos.visible = true
		$GUI/MousePos.visible = true
		var cpos = $TileMap.world_to_map($Player.position)
		$GUI/TilePos.text = str(cpos)
		var mpos = $TileMap.world_to_map(get_global_mouse_position())
		$GUI/MousePos.text = str(mpos)

func _input(event):
	if !event.is_pressed():
		return
	elif event.is_action("map_change"):
		Global.goto_scene(Global.Scene.COMBAT)

func win_event():
	player.get_node("AudioStreamPlayer2D").stream_paused = true
	$GUI/Win.visible = true
	
func toggle_audio():
	if player.get_node("AudioStreamPlayer2D").stream_paused:
		player.get_node("AudioStreamPlayer2D").stream_paused = false
	else:
		player.get_node("AudioStreamPlayer2D").stream_paused = true

func _on_Restart_pressed():
	$GUI/Win/Restart.disabled = true
	tile_map.levelNum = 0
	score = 0
	tile_map.build_level()
	tile_map.gameOver = false
	place_player()
	player.get_node("AudioStreamPlayer2D").stream_paused = false
	$GUI/Win.visible = false
	$GUI/Win/Restart.disabled = false

func get_loot_for_chest(floorLevel):
	$GUI/Loot/LootList.clear()
	#TODO: call global to generate list of items
	print("Generating Loot")
	#loop through items and add them to LootList
	$GUI/Loot/LootList.add_item("Fancy Pointy Stick", null, false)
	$GUI/Loot/LootList.add_item("Greased Animal Hide", null, false)
	$GUI/Loot/LootList.add_item("Boots of Running Really Fast", null, false)
	#show Loot Screen
	$GUI/Loot.visible = true

func _on_LootAccept_pressed():
	$GUI/Loot.visible = false
	#allow player movement again
	player.set_can_move(true)
	#allow collision
	tile_map.chestIsOpen = false
