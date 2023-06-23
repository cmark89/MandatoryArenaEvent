extends Node2D

@onready var hitbox_component = $HitboxComponent
const MAX_RADIUS = 150

var initial_angle = 0
func _ready():
	initial_angle = randf_range(0, TAU)
	var tween = create_tween()
	tween.tween_method(tween_method, 0.0, 2.0, 3.0)
	tween.tween_callback(queue_free)
	

func tween_method(rotations: float):
	var percent = rotations / 2
	var current_radius = percent * MAX_RADIUS
	var current_direction = Vector2.RIGHT.rotated(initial_angle + (rotations * TAU))
	
	var root_position = Vector2.ZERO
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	root_position = player.global_position
	global_position = root_position + (current_direction * current_radius)
