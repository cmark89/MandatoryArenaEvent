extends Node

const BASE_RANGE = 200
const BASE_DAMAGE = 20

@export var hammer_ability_scene: PackedScene
var damage_sound = preload("res://assets/audio/hit_hammer.ogg")
var hammer_count = 1
var multi_hammer_delay = 0.15

var upgrade_damage_scalar = 1

func _ready():
	$Timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	var upgrades = get_tree().get_first_node_in_group("upgrade_manager").get_current_upgrades()
	if upgrades.has("valor"):
		for i in upgrades["valor"]["quantity"]:
			upgrade_damage_scalar += 0.10

func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
		
	for i in hammer_count:
		var direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
		var spawn_position = player.global_position + (direction * randf() * BASE_RANGE)
		
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position, 1 << 0)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		if !result.is_empty():
			spawn_position = result["position"]
		
		var hammer_ability_instance = hammer_ability_scene.instantiate()
		get_tree().get_first_node_in_group("foreground_layer").add_child(hammer_ability_instance)
		hammer_ability_instance.global_position = spawn_position
		hammer_ability_instance.hitbox_component.damage = BASE_DAMAGE * upgrade_damage_scalar
		hammer_ability_instance.hitbox_component.damage_sound = damage_sound
		hammer_ability_instance.hitbox_component.damage_source = DamageSource.new("hammer")
		if hammer_count > 1:
			await get_tree().create_timer(multi_hammer_delay).timeout


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "hammer_rate":
		$Timer.wait_time -= 0.5
		$Timer.start()
	elif upgrade.id == "hammer_count":
		hammer_count += 1
	elif upgrade.id == "valor":
		upgrade_damage_scalar += 0.10
