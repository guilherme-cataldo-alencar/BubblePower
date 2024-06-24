extends StaticBody2D

var platformIsSolid = true

func _ready():
	$AnimationPlayer.play("Idle")

	
func state_in_idle():
	$AnimationPlayer.play("Idle")
	
func self_return():
	if !platformIsSolid:
		$AnimationPlayer.play("Return")
		platformIsSolid = true

func self_destroy():
	print("Teste")
	platformIsSolid = false
	$AnimationPlayer.play("Fall")
	$Return.start()
	$Timer.stop()
	pass

func _on_hitbox_area_entered(area):
	if area.is_in_group("Player"):
		$AnimationPlayer.play("Shake")
		$Timer.start()
	pass # Replace with function body.


func _on_hitbox_area_exited(area):
	if area.is_in_group("Player"):
		if platformIsSolid:
			$AnimationPlayer.play("Idle")
			$Timer.stop()
	pass # Replace with function body.


func _on_timer_timeout():
	self_destroy()


func _on_return_timeout():
	self_return()

func play_FallSound():
	$Fall.pitch_scale = randf_range(1.2, 1.5)
	$Fall.play()
	
func stop_FallSound():
	$Fall.pitch_scale = randf_range(1.2, 1.5)
	$Fall.stop()
