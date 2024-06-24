extends Area2D

func end_init_check():
	$AnimationPlayer.play("check")
	
	
func play_DeathSound():
	$Check.pitch_scale = randf_range(.8, 1.2)
	$Check.play()

