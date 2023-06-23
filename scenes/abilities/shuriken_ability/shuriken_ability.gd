extends Node2D

signal hit_enemy(this_shuriken:Node2D)
signal lost_target(this_shuriken:Node2D)

@onready var hitbox_component = $HitboxComponent
@onready var collision_shape_2d = $HitboxComponent/CollisionShape2D
const TRIGGER_RANGE = 5
const PROJECTILE_SPEED = 250
var target: Node2D
var bounces_left = 0
var target_last_position
var disposing = false

func _ready():
	pass
	

func _process(delta):
	if bounces_left < 0:
		return

	var dir_to_target
	if target == null:
		if not disposing:
			lost_target.emit(self)
		if target_last_position == null:
			# If the target is assigned but dies on the frame the shuriken spawns
			return
		dir_to_target = (target_last_position- global_position).normalized()
	else:
		target_last_position = target.global_position
		dir_to_target = (target.global_position - global_position).normalized()
		
	global_position += dir_to_target * PROJECTILE_SPEED * delta
	
	if (target != null && global_position.distance_to(target.global_position) <= TRIGGER_RANGE):
		collision_shape_2d.set_deferred("disabled", false)
		hit_enemy.emit(self)


func set_target(new_target: Node2D):
	target = new_target
	target_last_position = target.global_position


func set_next_target(new_target: Node2D):
	target = new_target
	await get_tree().create_timer(0.05).timeout
	collision_shape_2d.set_deferred("disabled", true)


func fade_out():
	disposing = true
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.3)
	tween.tween_callback(queue_free)
