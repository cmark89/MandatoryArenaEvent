extends Node

@export var whipstaff_bullet_ability_scene: PackedScene

var base_damage = 3
var bonus_damage = 0
const MAX_RANGE = 150

var projectiles = 10
var arc = 55.0
var total_delay = 0.75
var base_speed = 70
var speed_step = 25
var target_enemy = false
var maximum_hits = 1

var upgrade_damage_scalar = 1

@onready var timer = $Timer
var base_time
func _ready():
	base_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	var upgrades = get_tree().get_first_node_in_group("upgrade_manager").get_current_upgrades()
	if upgrades.has("valor"):
		for i in upgrades["valor"]["quantity"]:
			upgrade_damage_scalar += 0.10

func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var foreground = get_tree().get_first_node_in_group("foreground_layer") as Node2D
	if foreground == null:
		return
		
	var mean_angle = randf_range(0, 360)
	if target_enemy:
		var enemies = get_tree().get_nodes_in_group("enemy")
		enemies = enemies.filter(func(enemy:Node2D):
			# Use squared distance because it's faster than using a square root function
			return enemy.global_position.distance_squared_to(player.global_position) <= pow(MAX_RANGE, 2)
		)
		if enemies.size() > 0:
			var target = enemies.pick_random()
			mean_angle = rad_to_deg((target.global_position - player.global_position).normalized().angle())
	
	var _sign = -1 if randf() <= 0.5 else 1
	var start_angle = mean_angle - (_sign * arc / 2)
	var angle_step = _sign * arc / projectiles
	
	var delay = total_delay / projectiles
	for i in projectiles:
		var bullet_instance = whipstaff_bullet_ability_scene.instantiate() as Node2D
		foreground.add_child(bullet_instance)
		bullet_instance.global_position = player.global_position
		bullet_instance.hitbox_component.damage = (base_damage + bonus_damage) * upgrade_damage_scalar
		bullet_instance.hitbox_component.damage_source = DamageSource.new("whipstaff")
		var angle = deg_to_rad(start_angle + (angle_step * i))
		var angle_vector = Vector2(cos(angle), sin(angle))
		bullet_instance.set_direction(angle_vector)
		bullet_instance.set_speed(base_speed + speed_step * i)
		bullet_instance.hits_left = maximum_hits
		await get_tree().create_timer(delay).timeout


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "whipstaff_count":
		projectiles += 3
		arc += 5
	if upgrade.id == "whipstaff_damage":
		bonus_damage += 1
	if upgrade.id == "whipstaff_penetration":
		maximum_hits += 1
	if upgrade.id == "whipstaff_targeting":
		target_enemy = true
	elif upgrade.id == "valor":
		upgrade_damage_scalar += 0.10
