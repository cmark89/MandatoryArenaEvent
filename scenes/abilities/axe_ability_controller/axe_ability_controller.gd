extends Node

@export var axe_ability_scene: PackedScene
var base_damage = 9
var bonus_damage = 0
var crit_chance = 0.0
var upgrade_damage_scalar = 1

var damage_sound = preload("res://assets/audio/hit_axe.wav")

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
	var foreground = get_tree().get_first_node_in_group("foreground_layer") as Node2D
	if foreground == null:
		return
	
	var axe_instance = axe_ability_scene.instantiate() as Node2D
	foreground.add_child(axe_instance)
	axe_instance.global_position = player.global_position
	axe_instance.hitbox_component.damage = (base_damage + bonus_damage) * upgrade_damage_scalar
	axe_instance.hitbox_component.crit_chance = crit_chance
	axe_instance.hitbox_component.crit_damage_multiplier = 2.0
	axe_instance.hitbox_component.damage_sound = damage_sound
	axe_instance.hitbox_component.damage_source = DamageSource.new("axe")


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "axe_damage":
		bonus_damage += 1
	elif upgrade.id == "axe_crit" || upgrade.id == "axe_crit_upgrade":
		crit_chance += 0.1
	elif upgrade.id == "valor":
		upgrade_damage_scalar += 0.10
