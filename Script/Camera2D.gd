extends Camera2D

@export var player_path: NodePath

@onready var player_node:CharacterBody2D = get_node(player_path)

func _physics_process(_delta):
	follow_player()
	pass

func follow_player():
	var player_position = Vector2.ZERO
	var tween = create_tween()
	
	player_position.x = floor(player_node.position.x / 128)
	player_position.y = floor(player_node.position.y / 128)
	
	tween.tween_property(self, "position", player_position * 128, 0.6)
	
