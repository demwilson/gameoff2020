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
	update_HUD_values()
	place_player()
	
func place_player():
	player.position = tile_map.playerStartPosition
	$PlayerRoot/Anchor.set_start_position(player.position)
	print("The player starts at: " + str(player.position))
	tile_map.isGeneratingNewLevel = false

func _process(delta):
	update_HUD_values()
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

func restart_overworld():
	set_audio(false)
	tile_map.levelNum = 0
	tile_map.isGeneratingNewLevel = true
	player.stepsTaken = 0
	player.generate_steps_to_trigger_combat()
	player.set_can_move(false)
	tile_map.build_level()
	player.set_can_move(true)
	tile_map.gameOver = false
	place_player()
	tile_map.isGeneratingNewLevel = false
	set_audio(true)

func _on_Restart_pressed():
	$GUI/Win/Restart.disabled = true
	tile_map.levelNum = 0
	player.set_can_move(true)
	tile_map.gameOver = false
	$GUI/Win.visible = false
	$GUI/Win/Restart.disabled = false
	Global.goto_scene(Global.Scene.GROUND_CONTROL)

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
	Global.player.add_combat_count(1)
	Global.goto_scene(Global.Scene.COMBAT)

func update_floor_level(value):
	Global.current_level = value

func update_HUD_values():
	var hud = $GUI/HUD
	var oxygenHudValue = $GUI/HUD/HBoxContainer/BarsLeft/OxygenBar/Oxygen/Background/Number
	var oxygenHudGauge = $GUI/HUD/HBoxContainer/BarsLeft/OxygenBar/Oxygen/Background/Gauge
	oxygenHudValue.text = str(Global.player.get_oxygen())
	oxygenHudGauge.value = int(Global.player.get_oxygen_percentage())
	var levelHudValue = $GUI/HUD/HBoxContainer/Currencys/PlayerInfoBar/PlayerInfo/Background/Level
	levelHudValue.text = "Level: " + str(Global.current_level)
	var healthHudValue = $GUI/HUD/HBoxContainer/Currencys/PlayerInfoBar/PlayerInfo/Background/Health
	healthHudValue.text = "Health: " + str(Global.player.get_health())
	var combatsHudValue = $GUI/HUD/HBoxContainer/Currencys/PlayerInfoBar/PlayerInfo/Background/Combats
	combatsHudValue.text = "Combats: " + str(Global.player.get_combat_count())
	var currencyHudValue = $GUI/HUD/HBoxContainer/Currencys/CurrencyBar/Currency/Background/Number
	currencyHudValue.text = str(Global.currency)

func lose_event():
	tile_map.gameOver = true
	$GUI/Lose.visible = true
	set_audio(false)

func _on_LoseRestart_pressed():
	$GUI/Lose/LoseRestart.disabled = true
	tile_map.levelNum = 0
	player.set_can_move(true)
	tile_map.gameOver = false
	$GUI/Lose.visible = false
	$GUI/Lose/LoseRestart.disabled = false
	#Send player to SAAN
	Global.goto_scene(Global.Scene.GROUND_CONTROL)
