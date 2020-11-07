extends Node2D

const ACTION_AVAILABLE_TICKS = 5.0

var counter = 0
var enemy = {
	"health": 5,
	"timebar": 0,
	"speed": 1,
	"ready": false,
}
var ally = {
	"health": 5,
	"timebar": 0,
	"speed": 2,
	"ready": false,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	# generate ally UI content
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	counter += delta
	if enemy.timebar >= ACTION_AVAILABLE_TICKS:
		ally.health -= 1
		enemy.timebar = 0
	if ally.timebar >= ACTION_AVAILABLE_TICKS:
		enemy.health -= 1
		ally.timebar = 0
		
	enemy.timebar += enemy.speed * delta
	ally.timebar += ally.speed * delta
	
	# Update canvas
	$CanvasLayer/Ticks.text = "Ticks: " + str(counter)
	$CanvasLayer/EnemyActionBar.text = "Count: " + str(enemy.timebar)
	$CanvasLayer/AllyActionBar.text = "Count: " + str(ally.timebar)
	$CanvasLayer/EnemyHealth.text = "Health: " + str(enemy.health)
	$CanvasLayer/AllyHealth.text = "Health: " + str(ally.health)
	$CanvasLayer/EnemyProgressBar.value = enemy.timebar
	$CanvasLayer/AllyProgressBar.value = ally.timebar

func _input(event):
	if !event.is_pressed():
		return
	if event.is_action("map_change_again"):
		Global.goto_scene(Global.Scene.OVERWORLD)
