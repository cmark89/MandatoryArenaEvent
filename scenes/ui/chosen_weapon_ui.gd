extends CanvasLayer

@export var chosen_weapon_scene: PackedScene
@onready var h_box_container = $MarginContainer/HBoxContainer

var weapon_slots: Array[Node] = []
var equipped_weapons = 1
var epitaphs_slot: Node
func _ready():
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	for i in 4:
		var instance = chosen_weapon_scene.instantiate()
		weapon_slots.push_back(instance)
		h_box_container.add_child(instance)
		if i == 0:
			instance.set_weapon_texture(load("res://scenes/abilities/sword_ability/sword.png"))
	var instance = chosen_weapon_scene.instantiate()
	h_box_container.add_child(instance)
	instance.hide_frame()
	epitaphs_slot = instance

func on_ability_upgrade_added(upgrade:AbilityUpgrade, current_upgrades: Dictionary):
	if upgrade.id == "sword_kingsbane":
		weapon_slots[0].set_weapon_texture(upgrade.icon)
	elif upgrade is Ability:
		weapon_slots[equipped_weapons].set_weapon(upgrade)
		equipped_weapons += 1
	elif upgrade.id == "book_of_epitaphs":
		epitaphs_slot.set_weapon_texture(upgrade.icon)
