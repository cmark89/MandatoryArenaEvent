extends Node

@export var end_screen_scene: PackedScene

var difficulty = "NORMAL"
@export var pause_menu: PackedScene
@export var ending_player_scene: PackedScene
var rerolls_left = 0
var emergency_heals_left = 0
var blood_orbs_consumed = 0
var true_final_boss_unlocked

func _ready():
	($%Player as Player).health_component.died.connect(on_player_died)
	%EnemyManager.difficulty = difficulty
	GameEvents.true_last_boss_killed.connect(on_true_last_boss_killed)
	if MetaProgression.has_upgrade("reroll"):
		rerolls_left = MetaProgression.get_upgrade_quantity("reroll")
		
	if MetaProgression.has_upgrade("emergency_healing"):
		emergency_heals_left = MetaProgression.get_upgrade_quantity("emergency_healing")
		
	var blood_orb_count = 0
	if MetaProgression.has_upgrade("blood_orbs"):
		blood_orb_count = MetaProgression.get_upgrade_quantity("blood_orbs")
	var blood_orbs = get_tree().get_nodes_in_group("blood_orbs")
	blood_orbs.shuffle()
	for i in (4-blood_orb_count):
		var orb = blood_orbs.pop_front()
		orb.queue_free()

	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	GameEvents.blood_orb_collected.connect(on_blood_orb_collected)


func on_true_last_boss_killed():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	MusicPlayer.stop_music(2.0)
	player.set_invincible()
	
	var ending_player = ending_player_scene.instantiate()
	
	await get_tree().create_timer(2.0).timeout
	
	# Add the new scene to the root 
	get_tree().get_root().add_child(ending_player)	
	ending_player.play_ending()

func on_player_died(damage_source: DamageSource):
	MetaProgression.save()
	var end_screen_instance = end_screen_scene.instantiate()
	add_child(end_screen_instance)
	end_screen_instance.set_defeat()

func on_blood_orb_collected():
	blood_orbs_consumed += 1


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		add_child(pause_menu.instantiate())
		get_tree().root.set_input_as_handled()

func on_ability_upgrade_added(ability_upgrade:AbilityUpgrade, current_upgrades: Dictionary):
	if ability_upgrade.id == "book_of_epitaphs":
		true_final_boss_unlocked = true
