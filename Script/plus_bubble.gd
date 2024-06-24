extends Area2D

func self_return():
	$Sprite2D.visible = true
	$CollisionShape2D.disabled = false
	$AnimationPlayer.play("Idle")

func self_destroy():
	$Sprite2D.visible = false
	$CollisionShape2D.disabled = true
	$ReturnPlus.start()


func _on_return_plus_timeout():
	self_return()

func play_plusSound():
	$plusSound.pitch_scale = randf_range(1, 1.3)
	$plusSound.play()
