extends Node2D

var counter = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	counter += delta
	$CanvasLayer/Ticks.text = "Ticks: " + str(counter)
	
func _input(event):
	if !event.is_pressed():
		return
	if event.is_action("map_change_again"):
		Global.goto_scene(Global.Scene.OVERWORLD)
	
