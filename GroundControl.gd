extends Node2D

var o2_button = 0
var accuracy_button = 0
var attack_button = 0
var speed_button = 0
var defense_button = 0
var dodge_button = 0

func _ready():
	$CanvasLayer/Accuracy.visible = false
	$CanvasLayer/Speed.visible = false
	$CanvasLayer/Defense.visible = false
	$CanvasLayer/Attack.visible = false
	$CanvasLayer/Dodge.visible = false
	$CanvasLayer/o2_1.visible = false
	$CanvasLayer/o2_2.visible = false
	$CanvasLayer/as_1.visible = false
	$CanvasLayer/as_2.visible = false
	$CanvasLayer/defense_line.visible = false
	
func _on_O2_pressed():
	if o2_button < 1:
		o2_button += 1
		
	if o2_button == 1:
		$CanvasLayer/Accuracy.visible = true
		$CanvasLayer/Speed.visible = true
		$CanvasLayer/Defense.visible = true
		$CanvasLayer/o2_1.visible = true
		$CanvasLayer/o2_2.visible = true


func _on_Accuracy_pressed():
	if accuracy_button < 5:
		accuracy_button +=1
		$CanvasLayer/Accuracy/Label.text = str(accuracy_button) + "/5"
		
func _on_Speed_pressed():
	if speed_button < 5:
		speed_button +=1
		$CanvasLayer/Speed/Label.text = str(speed_button) + "/5"
		
	if speed_button == 5 && accuracy_button == 5:
		$CanvasLayer/Attack.visible = true
		$CanvasLayer/as_1.visible = true
		$CanvasLayer/as_2.visible = true
		
func _on_Defense_pressed():
	if defense_button < 5:
		defense_button +=1
		$CanvasLayer/Defense/Label.text = str(defense_button) + "/5"
	
	if defense_button == 5:
		$CanvasLayer/Dodge.visible = true
		$CanvasLayer/defense_line.visible = true


func _on_Dodge_pressed():
	if dodge_button < 5:
		dodge_button +=1
		$CanvasLayer/Dodge/Label.text = str(dodge_button) + "/5"
		
func _on_Attack_pressed():
	if attack_button < 5:
		attack_button +=1
		$CanvasLayer/Attack/Label.text = str(attack_button) + "/5"
