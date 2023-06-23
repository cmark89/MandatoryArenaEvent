extends Node

@export var sword_ability: PackedScene

var base_damage = 5
var bonus_damage = 0
var base_rate

var damage_sound = preload("res://assets/audio/hit_sword.wav")

const MAX_RANGE = 150


func _ready():
	base_rate = $Timer.wait_time
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	$Timer.timeout.connect(on_timer_timeout)


func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if (player == null):
		return
	
	var enemies = get_tree().get_nodes_in_group("enemy")
	enemies = enemies.filter(func(enemy:Node2D):
		# Use squared distance because it's faster than using a square root function
		return enemy.global_position.distance_squared_to(player.global_position) <= pow(MAX_RANGE, 2)
	)
			
	if (enemies.size() == 0):
		return
	
	enemies.sort_custom(func (a: Node2D, b: Node2D):
		# Return true if a is closer than b
		var a_distance = a.global_position.distance_squared_to(player.global_position)
		var b_distance = b.global_position.distance_squared_to(player.global_position)
		return a_distance < b_distance
	)
	var target = enemies[0]
	
	var sword_instance = sword_ability.instantiate() as SwordAbility
	get_tree().get_first_node_in_group("foreground_layer").add_child(sword_instance)
	sword_instance.hitbox_component.damage = base_damage + bonus_damage
	sword_instance.hitbox_component.damage_sound = damage_sound
	sword_instance.hitbox_component.damage_source = DamageSource.new("sword")

	var spawn_position = target.global_position + Vector2.RIGHT.rotated(randf_range(0, TAU)) * 4
	sword_instance.global_position = spawn_position
	
	var enemy_direction = target.global_position - sword_instance.global_position
	sword_instance.rotation = enemy_direction.angle()	# both in radians


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "sword_rate":
		var percent_reduction = current_upgrades["sword_rate"].quantity * 0.10
		$Timer.wait_time = base_rate * (1 - percent_reduction)
		$Timer.start()
	elif upgrade.id == "sword_damage":
		bonus_damage += 2
