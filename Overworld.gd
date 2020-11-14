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
	$CanvasLayer/Counter.text = "Counter: " + str(counter)
#	#uncomment these lines to have player pos and mouse pos appear on canvas for testing
	if Settings.debug:
		$CanvasLayer/TilePos.visible = true
		$CanvasLayer/MousePos.visible = true
		var cpos = $TileMap.world_to_map($Player.position)
		$CanvasLayer/TilePos.text = str(cpos)
		var mpos = $TileMap.world_to_map(get_global_mouse_position())
		$CanvasLayer/MousePos.text = str(mpos)

func _input(event):
	if !event.is_pressed():
		return
	elif event.is_action("map_change"):
		Global.goto_scene(Global.Scene.COMBAT)

func win_event():
	player.get_node("AudioStreamPlayer2D").stream_paused = true
	$CanvasLayer/Win.visible = true
	
func toggle_audio():
	if player.get_node("AudioStreamPlayer2D").stream_paused:
		player.get_node("AudioStreamPlayer2D").stream_paused = false
	else:
		player.get_node("AudioStreamPlayer2D").stream_paused = true

func _on_Restart_pressed():
	$CanvasLayer/Win/Restart.disabled = true
	tile_map.levelNum = 0
	score = 0
	tile_map.build_level()
	tile_map.gameOver = false
	place_player()
	player.get_node("AudioStreamPlayer2D").stream_paused = false
	$CanvasLayer/Win.visible = false
	$CanvasLayer/Win/Restart.disabled = false
