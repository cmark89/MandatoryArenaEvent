extends Node2D

@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer
@onready var trigger_area = $TriggerArea
@onready var collision_shape_2d = $HitboxComponent/CollisionShape2D
@onready var hitbox_component = $HitboxComponent

var explosion_delay: float
var triggered = false

func _ready():
	timer.timeout.connect(play_fade_out)
	trigger_area.body_entered.connect(on_enemy_entered)
	
func set_radius(radius: float):
	collision_shape_2d.shape.radius = radius

func set_delay(time: float):
	explosion_delay = time


func play_fade_out():
	animation_player.play("end")

func on_enemy_entered(other: Node2D):
	if triggered:
		return
	triggered = true
	timer.stop()
	if explosion_delay > 0:
		animation_player.play("trigger")
		await get_tree().create_timer(explosion_delay).timeout
	animation_player.play("explode")
