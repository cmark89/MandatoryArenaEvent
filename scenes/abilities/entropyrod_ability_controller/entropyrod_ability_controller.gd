extends Node

@export var entropy_orb_ability_scene: PackedScene
var base_damage = 3
var bonus_damage = 0
const MAX_RANGE = 200
@onready var timer = $Timer
var base_time

var upgrade_damage_scalar = 1

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
		
	var enemies = get_tree().get_nodes_in_group("enemy")
	enemies = enemies.filter(func(enemy:Node2D):
		# Use squared distance because it's faster than using a square root function
		return enemy.global_position.distance_squared_to(player.global_position) <= pow(MAX_RANGE, 2)
	)
	if enemies.size() <= 0:
		return
	
	var target = enemies.pick_random()
	
	var orb_instance = entropy_orb_ability_scene.instantiate() as Node2D
	foreground.add_child(orb_instance)
	orb_instance.global_position = player.global_position
	orb_instance.hitbox_component.damage = (base_damage + bonus_damage)  * upgrade_damage_scalar
	orb_instance.hitbox_component.damage_source = DamageSource.new("entropyorb")
	orb_instance.set_direction((target.global_position - player.global_position).normalized())


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "entropyrod_damage":
		bonus_damage += 1
	elif upgrade.id == "entropyrod_rate":
		timer.stop()
		timer.wait_time = base_time * (1 - current_upgrades["entropyrod_rate"].quantity * .10)
		timer.start()
	elif upgrade.id == "valor":
		upgrade_damage_scalar += 0.10
