extends CharacterBody2D

@export var SPEED = 100
@export var ACC = 10
@export var FRICTION = 20

@export var useable_power1 = false
@export var useable_power2 = false

@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

var max_jump = 1
var current_jump = 0

var active_bubble = false
var can_make_bubble = true

@export var current_checkinpoint:Area2D

var last_position:Vector2 = Vector2(63, -115)

@export var check1: NodePath
@export var check2: NodePath
@export var check3: NodePath

@onready var check1_node: Area2D = get_node(check1)
@onready var check2_node: Area2D = get_node(check2)
@onready var check3_node: Area2D = get_node(check3)

var jump_effect = preload("res://PackedScene/jump_effect.tscn")
var fall_effect = preload("res://PackedScene/fall_effect.tscn")
@export var control_path: NodePath
@onready var control_node: Control = get_node(control_path)

var ready_active_1 = false
var ready_active_2 = false

var end_game = false


func _physics_process(delta):
	if end_game == false:
		update_powers()
		if !active_bubble:
			velocity.y += get_gravity() * delta
		var input_dir: Vector2 = input()
		
		if input_dir != Vector2.ZERO:
			accelerate(input_dir)
		else:
			add_friction()
			
		if is_on_floor():
			current_jump = 0
		
		if Input.is_action_just_pressed("ui_jump") and !active_bubble:
			if current_jump < max_jump:
				current_jump += 1
				jump()
		
		player_movement()
		control_animation()
	
func update_powers():
	if useable_power1:
		max_jump = 2
		#active tutorial 1
		if ready_active_1 == false:
			print("Power 1")
			control_node.get_node("AnimationPlayer").play("Power1")
			#play_PowerSound()
			ready_active_1 = true
		
	if useable_power2:
		#active tutorial 2
		if ready_active_2 == false:
			control_node.get_node("AnimationPlayer").play("Power2")
			print("Teste")
			ready_active_2 = true
		
		if Input.is_action_just_pressed("ui_accept") and can_make_bubble:
			if active_bubble == true:
				active_bubble = false
				play_ExplodeBubbleSound()
				$AudioControl/Bubble.stop()
				$ReturnBubbleTIme.start()
				$BubbleTime.stop()
			else:
				active_bubble = true
				play_BubbleSound()
				$BubbleTime.start()
			
func control_animation():
	if active_bubble == true:
		$AnimationPlayer.play("bubble")
	else:
		if velocity == Vector2.ZERO:
			$AnimationPlayer.play("Idle")
		elif velocity.y != 0:
			if velocity.y < 0:
				if current_jump == 1:
					$AnimationPlayer.play("SingleJump")
				elif current_jump == 2:
					$AnimationPlayer.play("DoubleJump")
			else:
				$AnimationPlayer.play("Fall")
		elif velocity.x != 0:
			$AnimationPlayer.play("Run")
	pass
	
func input() -> Vector2:
	var input_dir = Vector2.ZERO
	
	
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	if active_bubble:
		input_dir.y = Input.get_axis("ui_up", "ui_down")
	input_dir = input_dir.normalized()
	return input_dir
	
func accelerate(direction):
	velocity.x = velocity.move_toward(SPEED * direction, ACC).x
	if active_bubble:
		velocity.y = velocity.move_toward(SPEED * direction, ACC).y
	pass
	
func add_friction():
	velocity.x = velocity.move_toward(Vector2.ZERO, FRICTION).x
	if active_bubble:
		velocity.y = velocity.move_toward(Vector2.ZERO, FRICTION).y
	pass
	
func player_movement():
	if velocity.x > 0:
		$Sprite2D.flip_h = false
	elif velocity.x < 0:
		$Sprite2D.flip_h = true
	
	move_and_slide()
	
func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity
	
func jump():
	velocity.y = jump_velocity
	
	if current_jump == 1:
		var effect = jump_effect.instantiate()
		effect.global_position = $Marker2D.global_position
		get_parent().add_child(effect)
	play_JumpSound()
	
	
func returnToCheckpoint():
	global_position = last_position
	active_bubble = false
	$ReturnBubbleTIme.stop()
	can_make_bubble = true
	print("CheckPoint")
	pass
	
func _on_hitbox_body_entered(body):
	if body.is_in_group("Tilemap") or body.is_in_group("FallPlatform"):
		var effect = fall_effect.instantiate()
		effect.global_position = $Marker2D2.global_position
		get_parent().add_child(effect)
		play_fallSound()
	pass # Replace with function body.

func _on_hitbox_body_exited(body):
	pass # Replace with function body.

func _on_hitbox_area_entered(area):
	if area.is_in_group("Spike"):
		play_DeathSound()
		returnToCheckpoint()
	elif area.is_in_group("Power"):
		useable_power1 = true
		if area.has_method("self_destroy"):
			area.self_destroy()
	elif area.is_in_group("Power2"):
		useable_power2 = true
		if area.has_method("self_destroy"):
			area.self_destroy()
	elif area.is_in_group("FinalPower"):
		area.get_node("AnimationPlayer").play("Collect")
		control_node.get_node("Transition/ColorRect/Animation").play("Transition")
	elif area.is_in_group("PlusBubble"):
		$BubbleTime.stop()
		if $BubbleTime.wait_time < 8:
			$BubbleTime.wait_time += 5
		$BubbleTime.start()
		area.get_node("AnimationPlayer").play("Collect")
	elif area.is_in_group("CheckPoint"):
		last_position = area.global_position
		current_checkinpoint = area
		if check1_node != area:
			check1_node.get_node("AnimationPlayer").play("idle")
		if check2_node != area:
			check1_node.get_node("AnimationPlayer").play("idle")
		if check3_node != area:
			check3_node.get_node("AnimationPlayer").play("idle")
		current_checkinpoint.get_node("AnimationPlayer").play("init_check")
	elif area.is_in_group("DeathArea"):
		play_DeathSound()
		returnToCheckpoint()

func _on_hitbox_area_exited(area):
	if area.is_in_group("Spike"):
		pass
		
	if area.is_in_group("Power"):
		pass
		
	if area.is_in_group("Power"):
		pass
		
	if area.is_in_group("Power2"):
		pass
		
	if area.is_in_group("FinalPower"):
		pass


func _on_bubble_time_timeout():
	can_make_bubble = false
	active_bubble = false
	$AudioControl/Bubble.stop()
	play_ExplodeBubbleSound()
	$BubbleTime.wait_time = 3
	$ReturnBubbleTIme.start()
	pass # Replace with function body.


func _on_return_bubble_t_ime_timeout():
	can_make_bubble = true
	pass # Replace with function body.

func play_footstepSound():
	$AudioControl/FootStep.pitch_scale = randf_range(.8, 1.2)
	$AudioControl/FootStep.play()
	
func play_fallSound():
	$AudioControl/Fall.pitch_scale = randf_range(.8, 1.2)
	$AudioControl/Fall.play()
	
func play_JumpSound():
	$AudioControl/Jump.pitch_scale = randf_range(.8, 1.2)
	$AudioControl/Jump.play()

func play_BubbleSound():
	$AudioControl/Bubble.pitch_scale = randf_range(.8, 1.2)
	$AudioControl/Bubble.play()

func play_ExplodeBubbleSound():
	$AudioControl/ExplodeBubble.pitch_scale = randf_range(.8, 1.2)
	$AudioControl/ExplodeBubble.play()
	
func play_DeathSound():
	$AudioControl/Death.pitch_scale = randf_range(.8, 1.2)
	$AudioControl/Death.play()


