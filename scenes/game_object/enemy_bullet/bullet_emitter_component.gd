extends Node

@export var bullet_scene: PackedScene

func fire(direction: Vector2, speed: float, scale: float, damage: int, max_lifetime: float):
	var instance = bullet_scene.instantiate()
	var layer = get_tree().get_first_node_in_group("foreground_layer")
	layer.add_child(instance)
	instance.scale = Vector2(scale, scale)
	instance.global_position = owner.global_position
	instance.set_direction(direction)
	instance.set_speed(speed)
	instance.damage = damage
	instance.set_duration(max_lifetime)
	return instance
