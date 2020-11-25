extends Node2D

const PERSIST = true
const PLAYER_START_HP = 5
const FIRST_FLOOR = 1

var counter = 0

# node references
onready var tile_map = $TileMap
onready var player = $PlayerRoot/Player
onready var anchor = $PlayerRoot/Anchor
onready var debug_ui = $GUI/Debug
onready	var needKeyWindow = $GUI/NeedKey

var BossNode = preload("res://overworld/BossOverworld.tscn")
var BossNodeName = "Boss"
var BossInstance

var LootWindowNode = preload("res://loot_window/LootWindow.tscn")
var WinWindowNode = preload("res://win/Win.tscn")
var LoseWindowNode = preload("res://lose/Lose.tscn")
# game state
var player_tile
var score = 0
var boss
var currentAudioPosition = 0.0

func _ready():
	update_HUD_values()
	place_player()
	
func place_player():
	player.position = tile_map.playerStartPosition
	anchor.set_start_position(player.position)
	Global.log(Global.LogLevel.TRACE, "The player starts at: " + str(player.position))
	#used to prevent moving when going from level to level
	yield(get_tree().create_timer(0.3), 'timeout')
	tile_map.isGeneratingNewLevel = false

func place_boss():
	#set boss position from tileMap
	BossInstance = BossNode.instance()
	add_child(BossInstance)
	boss = BossInstance.get_node("Boss")
	boss.position = tile_map.bossStartPosition
	Global.log(Global.LogLevel.TRACE, "The Boss starts at: " + str(tile_map.bossStartPosition))

func set_boss_movement(active):
	boss.set_can_move(active)

func get_boss_node_name():
	return self.BossNodeName

func remove_boss():
	if BossInstance:
		BossInstance.queue_free()

func _process(delta):
	update_HUD_values()
	if Global.debug >= Global.LogLevel.INFO:
		debug_ui.visible = true
		var cpos = $TileMap.world_to_map(player.position)
		$GUI/Debug/TilePos.text = str(cpos)
		var mpos = $TileMap.world_to_map(get_global_mouse_position())
		$GUI/Debug/MousePos.text = str(mpos)
		counter += delta
		$GUI/Debug/Counter.text = "Counter: " + str(counter)
		$GUI/Debug/StepCount.text = "Steps Taken: " + str(player.stepsTaken)
		$GUI/Debug/StepToFight.text = "StepsToFight: " + str(player.stepsToTriggerCombat)

func _input(event):
	if !event.is_pressed():
		return
	elif event.is_action("stats_profile"):
		Global.goto_scene(Global.Scene.STATS)

func win_event():
	remove_boss()
	set_audio(false)
	load_win_window()
	
func set_audio(value):
	if value:
		player.get_node("AudioStreamPlayer").play(currentAudioPosition)
	else:
		player.get_node("AudioStreamPlayer").stop()
		currentAudioPosition = player.get_node("AudioStreamPlayer").get_playback_position()

func restart_overworld():
	set_audio(false)
	remove_boss()
	tile_map.levelNum = 0
	Global.floor_level = FIRST_FLOOR
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
	#show Loot Screen
	load_loot_window()

func load_loot_window():
	var lootInstance = LootWindowNode.instance()
	lootInstance._init(Global.Scene.OVERWORLD)
	add_child(lootInstance)
	lootInstance.connect("loot_window_closed", self, "_on_LootWindow_pressed")
	
func load_lose_window():
	var loseInstance = LoseWindowNode.instance()
	add_child(loseInstance)

func load_win_window():
	var winInstance = WinWindowNode.instance()
	add_child(winInstance)

func _on_LootWindow_pressed():
	#allow player movement again
	player.set_can_move(true)
	#allow collision
	tile_map.chestIsOpen = false

func trigger_combat():
	Global.player.add_combat_count(1)
	Global.goto_scene(Global.Scene.COMBAT)

func trigger_boss_combat():
	Global.boss_fight = true
	set_boss_movement(false)
	trigger_combat()
	remove_boss()
	Global.player.set_floor_key(true)
	tile_map.open_hatch()

func update_floor_level(value):
	Global.floor_level = value + 1

func update_HUD_values():
	var hud = $GUI/HUD
	var oxygenHudValue = $GUI/HUD/HUDSpacer/HBoxContainer/BarsLeft/OxygenBar/OxygenAmount/Number
	var oxygenHudGauge = $GUI/HUD/HUDSpacer/HBoxContainer/BarsLeft/OxygenBar/OxygenGauge/Gauge
	oxygenHudValue.text = str(Global.player.get_oxygen())
	oxygenHudGauge.value = int(Global.player.get_oxygen_percentage())
	var levelHudValue = $GUI/HUD/HUDSpacer/HBoxContainer/BarsMiddle/PlayerInfoBar/PlayerLevel/Level
	levelHudValue.text = "Level: " + str(Global.floor_level)
	var healthHudValue = $GUI/HUD/HUDSpacer/HBoxContainer/BarsMiddle/PlayerInfoBar/PlayerHealth/Health
	healthHudValue.text = "Health: " + str(Global.player.get_health())
	var combatsHudValue = $GUI/HUD/HUDSpacer/HBoxContainer/BarsMiddle/PlayerInfoBar/PlayerCombat/Combats
	combatsHudValue.text = "Combats: " + str(Global.player.get_combat_count())
	var currencyHudValue = $GUI/HUD/HUDSpacer/HBoxContainer/BarsRight/CurrencyBar/CurrencyAmount/Number
	currencyHudValue.text = str(Global.currency)

func lose_event():
	remove_boss()
	tile_map.gameOver = true
	set_audio(false)
	load_lose_window()

func set_ui_visible(show):
	$GUI/HUD.visible = show
	if Global.debug > Global.LogLevel.INFO:
		debug_ui.visible = show

func _on_LoseRestart_pressed():
	$GUI/Lose/LoseRestart.disabled = true
	tile_map.levelNum = 0
	player.set_can_move(true)
	tile_map.gameOver = false
	$GUI/Lose.visible = false
	$GUI/Lose/LoseRestart.disabled = false
	#Send player to SAAN
	Global.goto_scene(Global.Scene.GROUND_CONTROL)

func need_key_event():
	needKeyWindow.visible = true

func _on_NeedKeyAccept_pressed():
	needKeyWindow.visible = false
