extends Node
class_name VialDropComponent

@export_range(0, 1) var drop_percent: float = .5
@export var health_component: HealthComponent
@export var vial_scene: PackedScene

func _ready():
	health_component.died.connect(on_died)


func on_died(damage_source: DamageSource):
	var adjusted_drop_percent = drop_percent
	if MetaProgression.has_upgrade("experience_gain"):
		adjusted_drop_percent += 0.05 * MetaProgression.get_upgrade_quantity("experience_gain")
		
	if randf() > adjusted_drop_percent:
		return
		
	if vial_scene == null:
		return
	
	if not owner is Node2D:
		return
		
	var spawn_position = (owner as Node2D).global_position
	var vial_instance = vial_scene.instantiate() as Node2D
	get_tree().get_first_node_in_group("entities_layer").add_child(vial_instance)
	vial_instance.global_position = spawn_position
