extends Control

@export var player_path:NodePath
@onready var player_node:CharacterBody2D = get_node(player_path)

var ready_play = false

func _process(_delta):
	var returnBubble = player_node.get_node("ReturnBubbleTIme")
	if player_node.useable_power2 == false:
		$ProgressBar.visible = false
		$TextureRect.visible = false
	else:
		if ready_play == false:
			print("Show")
			$ProgressBar/AnimationPll.play("Show")
			ready_play = true
	
	if player_node.active_bubble:
		$ProgressBar.fill_mode = 0
		$ProgressBar.max_value = player_node.get_node("BubbleTime").wait_time
		$ProgressBar.value = player_node.get_node("BubbleTime").time_left
	else:
		$ProgressBar.fill_mode = 0
		$ProgressBar.max_value = returnBubble.wait_time
		$ProgressBar.value =  returnBubble.wait_time - returnBubble.time_left
	pass
	


func _on_timer_1_timeout():
	$AnimationPlayer.play("EndPower1")


func _on_timer_timeout():
	$AnimationPlayer.play("EndPower2")

func play_winSound():
	$Transition/ColorRect/AudioStreamPlayer2D.play()
	
