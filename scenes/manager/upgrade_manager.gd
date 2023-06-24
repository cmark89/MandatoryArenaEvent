extends Node

@export var experience_manager: Node
@export var upgrade_screen_scene: PackedScene

const MAX_WEAPONS = 3
var current_upgrades = {}
var upgrade_pool: WeightedTable = WeightedTable.new()
var weapons_picked = 0
var weapons_purged = false
var picked_ultimate_upgrades = []

var upgrade_player_speed = preload("res://resources/upgrades/player_speed.tres")
var upgrade_sword_rate = preload("res://resources/upgrades/sword_rate.tres")
var upgrade_sword_damage = preload("res://resources/upgrades/sword_damage.tres")
var upgrade_valor = preload("res://resources/upgrades/valor.tres")

var upgrade_axe = preload("res://resources/upgrades/axe.tres")
var upgrade_axe_damage = preload("res://resources/upgrades/axe_damage.tres")
var upgrade_axe_crit = preload("res://resources/upgrades/axe_crit.tres")
var upgrade_axe_increased_crit = preload("res://resources/upgrades/axe_crit_upgrade.tres")
var upgrade_hammer = preload("res://resources/upgrades/hammer.tres")
var upgrade_hammer_rate = preload("res://resources/upgrades/hammer_rate.tres")
var upgrade_hammer_count = preload("res://resources/upgrades/hammer_count.tres")
var upgrade_shuriken = preload("res://resources/upgrades/shuriken.tres")
var upgrade_shuriken_count = preload("res://resources/upgrades/shuriken_count.tres")
var upgrade_shuriken_bounces = preload("res://resources/upgrades/shuriken_bounces.tres")
var upgrade_butterflyknife = preload("res://resources/upgrades/butterflyknife.tres")
var upgrade_butterflyknife_count = preload("res://resources/upgrades/butterflyknife_count.tres")
var upgrade_butterflyknife_damage = preload("res://resources/upgrades/butterflyknife_damage.tres")
var upgrade_hourglass = preload("res://resources/upgrades/hourglass.tres")
var upgrade_hourglass_damage = preload("res://resources/upgrades/hourglass_damage.tres")
var upgrade_hourglass_range = preload("res://resources/upgrades/hourglass_range.tres")
var upgrade_ghostpepper = preload("res://resources/upgrades/ghostpepper.tres")
var upgrade_ghostpepper_damage = preload("res://resources/upgrades/ghostpepper_damage.tres")
var upgrade_ghostpepper_delay = preload("res://resources/upgrades/ghostpepper_delay.tres")
var upgrade_entropyrod = preload("res://resources/upgrades/entropyrod.tres")
var upgrade_entropyrod_damage = preload("res://resources/upgrades/entropyrod_damage.tres")
var upgrade_entropyrod_rate = preload("res://resources/upgrades/entropyrod_rate.tres")
var upgrade_whipstaff = preload("res://resources/upgrades/whipstaff.tres")
var upgrade_whipstaff_count = preload("res://resources/upgrades/whipstaff_count.tres")
var upgrade_whipstaff_damage = preload("res://resources/upgrades/whipstaff_damage.tres")
var upgrade_whipstaff_penetration = preload("res://resources/upgrades/whipstaff_penetration.tres")
var upgrade_whipstaff_targeting = preload("res://resources/upgrades/whipstaff_targeting.tres")
var book_of_epitaphs = preload("res://resources/upgrades/book_of_epitaphs.tres")

var upgrade_kingsbane = preload("res://resources/upgrades/sword_kingsbane.tres")


func _ready():
	upgrade_pool.add_item(upgrade_axe, 4)
	upgrade_pool.add_item(upgrade_hammer, 4)
	upgrade_pool.add_item(upgrade_shuriken, 4)
	upgrade_pool.add_item(upgrade_butterflyknife, 4)
	upgrade_pool.add_item(upgrade_hourglass, 4)
	upgrade_pool.add_item(upgrade_ghostpepper, 4)
	upgrade_pool.add_item(upgrade_entropyrod, 4)
	upgrade_pool.add_item(upgrade_whipstaff, 4)
	
	upgrade_pool.add_item(upgrade_sword_rate, 2)
	upgrade_pool.add_item(upgrade_sword_damage, 2)
	upgrade_pool.add_item(upgrade_player_speed, 2)
	upgrade_pool.add_item(upgrade_valor, 2)	
	
	if get_tree().get_first_node_in_group("main").difficulty == "NIGHTMARE" \
	&& MetaProgression.has_upgrade("book_epitaphs"):
		upgrade_pool.add_item(book_of_epitaphs, 2)
	experience_manager.leveled_up.connect(on_level_up)
	GameEvents.blood_orb_collected.connect(on_blood_orb_collected)


func on_upgrade_selected(ability_upgrade: AbilityUpgrade):
	apply_upgrade(ability_upgrade)


func apply_upgrade(upgrade: AbilityUpgrade):
	var has_upgrade = current_upgrades.has(upgrade.id)
	if !has_upgrade:
		current_upgrades[upgrade.id] = {
			"resource": upgrade,
			"quantity": 1
		}
	else:
		current_upgrades[upgrade.id]["quantity"] += 1
	
	if upgrade.max_quantity > 0:
		var current_quantity = current_upgrades[upgrade.id]["quantity"]
		if current_quantity >= upgrade.max_quantity:
			upgrade_pool.remove_item(upgrade)
	
	if upgrade is Ability:
		weapons_picked += 1

	update_upgrade_pool(upgrade)
	GameEvents.emit_ability_upgrade_added(upgrade, current_upgrades)


func pick_upgrades():
	var chosen_upgrades: Array[AbilityUpgrade] = []
	for i in 3:
		if upgrade_pool.items.size() == chosen_upgrades.size():
			break
		var chosen_upgrade = upgrade_pool.pick_item(chosen_upgrades) as AbilityUpgrade
		chosen_upgrades.append(chosen_upgrade)
				
	return chosen_upgrades


func pick_upgrades_excluding_new_weapons():
	var new_upgrade_pool = WeightedTable.new()
	for item in upgrade_pool.items:
		if not (item["item"] is Ability):
			new_upgrade_pool.add_item(item["item"], item["weight"])
			
	var chosen_upgrades: Array[AbilityUpgrade] = []
	for i in 3:
		if upgrade_pool.items.size() == chosen_upgrades.size():
			break
		var chosen_upgrade = new_upgrade_pool.pick_item(chosen_upgrades) as AbilityUpgrade
		chosen_upgrades.append(chosen_upgrade)
				
	return chosen_upgrades


func on_level_up(current_level: int):		
	var upgrade_screen_instance = upgrade_screen_scene.instantiate()
	add_child(upgrade_screen_instance)
	upgrade_screen_instance.reroll_selected.connect(on_reroll)
	var chosen_upgrades = pick_upgrades()
	upgrade_screen_instance.set_ability_upgrades(chosen_upgrades as Array[AbilityUpgrade])
	upgrade_screen_instance.upgrade_selected.connect(on_upgrade_selected)


func on_blood_orb_collected():
	var upgrade_screen_instance = upgrade_screen_scene.instantiate()
	add_child(upgrade_screen_instance)
	upgrade_screen_instance.audio_stream_player.volume_db = -80.0
	upgrade_screen_instance.reroll_selected.connect(on_reroll)
	var chosen_upgrades = pick_upgrades_excluding_new_weapons()
	upgrade_screen_instance.set_ability_upgrades(chosen_upgrades as Array[AbilityUpgrade])
	upgrade_screen_instance.upgrade_selected.connect(on_upgrade_selected)

func on_reroll(upgrade_screen_instance: Node):
	var chosen_upgrades = pick_upgrades()
	upgrade_screen_instance.set_ability_upgrades(chosen_upgrades as Array[AbilityUpgrade])


func update_upgrade_pool(chosen_upgrade: AbilityUpgrade):
	if weapons_picked >= MAX_WEAPONS && !weapons_purged:
		weapons_purged = true
		upgrade_pool.remove_item(upgrade_axe)
		upgrade_pool.remove_item(upgrade_hammer)
		upgrade_pool.remove_item(upgrade_shuriken)
		upgrade_pool.remove_item(upgrade_butterflyknife)
		upgrade_pool.remove_item(upgrade_hourglass)
		upgrade_pool.remove_item(upgrade_ghostpepper)
		upgrade_pool.remove_item(upgrade_entropyrod)
		upgrade_pool.remove_item(upgrade_whipstaff)
		
		
	if chosen_upgrade.id == upgrade_axe.id:
		upgrade_pool.add_item(upgrade_axe_damage, 5)
		upgrade_pool.add_item(upgrade_axe_crit, 5)
	elif chosen_upgrade.id == upgrade_axe_crit.id:
		upgrade_pool.add_item(upgrade_axe_increased_crit, 5)
	elif chosen_upgrade.id == upgrade_hammer.id:
		upgrade_pool.add_item(upgrade_hammer_rate, 5)
		upgrade_pool.add_item(upgrade_hammer_count, 5)
	elif chosen_upgrade.id == upgrade_shuriken.id:
		upgrade_pool.add_item(upgrade_shuriken_count, 5)
		upgrade_pool.add_item(upgrade_shuriken_bounces, 5)
	elif chosen_upgrade.id == upgrade_butterflyknife.id:
		upgrade_pool.add_item(upgrade_butterflyknife_count, 5)
		upgrade_pool.add_item(upgrade_butterflyknife_damage, 5)
	elif chosen_upgrade.id == upgrade_hourglass.id:
		upgrade_pool.add_item(upgrade_hourglass_damage, 5)
		upgrade_pool.add_item(upgrade_hourglass_range, 5)
	elif chosen_upgrade.id == upgrade_ghostpepper.id:
		upgrade_pool.add_item(upgrade_ghostpepper_damage, 5)
		upgrade_pool.add_item(upgrade_ghostpepper_delay, 5)
	elif chosen_upgrade.id == upgrade_entropyrod.id:
		upgrade_pool.add_item(upgrade_entropyrod_damage, 5)
		upgrade_pool.add_item(upgrade_entropyrod_rate, 5)
	elif chosen_upgrade.id == upgrade_whipstaff.id:
		upgrade_pool.add_item(upgrade_whipstaff_count, 5)
		upgrade_pool.add_item(upgrade_whipstaff_damage, 4)
		upgrade_pool.add_item(upgrade_whipstaff_penetration, 3)
		upgrade_pool.add_item(upgrade_whipstaff_targeting, 2)
		
	if chosen_upgrade.id == upgrade_sword_damage.id || chosen_upgrade.id == upgrade_sword_rate.id:
		if upgrade_maxed(upgrade_sword_damage) && upgrade_maxed(upgrade_sword_rate):
			upgrade_pool.add_item(upgrade_kingsbane, 10)


func get_maxed_out_weapons():
	var result = []
	if upgrade_maxed(upgrade_sword_damage) && upgrade_maxed(upgrade_sword_rate):
		result.push_back("sword")
	if upgrade_maxed(upgrade_axe_increased_crit) && upgrade_maxed(upgrade_axe_damage):
		result.push_back("axe")
	if upgrade_maxed(upgrade_hammer_count) && upgrade_maxed(upgrade_hammer_rate):
		result.push_back("hammer")
	if upgrade_maxed(upgrade_shuriken_bounces) && upgrade_maxed(upgrade_shuriken_count):
		result.push_back("shuriken")
	if upgrade_maxed(upgrade_butterflyknife_damage) && upgrade_maxed(upgrade_butterflyknife_count):
		result.push_back("butterflyknife")
	if upgrade_maxed(upgrade_hourglass_damage) && upgrade_maxed(upgrade_hourglass_range):
		result.push_back("hourglass")
	if upgrade_maxed(upgrade_ghostpepper_damage) && upgrade_maxed(upgrade_ghostpepper_delay):
		result.push_back("ghostpepper")
	if upgrade_maxed(upgrade_entropyrod_damage) && upgrade_maxed(upgrade_entropyrod_rate):
		result.push_back("entropyrod")
	if upgrade_maxed(upgrade_whipstaff_damage) && upgrade_maxed(upgrade_whipstaff_count)\
	&& upgrade_maxed(upgrade_whipstaff_penetration) && upgrade_maxed(upgrade_whipstaff_targeting):
		result.push_back("whipstaff")
	return result


func get_unupgraded_weapons():
	var result = []
	# start with sword
	if !current_upgrades.has(upgrade_sword_damage.id) && !current_upgrades.has(upgrade_sword_rate.id):
		result.push_back("sword")
	if current_upgrades.has(upgrade_axe):
		if !current_upgrades.has(upgrade_axe_damage.id) && !current_upgrades.has(upgrade_axe_crit.id):
			result.push_back("axe")
	if current_upgrades.has(upgrade_hammer):
		if !current_upgrades.has(upgrade_hammer_rate.id) && !current_upgrades.has(upgrade_hammer_count):
			result.push_back("hammer")
	if current_upgrades.has(upgrade_shuriken):
		if !current_upgrades.has(upgrade_shuriken_count.id) && !current_upgrades.has(upgrade_shuriken_bounces):
			result.push_back("shuriken")
	if current_upgrades.has(upgrade_butterflyknife):
		if !current_upgrades.has(upgrade_butterflyknife_count.id) && !current_upgrades.has(upgrade_butterflyknife_damage):
			result.push_back("butterflyknife")
	if current_upgrades.has(upgrade_hourglass):
		if !current_upgrades.has(upgrade_hourglass_damage.id) && !current_upgrades.has(upgrade_hourglass_range):
			result.push_back("hourglass")
	if current_upgrades.has(upgrade_ghostpepper):
		if !current_upgrades.has(upgrade_ghostpepper_damage.id) && !upgrade_ghostpepper_delay.has(upgrade_hourglass_range):
			result.push_back("ghostpepper")
	if current_upgrades.has(upgrade_entropyrod):
		if !current_upgrades.has(upgrade_entropyrod_damage.id) && !upgrade_ghostpepper_delay.has(upgrade_entropyrod_rate):
			result.push_back("entryoprod")
	if current_upgrades.has(upgrade_whipstaff):
		if !current_upgrades.has(upgrade_whipstaff_damage.id) && !current_upgrades.has(upgrade_whipstaff_count)\
		&& current_upgrades.has(upgrade_whipstaff_penetration.id) && !current_upgrades.has(upgrade_whipstaff_targeting):
			result.push_back("whipstaff")
	return result


func upgrade_maxed(upgrade: AbilityUpgrade):
	return current_upgrades.has(upgrade.id) && current_upgrades[upgrade.id]["quantity"] >= upgrade.max_quantity

func get_current_upgrades():
	return current_upgrades
