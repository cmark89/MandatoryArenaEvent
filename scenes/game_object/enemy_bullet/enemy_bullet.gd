extends Node2D

var damage = 10
@onready var area_2d = $Area2D
@onready var timer = $Timer

var speed = 0
var direction: Vector2 = Vector2.ZERO

func _ready():
	area_2d.body_entered.connect(on_body_entered)
	timer.timeout.connect(queue_free)
	

func _process(delta):
	if speed > 0:
		global_position += direction * speed * delta
	
	
func on_body_entered(other: Node2D):
	other.self_damage(damage)
	queue_free()


func on_timer_timeout():
	queue_free()


func set_direction(dir: Vector2):
	direction = dir
	rotation = dir.angle() + deg_to_rad(90)


func set_speed(new_speed: float):
	speed = new_speed


func set_duration(duration: float):
	if duration < 0:
		timer.stop()
	else:
		timer.stop()
		timer.wait_time = duration
		timer.start()
