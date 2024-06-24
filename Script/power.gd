class_name Power
extends Area2D

func self_destroy():
	$AnimationPlayer.play("Collect")
	$PowerSound.play()

func self_destroy_master():
	queue_free()
