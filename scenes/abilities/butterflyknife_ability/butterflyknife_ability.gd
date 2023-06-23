extends Node2D

signal hit_enemy(this_butterflyknife:Node2D)
signal lost_target(this_butterflyknife:Node2D)

@onready var hitbox_component = $HitboxComponent
@onready var collision_shape_2d = $HitboxComponent/CollisionShape2D
const TRIGGER_RANGE = 1
const PROJECTILE_SPEED = 100

var target: Node2D
var flying_out = false
var fly_out_angle: Vector2 = Vector2.ZERO
var fly_out_time = randf_range(0, 60.0)
var fly_out_sine_multiplier = 2.5 * (1 + randf())
const FLY_OUT_ARC = 25
@onready var knife = $Knife


func _ready():
	pass


func _process(delta):
	if flying_out:
		fly_out_time += delta
		var angle = fly_out_angle.rotated((deg_to_rad(FLY_OUT_ARC) * sin(fly_out_time * fly_out_sine_multiplier)))
		global_position += angle * PROJECTILE_SPEED * delta
		rotation = angle.angle() + deg_to_rad(90)
		return
		
	var dir_to_target: Vector2 = Vector2.ZERO
	if target == null:
		lost_target.emit(self)
	else:
		dir_to_target = (target.global_position - global_position).normalized()
	
	fly_out_angle = dir_to_target	
	global_position += dir_to_target * PROJECTILE_SPEED * delta
	rotation = dir_to_target.angle() + deg_to_rad(90)
	if (target != null && global_position.distance_to(target.global_position) <= TRIGGER_RANGE):
		hit_enemy.emit(self)


func fly_out():
	target = null
	collision_shape_2d.set_deferred("disabled", false)
	knife.visible = false
	flying_out = true
	await get_tree().create_timer(0.05).timeout
	collision_shape_2d.set_deferred("disabled", true)
	
	await get_tree().create_timer(10.00).timeout
	fade_out()


func set_target(new_target: Node2D):
	if new_target == null:
		return
	target = new_target
	return


func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.3)
	tween.tween_callback(queue_free)
