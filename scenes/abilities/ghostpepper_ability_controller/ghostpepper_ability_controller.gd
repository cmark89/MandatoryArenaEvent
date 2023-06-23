extends Node

@export var ghostpepper_ability: PackedScene

var base_damage = 30
var bonus_damage = 0
var base_delay = 0
var bonus_delay = 0
const MAX_RANGE = 150

var upgrade_damage_scalar = 1

func _ready():
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	$Timer.timeout.connect(on_timer_timeout)
	var upgrades = get_tree().get_first_node_in_group("upgrade_manager").get_current_upgrades()
	if upgrades.has("valor"):
		for i in upgrades["valor"]["quantity"]:
			upgrade_damage_scalar += 0.10

func on_timer_timeout():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if (player == null):
		return
	
	var ghost_instance = ghostpepper_ability.instantiate()
	get_tree().get_first_node_in_group("entities_layer").add_child(ghost_instance)
	ghost_instance.set_delay(base_delay + bonus_delay)
	ghost_instance.hitbox_component.damage = (base_damage + bonus_damage)  * upgrade_damage_scalar
	ghost_instance.hitbox_component.damage_source = DamageSource.new("ghostpepper")
	ghost_instance.global_position = player.global_position


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "ghostpepper_damage":
		bonus_damage += 4
	elif upgrade.id == "ghostpepper_delay":
		bonus_delay += 0.3
	elif upgrade.id == "valor":
		upgrade_damage_scalar += 0.10
