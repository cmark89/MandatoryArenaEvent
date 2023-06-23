extends Node

@export var butterflyknife_ability_scene: PackedScene

var base_damage = 15
var bonus_damage = 0
const MAX_RANGE = 275
var damage_sound = preload("res://assets/audio/hit_butterflyknife.wav")
var projectiles = 1
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
		
	var enemies = get_tree().get_nodes_in_group("enemy")
	enemies = enemies.filter(func(enemy:Node2D):
		# Use squared distance because it's faster than using a square root function
		return enemy.global_position.distance_squared_to(player.global_position) <= pow(MAX_RANGE, 2)
	).duplicate()
	
	var targets = []
	enemies.shuffle()
	for i in projectiles:
		targets.push_front(enemies.pop_at(0))
		
	for target in targets:
		if target != null:
			fire_butterfly(target)



func fire_butterfly(target):
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var foreground = get_tree().get_first_node_in_group("foreground_layer") as Node2D
	if foreground == null:
		return
	
	if target == null:
		return
	
	var butterflyknife_instance = butterflyknife_ability_scene.instantiate() as Node2D
	foreground.add_child(butterflyknife_instance)
	butterflyknife_instance.global_position = player.global_position
	butterflyknife_instance.hitbox_component.damage = (base_damage + bonus_damage) * upgrade_damage_scalar
	butterflyknife_instance.hitbox_component.damage_sound = damage_sound
	butterflyknife_instance.hitbox_component.damage_source = DamageSource.new("butterflyknife")
	butterflyknife_instance.set_target(target)
	butterflyknife_instance.lost_target.connect(on_butterflyknife_lost_target)
	butterflyknife_instance.hit_enemy.connect(on_butterflyknife_hit)


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


func on_butterflyknife_lost_target(butterfly: Node2D):
	var new_target = choose_initial_target(get_tree().get_first_node_in_group("player") as Node2D)
	
	if new_target == null:
		butterfly.fly_out()
	else:
		butterfly.set_target(new_target)


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "butterflyknife_damage":
		bonus_damage += 7
	elif upgrade.id == "butterflyknife_count":
		projectiles += 1
	elif upgrade.id == "valor":
		upgrade_damage_scalar += 0.10


func on_butterflyknife_hit(butterfly: Node2D):
	butterfly.fly_out()
