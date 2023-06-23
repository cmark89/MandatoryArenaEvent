extends Node
class_name HealthVialDropComponent

@export var health_component: HealthComponent
@export var vial_scene: PackedScene

func _ready():
	health_component.died.connect(on_died)


func on_died(damage_source: DamageSource):
	if !MetaProgression.has_upgrade("health_vials"):
		return
	
	var drop_chance = 0.01 * MetaProgression.get_upgrade_quantity("health_vials")
		
	if randf() > drop_chance:
		return
		
	if vial_scene == null:
		return
	
	if not owner is Node2D:
		return
		
	var angle = deg_to_rad(randf_range(0, 360))
	var dist = 6
	var offset = Vector2(cos(angle), sin(angle)) * dist
	var spawn_position = (owner as Node2D).global_position + offset
	var vial_instance = vial_scene.instantiate() as Node2D
	get_tree().get_first_node_in_group("entities_layer").add_child(vial_instance)
	vial_instance.global_position = spawn_position
