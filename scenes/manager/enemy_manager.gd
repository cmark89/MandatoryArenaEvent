extends Node

const SPAWN_RADIUS = 375

@onready var timer = $Timer

@export var end_screen_scene: PackedScene
@export var arena_time_manager: Node
var spawning = true

@export var basic_enemy_scene: PackedScene
@export var wizard_enemy_scene: PackedScene
@export var bat_enemy_scene: PackedScene
@export var ratfink_enemy_scene: PackedScene
@export var gladiator_enemy_scene: PackedScene
@export var apprentice_enemy_scene: PackedScene
@export var chad_enemy_scene: PackedScene
@export var exhumed_enemy_scene: PackedScene
@export var spider_enemy_scene: PackedScene
@export var giant_enemy_scene: PackedScene
@export var ghost_enemy_scene: PackedScene

@export var boss_crab_scene: PackedScene
@export var boss_chad_scene: PackedScene
@export var boss_executioner_scene: PackedScene
@export var boss_gareth_scene: PackedScene

@export var executed_enemy_scene: PackedScene

var base_spawn_time = 0
var enemy_table: WeightedTable = WeightedTable.new()
var difficulty = "NORMAL"

var spawns_per_tick = 1
@onready var audio_stream_player = $AudioStreamPlayer

func _ready():
	base_spawn_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)
	enemy_table.add_item(basic_enemy_scene, 10)
	GameEvents.spawn_lesser_chads.connect(on_spawn_lesser_chads)
	GameEvents.spawn_gladiators.connect(on_spawn_gladiators)
	GameEvents.spawn_executed.connect(on_spawn_executed)
	GameEvents.spawn_ghosts.connect(on_spawn_ghosts)


func on_timer_timeout():
	timer.start()
	if spawning:
		for i in spawns_per_tick:
			var enemy = enemy_table.pick_item() as PackedScene
			if enemy == null:
				break
			var position = get_spawn_position()
			spawn_enemy(enemy, position)


func get_spawn_position():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	var spawn_position = Vector2.ZERO
	if player == null:
		return spawn_position
	
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	for i in 4:
		spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
		var additional_check_offset = random_direction * 20
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position + additional_check_offset, 1 << 0)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		
		if result.is_empty():
			# Ray doesn't intersect terrain
			break
		else:
			random_direction = random_direction.rotated(deg_to_rad(90))
	
	return spawn_position


func on_arena_difficulty_increased(arena_difficulty: int):
	if arena_difficulty == 1:
		if difficulty == "MANIAC":
			spawns_per_tick = 2
			enemy_table.add_item(ratfink_enemy_scene, 4)
			for i in 3:
				spawn_enemy(ratfink_enemy_scene, get_spawn_position())
			for i in 20:
				spawn_enemy(basic_enemy_scene, get_spawn_position())
		elif difficulty == "NIGHTMARE":
			spawns_per_tick = 3
			enemy_table.add_item(wizard_enemy_scene, 10)
			for i in 2:
				spawn_enemy(apprentice_enemy_scene, get_spawn_position())
			for i in 20:
				spawn_enemy(wizard_enemy_scene, get_spawn_position())
	if arena_difficulty == 6:		# 30 seconds
		if difficulty != "NIGHTMARE":
			enemy_table.add_item(wizard_enemy_scene, 5)
	if arena_difficulty == 12:		# 60 seconds
		enemy_table.remove_item(basic_enemy_scene)
	if arena_difficulty == 18:	# 1:30
		#Spawn a swarm of basic rats 
		if difficulty == "MANIAC":
			for i in 15:
				spawn_enemy(wizard_enemy_scene, get_spawn_position())
			for i in 15:
				spawn_enemy(bat_enemy_scene, get_spawn_position())
		elif difficulty == "NIGHTMARE":
			for i in 15:
				spawn_enemy(ghost_enemy_scene, get_spawn_position())
		else:
			for i in 100:
				spawn_enemy(basic_enemy_scene, get_spawn_position())
	if arena_difficulty == 21:	# 1:45
		timer.wait_time = 0.5
		enemy_table.add_item(bat_enemy_scene, 5)
	if arena_difficulty == 24:	# 2:00
		enemy_table.remove_item(wizard_enemy_scene)
		for i in 10:
			spawn_enemy(bat_enemy_scene, get_spawn_position())
	if arena_difficulty == 25:	# 2:05
		for i in 10:
			spawn_enemy(bat_enemy_scene, get_spawn_position())
	if arena_difficulty == 26:	# 2:10
		for i in 10:
			spawn_enemy(bat_enemy_scene, get_spawn_position())
	if arena_difficulty == 27:	# 2:15
		for i in 10:
			spawn_enemy(bat_enemy_scene, get_spawn_position())
	if arena_difficulty == 28:	# 2:20
		for i in 10:
			spawn_enemy(bat_enemy_scene, get_spawn_position())
	if arena_difficulty == 30:	# 2:30
		enemy_table.add_item(ratfink_enemy_scene, 3)
	if arena_difficulty == 36:	# 3:00
		# Begin ratfink / vermin swarm-in!
		enemy_table.remove_item(ratfink_enemy_scene)
		enemy_table.remove_item(bat_enemy_scene)
		enemy_table.add_item(basic_enemy_scene, 1)
		timer.stop()
		timer.wait_time = 0.1
		timer.start()
		for i in 5:
			spawn_enemy(ratfink_enemy_scene, get_spawn_position())
	if arena_difficulty == 37:	# 3:05
		for i in 5:
			spawn_enemy(ratfink_enemy_scene, get_spawn_position())
	if arena_difficulty == 38:	# 3:10
		for i in 10:
			spawn_enemy(ratfink_enemy_scene, get_spawn_position())
	if arena_difficulty == 39:	# 3:15
		for i in 15:
			spawn_enemy(ratfink_enemy_scene, get_spawn_position())
	if arena_difficulty == 40:	# 3:20
		for i in 10:
			spawn_enemy(ratfink_enemy_scene, get_spawn_position())
		enemy_table.add_item(ratfink_enemy_scene, 8)
		enemy_table.add_item(bat_enemy_scene, 8)
		timer.stop()
		timer.wait_time = 1
		timer.start()
	if arena_difficulty == 42:	# 3:30
		enemy_table.remove_item(basic_enemy_scene)
		enemy_table.remove_item(ratfink_enemy_scene)
		enemy_table.remove_item(bat_enemy_scene)
		enemy_table.add_item(gladiator_enemy_scene, 10)
	if arena_difficulty == 48:	# 4:00
		spawns_per_tick += 2
	if arena_difficulty == 54:	# 4:30
		var apprentices = 2
		if difficulty == "MANIAC":
			apprentices = 3
		elif difficulty == "NIGHTMARE":
			apprentices = 4
		for i in apprentices:
			spawn_enemy(apprentice_enemy_scene, get_spawn_position())
		enemy_table.add_item(bat_enemy_scene, 5)
		spawns_per_tick -= 1
	if arena_difficulty == 60: # 5:00
		enemy_table.remove_item(bat_enemy_scene)
		enemy_table.add_item(chad_enemy_scene, 13)
		if difficulty == "MANIAC":
			for i in 25:
				spawn_enemy(chad_enemy_scene, get_spawn_position())
		elif difficulty == "NIGHTMARE":
			for i in 25:
				spawn_enemy(ghost_enemy_scene, get_spawn_position())
	if arena_difficulty == 64: # 5:20
		for i in 30:
			spawn_enemy(gladiator_enemy_scene, get_spawn_position())
	if arena_difficulty == 65: # 5:25
		for i in 25:
			spawn_enemy(chad_enemy_scene, get_spawn_position())
	if arena_difficulty == 66: # 5:30
		var apprentices = 2
		if difficulty == "MANIAC":
			apprentices = 3
		elif difficulty == "NIGHTMARE":
			apprentices = 4
		for i in apprentices:
			spawn_enemy(apprentice_enemy_scene, get_spawn_position())
	if arena_difficulty == 72: # 6:00
		enemy_table.remove_item(chad_enemy_scene)
		enemy_table.remove_item(gladiator_enemy_scene)
		enemy_table.add_item(exhumed_enemy_scene, 5)
		timer.stop()
		timer.wait_time = 1
		timer.start()
		for i in 15:
			spawn_enemy(exhumed_enemy_scene, get_spawn_position())
	if arena_difficulty == 75: # 6:15
		for i in 20:
			spawn_enemy(exhumed_enemy_scene, get_spawn_position())
		spawns_per_tick += 1
	if arena_difficulty == 78: # 6:30
		for i in 25:
			spawn_enemy(exhumed_enemy_scene, get_spawn_position())
		spawns_per_tick += 1
	if arena_difficulty == 84: # 7:00
		for i in 35:
			spawn_enemy(exhumed_enemy_scene, get_spawn_position())
		spawns_per_tick -= 1
		for i in 2:
			spawn_enemy(apprentice_enemy_scene, get_spawn_position())
		enemy_table.add_item(chad_enemy_scene, 5)
		enemy_table.add_item(gladiator_enemy_scene, 5)
		enemy_table.add_item(spider_enemy_scene, 5)
	if arena_difficulty == 90: # 7:30
		spawns_per_tick += 1
		timer.stop()
		timer.wait_time = 0.7
		timer.start()
		enemy_table.remove_item(gladiator_enemy_scene)
		enemy_table.remove_item(chad_enemy_scene)
		enemy_table.remove_item(exhumed_enemy_scene)
	if arena_difficulty == 93: # 7:45
		for i in 50:
			spawn_enemy(spider_enemy_scene, get_spawn_position())
	if arena_difficulty == 96: #8:00
		for i in 4:
			spawn_enemy(apprentice_enemy_scene, get_spawn_position())
		for i in 25:
			spawn_enemy(spider_enemy_scene, get_spawn_position())
		spawns_per_tick -= 2
		enemy_table.add_item(giant_enemy_scene, 1)
	if arena_difficulty == 102: #8:30
		for i in 30:
			spawn_enemy(exhumed_enemy_scene, get_spawn_position())
		await get_tree().create_timer(3.5).timeout
		for i in 30:
			spawn_enemy(exhumed_enemy_scene, get_spawn_position())
		await get_tree().create_timer(3.5).timeout
		for i in 30:
			spawn_enemy(exhumed_enemy_scene, get_spawn_position())
	if arena_difficulty == 108: #9:00
		for i in 6:
			spawn_enemy(apprentice_enemy_scene, get_spawn_position())
		enemy_table.remove_item(apprentice_enemy_scene)
		enemy_table.remove_item(giant_enemy_scene)
		enemy_table.remove_item(chad_enemy_scene)
		enemy_table.remove_item(gladiator_enemy_scene)
		enemy_table.remove_item(spider_enemy_scene)
		spawns_per_tick += 1
		
		if difficulty == "NIGHTMARE":
			enemy_table.add_item(ghost_enemy_scene, 15)
			for i in 50:
				spawn_enemy(ghost_enemy_scene, get_spawn_position())
		enemy_table.add_item(basic_enemy_scene, 10)
		enemy_table.add_item(wizard_enemy_scene, 12)
		enemy_table.add_item(ratfink_enemy_scene, 12)
		enemy_table.add_item(bat_enemy_scene, 7)
		enemy_table.add_item(gladiator_enemy_scene, 15)
		enemy_table.add_item(chad_enemy_scene, 7)
		enemy_table.add_item(spider_enemy_scene, 8)
		enemy_table.add_item(exhumed_enemy_scene, 15)
		enemy_table.add_item(giant_enemy_scene, 3)
		enemy_table.add_item(apprentice_enemy_scene, 2)
	if arena_difficulty == 114: #9:30
		if difficulty == "NIGHTMARE":
			spawns_per_tick += 1
		else:
			spawns_per_tick += 2
		


func spawn_enemy(enemy: PackedScene, position: Vector2):
	var enemy_instance = enemy.instantiate() as Node2D
	enemy_instance.difficulty = difficulty
	get_tree().get_first_node_in_group("entities_layer").add_child(enemy_instance)
	enemy_instance.global_position = get_spawn_position()
	if !MetaProgression.has_bestiary_entry(enemy_instance.bestiary_entry_id):
		MetaProgression.add_bestiary_entry(enemy_instance.bestiary_entry_id)
	return enemy_instance


func spawn_final_boss():
	var boss_scene
	
	if difficulty == "NORMAL":
		boss_scene = boss_crab_scene
	elif difficulty == "MANIAC":
		boss_scene = boss_chad_scene
	if difficulty == "NIGHTMARE":
		if get_tree().get_first_node_in_group("main").true_final_boss_unlocked:
			boss_scene = boss_gareth_scene
		else:
			boss_scene = boss_executioner_scene
	
	spawning = false
	
	if boss_scene == boss_gareth_scene:
		MusicPlayer.stop_music(4.0)
		await get_tree().create_timer(7).timeout
		MusicPlayer.play_true_last_boss_theme()
	
	var boss_instance = spawn_enemy(boss_scene, get_spawn_position())
	boss_instance.set_death_callback(on_final_boss_killed.bind(boss_instance.boss_name))
	var boss_health_bar = get_tree().get_first_node_in_group("boss_health_bar")
	boss_health_bar.setup(boss_instance.health_component, boss_instance.boss_name)
	boss_health_bar.show_boss_health_bar()


func on_spawn_lesser_chads():
	for i in 20:
		spawn_enemy(chad_enemy_scene, get_spawn_position())

func on_spawn_gladiators():
	for i in 25:
		spawn_enemy(gladiator_enemy_scene, get_spawn_position())
		
func on_spawn_executed():
	for i in 25:
		spawn_enemy(executed_enemy_scene, get_spawn_position())


func on_spawn_ghosts():
	for i in 10:
		spawn_enemy(ghost_enemy_scene, get_spawn_position())

func on_final_boss_killed(damage_source: DamageSource, boss_name:String):
	# Victory!
	if boss_name == "DARK LORD GARETH":
		audio_stream_player.play()

	await get_tree().create_timer(2).timeout
	MetaProgression.save()
	
	if boss_name != "DARK LORD GARETH":
		var end_screen_instance = end_screen_scene.instantiate()
		add_child(end_screen_instance)
		end_screen_instance.set_victory()
	else:
		GameEvents.emit_true_last_boss_killed()
