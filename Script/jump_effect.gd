extends Node2D

func _ready():
	$AnimationPlayer.play("normal")

func self_destroy():
	queue_free()
