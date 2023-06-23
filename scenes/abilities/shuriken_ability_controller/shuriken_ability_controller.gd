extends Node

@export var shuriken_ability_scene: PackedScene
var base_damage = 5
var projectiles = 1
var bounces = 2

const MAX_RANGE = 275
const MAX_BOUNCE_RANGE = 75

var damage_sound = preload("res://assets/audio/hit_shuriken.wav")
var upgrade_damage_scalar = 1

func _ready():
	$Timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	var upgrades = get_tree().get_first_node_in_group("upgrade_manager").get_current_upgrades()
	if upgrades.has("valor"):
		for i in upgrades["valor"]["quantity"]:
			upgrade_damage_scalar += 0.10

func on_timer_timeout():
	for i in projectiles:
		fire_shuriken()
		await get_tree().create_timer(0.1).timeout



func fire_shuriken():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var foreground = get_tree().get_first_node_in_group("foreground_layer") as Node2D
	if foreground == null:
		return
	
	var initial_target = choose_initial_target(player)
	if initial_target == null:
		return
	
	var shuriken_instance = shuriken_ability_scene.instantiate() as Node2D
	foreground.add_child(shuriken_instance)
	shuriken_instance.global_position = player.global_position
	shuriken_instance.hitbox_component.damage = base_damage * upgrade_damage_scalar
	shuriken_instance.hitbox_component.damage_sound = damage_sound
	shuriken_instance.hitbox_component.damage_source = DamageSource.new("shuriken")
	shuriken_instance.set_target(initial_target)
	shuriken_instance.bounces_left = bounces
	shuriken_instance.hit_enemy.connect(on_shuriken_hit)
	shuriken_instance.lost_target.connect(on_shuriken_lost_target)


func choose_initial_target(player: Node2D):
	var enemies = get_tree().get_nodes_in_group("enemy")
	enemies = enemies.filter(func(enemy:Node2D):
		# Use squared distance because it's faster than using a square root function
		return enemy.global_position.distance_squared_to(player.global_position) <= pow(MAX_RANGE, 2)
	)
	if enemies.size() > 0:
		return enemies.pick_random()
	else:
		return null


func choose_bounce_target(shuriken: Node2D):
	var enemies = get_tree().get_nodes_in_group("enemy")
	enemies = enemies.filter(func(enemy:Node2D):
		# Use squared distance because it's faster than using a square root function
		var distance = enemy.global_position.distance_squared_to(shuriken.global_position)
		return enemy != shuriken.target && distance <= pow(MAX_BOUNCE_RANGE, 2)
	)
	if enemies.size() <= 0:
		return null
	return enemies.pick_random()


func on_shuriken_hit(shuriken: Node2D):
	shuriken.bounces_left -= 1
	if shuriken.bounces_left < 0:
		await get_tree().create_timer(0.05).timeout
		shuriken.queue_free()
	else:
		var new_target = choose_bounce_target(shuriken)
		if new_target != null:
			shuriken.set_next_target(new_target)

func on_shuriken_lost_target(shuriken: Node2D):
	var new_target = choose_bounce_target(shuriken)
	if new_target == null:
		shuriken.fade_out()
	else:
		shuriken.target = new_target


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "shuriken_bounces":
		bounces += 1
	if upgrade.id == "shuriken_count":
		projectiles += 1
	elif upgrade.id == "valor":
		upgrade_damage_scalar += 0.10
