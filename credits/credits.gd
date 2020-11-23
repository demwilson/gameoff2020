extends Node2D

var creditTitle = ["Game Design:", "Developers:", "Art Assets:", "Music:", "Sound Effects", " "]
var credits = [
	"Angel Gonzalez Alexander Wilson", 
	"Angel Gonalez Alexander Wilson Michael Marquez Raul Martinez",
	'Juan "Tony" Davila',
	"Ebrey Rojas",
	"Ebrey Rojas Alexander Wilson",
	"Developed with Godot Engine, https://godotengine.org/license"
	]

func _ready():
	credits()
	OS.set_window_size(Vector2(1280, 720))

func credits():
	for i in range(len(creditTitle)):
		print(i)
		$credits/creditstext/title.text = creditTitle[i]
		$credits/creditstext/contributers.text = credits[i]
		yield(get_tree().create_timer(2),"timeout")
	
	$credits/creditstext/title.visible = false
	$credits/creditstext/contributers.visible = false
	$credits/creditstext/thankyou.visible = true
	$credits/creditstext/retry.visible = true

func _on_retry_pressed():
	Global.goto_scene(Global.Scene.TITLE)
