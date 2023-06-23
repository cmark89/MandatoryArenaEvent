extends Node2D

@export var healing: int = 1
@onready var collision_shape_2d = $Area2D/CollisionShape2D
@onready var sprite = $Sprite2D
@onready var audio_stream_player_2d = $AudioStreamPlayer2D

func _ready():
	$Area2D.area_entered.connect(on_area_entered)


func on_area_entered(other_area: Area2D):
	Callable(disable_collision).call_deferred()
	
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_method(tween_collect.bind(global_position), 0.0, 1.0, 0.5)\
	.set_ease(Tween.EASE_IN)\
	.set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite, "scale", Vector2.ZERO, .05)\
	.set_delay(.45)
	tween.chain()
	tween.tween_callback(collect)
	
	audio_stream_player_2d.pitch_scale = randf_range(0.9, 1.3)
	audio_stream_player_2d.play()


func tween_collect(percent: float, start_position: Vector2):
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	global_position = start_position.lerp(player.global_position, percent)
	var direction_from_start = player.global_position - start_position
	
	var target_rotation = direction_from_start.angle() + deg_to_rad(90)
	rotation = lerp_angle(rotation, target_rotation, 1 - exp(-2 * get_process_delta_time()))
	

func collect():
	GameEvents.emit_healing_vial_collected(healing)
	queue_free()

func disable_collision():
	collision_shape_2d.disabled = true
