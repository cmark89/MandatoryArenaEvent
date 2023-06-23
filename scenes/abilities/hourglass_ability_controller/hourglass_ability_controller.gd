extends Node

@export var hourglass_ability_scene: PackedScene
const BASE_RANGE = 50
var base_damage = 4
var bonus_damage = 0
var bonus_range = 0

var damage_sound = preload("res://assets/audio/hit_axe.wav")
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
	var foreground = get_tree().get_first_node_in_group("midground_layer") as Node2D
	if foreground == null:
		return
	
	var hourglass_instance = hourglass_ability_scene.instantiate() as Node2D
	foreground.add_child(hourglass_instance)
	hourglass_instance.global_position = player.global_position
	hourglass_instance.hitbox_component.damage = (base_damage + bonus_damage)  * upgrade_damage_scalar
	hourglass_instance.hitbox_component.damage_source = DamageSource.new("hourglass")
	hourglass_instance.set_radius(BASE_RANGE + bonus_range)
	hourglass_instance.play()


func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "hourglass_damage":
		bonus_damage += 2
	if upgrade.id == "hourglass_range":
		bonus_range += 25
	elif upgrade.id == "valor":
		upgrade_damage_scalar += 0.10
