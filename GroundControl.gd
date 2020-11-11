extends Node2D

var oxygen_button = 0
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
	$CanvasLayer/TierConnector0_1.visible = false
	$CanvasLayer/TierConnector0_2.visible = false
	$CanvasLayer/TierConnector1_1.visible = false
	$CanvasLayer/TierConnector1_2.visible = false
	$CanvasLayer/TierConnector1_3.visible = false
	
func _on_Oxygen_pressed():
	if oxygen_button < 1:
		oxygen_button += 1
		
	if oxygen_button == 1:
		$CanvasLayer/Accuracy.visible = true
		$CanvasLayer/Speed.visible = true
		$CanvasLayer/Defense.visible = true
		$CanvasLayer/TierConnector0_1.visible = true
		$CanvasLayer/TierConnector0_2.visible = true


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
		$CanvasLayer/TierConnector1_1.visible = true
		$CanvasLayer/TierConnector1_2.visible = true
		
func _on_Defense_pressed():
	if defense_button < 5:
		defense_button +=1
		$CanvasLayer/Defense/Label.text = str(defense_button) + "/5"
	
	if defense_button == 5:
		$CanvasLayer/Dodge.visible = true
		$CanvasLayer/TierConnector1_3.visible = true


func _on_Dodge_pressed():
	if dodge_button < 5:
		dodge_button +=1
		$CanvasLayer/Dodge/Label.text = str(dodge_button) + "/5"
		
func _on_Attack_pressed():
	if attack_button < 5:
		attack_button +=1
		$CanvasLayer/Attack/Label.text = str(attack_button) + "/5"



