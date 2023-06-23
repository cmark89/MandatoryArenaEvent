extends Node2D

@onready var hitbox_animator = $HitboxAnimator
@onready var orb_animator = $OrbAnimator
@onready var timer = $Timer
@onready var hitbox_component = $HitboxComponent


const SPEED = 50
var direction

func _ready():
	timer.timeout.connect(on_timer_timeout)
	
func _process(delta):
	global_position += direction * SPEED * delta

func set_duration(seconds: float):
	timer.wait_time = seconds
	timer.start()

func on_timer_timeout():
	hitbox_animator.stop()
	orb_animator.play("die")

func set_direction(dir: Vector2):
	self.direction = dir
