extends Node2D

signal closed_scene

onready var return_button = $CanvasLayer/returnbutton

#Titles
var creditTitle = ["Game Design", "Developers", "Art Assets", "Audio Assets", "Story", " "]

#Contributer names
var credits = [
	"Angel Gonzalez\nAlexander Wilson", 
	"Angel Gonzalez\nMichael Marquez\nRaul Martinez\nAlexander Wilson",
	'Juan "Tony" Davila',
	"Ebrey Rojas",
	"Alexander Wilson",
	"Developed with:\nGodot v3.2.3"
	]

var from_title = false

func _ready():
	credits()
	if from_title:
		return_button.visible = true
	OS.set_window_size(Vector2(1280, 720))
	
func credits():
	for i in range(len(creditTitle)):
		$CanvasLayer/creditstext/title.text = creditTitle[i]
		$CanvasLayer/creditstext/contributers.text = credits[i]
		yield(get_tree().create_timer(5),"timeout")
	$CanvasLayer/creditstext/title.visible = false
	$CanvasLayer/creditstext/contributers.visible = false
	$CanvasLayer/creditstext/thankyou.visible = true
	$CanvasLayer/creditstext/retry.visible = true

func close_credits():
	if from_title:
		emit_signal("closed_scene")
		self.queue_free()
	else:
		Global.goto_scene(Global.Scene.TITLE)

func _on_retry_pressed():
	close_credits()

func _on_returnbutton_pressed():
	close_credits()
