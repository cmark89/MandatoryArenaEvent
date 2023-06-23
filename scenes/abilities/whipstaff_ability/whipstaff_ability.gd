extends Node2D

@onready var timer = $Timer
@onready var hitbox_component = $WhipstaffProjectile/HitboxComponent
@onready var animation_player = $AnimationPlayer

var hits_left = 1

var speed
var direction

func _ready():
	hitbox_component.callback = Callable(self, "on_collision")
	timer.timeout.connect(Callable(self, "queue_free"))
	
func _process(delta):
	global_position += direction * speed * delta

func on_timer_timeout():
	queue_free()

func set_direction(dir: Vector2):
	self.direction = dir
	rotation = dir.angle() + deg_to_rad(90)

func set_speed(new_speed: float):
	speed = new_speed

func on_collision():
	
	hits_left -= 1
	if hits_left <= 0:
		animation_player.play("destroy")
