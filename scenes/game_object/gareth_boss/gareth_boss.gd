extends CharacterBody2D

@export var bestiary_entry_id: String
@export var damage = 2
@export var boss_name = "MAGICALLY EMBIGGENED CRAB"
@onready var visuals = $Visuals as Node2D
@onready var velocity_component = $VelocityComponent
@onready var enemy_sound_player_component = $EnemySoundPlayerComponent
@onready var health_component = $HealthComponent
@onready var bullet_emitter_component = $BulletEmitterComponent
@onready var animation_player = $AnimationPlayer
@onready var attack_timer = $AttackTimer
@onready var teleport_player_2d = $TeleportPlayer2D

@onready var knife_shot_player_2d = $KnifeShotPlayer2D
@onready var dash_player_2d = $DashPlayer2D

@onready var final_boss_audio_player = $FinalBossAudioPlayer


var axe_bullet_scene = preload("res://scenes/game_object/enemy_bullet/enemy_bullet.tscn")
var blood_orb_scene = preload("res://scenes/game_object/blood_orb/blood_orb.tscn")

var axe_traps = []
const PREPARE_AXES_CHANCE = 0.3
const DASH_CHANCE = 0.4


const ACTION_COUNTER_TRIGGER_MIN = 2
const ACTION_COUNTER_TRIGGER_MAX = 3
var action_counter = 0

const MAX_BUBBLE_STORM_RANGE: float = 350
const BUBBLE_STORM_DURATION: float = 7
const TOTAL_BUBBLES_TO_FIRE: int = 500
const BUBBLE_STORM_MIN_ARC: float = 15
const BUBBLE_STORM_MAX_ARC: float = 300
const BUBBLE_MIN_SPEED: float = 50
const BUBBLE_MAX_SPEED: float = 220
const MIN_DISTANCE_AFTER_TELEPORT = 40

const AXE_DAMAGE = 5
var difficulty
var can_act = true
var charging = false
var throwing_knives = false
var charge_direction
var used_blood_orbs = false
var played_low_health_audio = false
@export var current_charge_speed = 60

func _ready():
	$HurtboxComponent.hit.connect(on_hit)
	attack_timer.timeout.connect(on_attack_timer_timeout)
	final_boss_audio_player.play_spawn_audio()
	await get_tree().create_timer(5).timeout
	attack_timer.start()

func set_death_callback(callback):
	$HealthComponent.died.connect(callback)


func set_next_action_trigger():
	action_counter = randi_range(ACTION_COUNTER_TRIGGER_MIN, ACTION_COUNTER_TRIGGER_MAX)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !played_low_health_audio && health_component.current_health < health_component.max_health * 0.25:
		final_boss_audio_player.play_low_health_audio()
		played_low_health_audio = true
		
	if charging:
#		global_position += charge_direction * delta * current_charge_speed
		velocity = charge_direction * current_charge_speed
		move_and_slide()
		
	elif throwing_knives:
		velocity_component.decelerate()
		
	else:
		velocity_component.accelerate_to_player()
		velocity_component.move(self)

		var move_sign = -sign(velocity.x)
		if move_sign != 0:
			visuals.scale.x = -move_sign

func on_hit(audio_stream: AudioStream):
	enemy_sound_player_component.play_damage_sound(audio_stream)

func on_attack_timer_timeout():
	if !can_act:
		return
	action_counter -= 1
	if action_counter <= 0:
		var player = get_tree().get_first_node_in_group("player")
		if player == null:
			return
		set_next_action_trigger()
		can_act = false
		if !used_blood_orbs:
			use_blood_orbs()
		elif randf() < DASH_CHANCE:
			use_charge()
		else:
			# First, check for an axe throw
			if randf() < 0.6:
				throw_axes()
			elif axe_traps.size() > 0 && randf() < get_jump_chance():
				animation_player.play("jump")
				await animation_player.animation_finished
				animation_player.play("walk")
			#elif randf() < 0.2:
				#spawn_executed()
			elif randf() <0.2:
				spawn_ghosts()
			elif randf() < 0.15 && global_position.distance_squared_to(player.global_position) <= pow(MAX_BUBBLE_STORM_RANGE, 2):
				animation_player.play("bubble_storm_start")
			else:
				throw_trap_axes()

func use_charge():
	# First, check if we teleport
	if randf() < 0.20:
		teleport()
	elif randf() < 0.5:
		lunge()
	else:
		side_dash()

func teleport():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	final_boss_audio_player.play_laugh_audio()
	
	# If possible, we want to teleport to the opposite side of the player!	
	var distance_to_player = global_position.distance_to(player.global_position)
	var angle_to_player = (player.global_position - global_position).normalized()
	var target_position = global_position + (angle_to_player * distance_to_player * 2)
	
	var query_parameters = PhysicsRayQueryParameters2D.create(global_position, target_position, 1 << 0)
	var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
	
	if !result.is_empty():
		target_position = result["position"]
		if target_position.distance_squared_to(player.global_position) <= pow(MIN_DISTANCE_AFTER_TELEPORT, 2):
			can_act = true
			return
	
	teleport_player_2d.play()
	animation_player.play("teleport_start")
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, 0.4) \
	.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	animation_player.play("teleport_end")
	await animation_player.animation_finished
	animation_player.play("walk")
	action_counter -= 1
	can_act = true


func lunge():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	charge_direction = (player.global_position - global_position).normalized()
	dash(charge_direction)
	
	
func side_dash():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var dir_sign = -1 if randf() <= 0.5 else 1
	charge_direction = (player.global_position - global_position).normalized()\
	.rotated(deg_to_rad(dir_sign * 90))
	
	
	if randf() < 0.25:
		# Side teleport instead!
		final_boss_audio_player.play_laugh_audio()
		var target_position = charge_direction * randf_range(100, 200)
	
		var query_parameters = PhysicsRayQueryParameters2D.create(global_position, target_position, 1 << 0)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		
		if !result.is_empty():
			target_position = result["position"]
		
		teleport_player_2d.play()
		animation_player.play("teleport_start")
		var tween = create_tween()
		tween.tween_property(self, "global_position", target_position, 0.4) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		await tween.finished
		animation_player.play("teleport_end")
		await animation_player.animation_finished
		animation_player.play("walk")
		action_counter -= 1
		can_act = true
	else:
		dash(charge_direction)
		
	action_counter -= 2


func get_jump_chance():
	var count = axe_traps.size()
	if count < 20:
		return 0
	
	return count * 0.003

func dash(vector):
	dash_player_2d.play()
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	charge_direction = vector
	animation_player.play("charge")
	charging = true
	await animation_player.animation_finished
	charging = false
	can_act = true
	animation_player.play("walk")


func throw_axes():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var player_angle = (player.global_position - global_position).normalized()
	
	final_boss_audio_player.play_shoot_audio()
		
	var patterns = ["cluster", "quick_collapse", "enclosing"]
	var pattern = patterns.pick_random()
	throwing_knives = true
	await get_tree().create_timer(0.25).timeout
	if pattern == "cluster":
		var knives_to_throw = 7
		var arc = 30.0
		for i in knives_to_throw:
			knife_shot_player_2d.play()
			var new_angle = player_angle.rotated(deg_to_rad(randf_range(-arc/2, arc/2)))
			bullet_emitter_component.fire(new_angle, 180 + randf_range(20,50), 3.5, AXE_DAMAGE, 7)
			await get_tree().create_timer(0.08).timeout
		await get_tree().create_timer(0.25).timeout
	elif pattern == "quick_collapse":
		var knives_to_throw = 8
		for i in knives_to_throw:
			knife_shot_player_2d.play()
			var spawn_position = get_spawn_position()
			var instance = bullet_emitter_component.fire(Vector2.ZERO, 170, 3.5, AXE_DAMAGE, 10)
			instance.position = spawn_position
			instance.direction = (player.global_position - spawn_position).normalized()
			await get_tree().create_timer(0.1).timeout
		await get_tree().create_timer(0.7).timeout
	elif pattern == "enclosing":
		knife_shot_player_2d.play()
		var knives_to_throw = 14
		var offsets = [ \
		-27.5, -35, -42.5, -50, -57.5, -65, -72.5, \
		27.5, 35, 42.5, 50, 57.5, 65, 72.5 \
		]
		for i in knives_to_throw:
			var new_angle = player_angle.rotated(deg_to_rad(offsets[i]))
			bullet_emitter_component.fire(new_angle, 220, 3.5, AXE_DAMAGE, 7)
		await get_tree().create_timer(0.4).timeout

	can_act = true
	throwing_knives = false


func spawn_ghosts():
	GameEvents.emit_spawn_ghosts()
	can_act = true
	
func get_spawn_position():
	var spawn_radius = 375
	var player = get_tree().get_first_node_in_group("player") as Node2D
	var spawn_position = Vector2.ZERO
	if player == null:
		return spawn_position
	
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	for i in 4:
		spawn_position = player.global_position + (random_direction * spawn_radius)
		var additional_check_offset = random_direction * 20
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position + additional_check_offset, 1 << 0)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		
		if result.is_empty():
			# Ray doesn't intersect terrain
			break
		else:
			random_direction = random_direction.rotated(deg_to_rad(90))
	
	return spawn_position

func throw_trap_axes():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
		
	final_boss_audio_player.play_trap_create_audio()
	var angle_to_player = (player.global_position - global_position).normalized()
	var distances = [50, 100, 150, 200, 250]
	for i in 5:
		var direction = angle_to_player.rotated(deg_to_rad(-90))
		var target_position = global_position + (direction * distances[i])
		var query_parameters = PhysicsRayQueryParameters2D.create(global_position, target_position, 1 << 0)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		if !result.is_empty():
			continue
		create_trap_axe(target_position)
		await get_tree().create_timer(0.1).timeout
		
	for i in 5:
		var direction = angle_to_player.rotated(deg_to_rad(90))
		var target_position = global_position + (direction * distances[i])
		var query_parameters = PhysicsRayQueryParameters2D.create(global_position, target_position, 1 << 0)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		if !result.is_empty():
			continue
		create_trap_axe(target_position)
		await get_tree().create_timer(0.1).timeout
	
	await get_tree().create_timer(0.75).timeout
	can_act = true
	

func create_trap_axe(target_position: Vector2):
	knife_shot_player_2d.play()
	var bullet = axe_bullet_scene.instantiate()
	var layer = get_tree().get_first_node_in_group("foreground_layer")
	layer.add_child(bullet)
	bullet.scale = Vector2(3.5, 3.5)
	bullet.set_duration(-1)
	bullet.global_position = global_position
	var tween = create_tween()
	tween.tween_property(bullet, "global_position", target_position, 1)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	axe_traps.push_back(bullet)

func activate_axe_traps():
	GameEvents.emit_shake_camera()
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	for axe in axe_traps:
		if axe == null:	# Can happen if the player hit one while it was stationary
			continue
		var dir = (player.global_position - axe.global_position).normalized()
		dir = dir.rotated(deg_to_rad(randf_range(-45, 45)))
		axe.direction = dir
		var tween = create_tween()
		tween.tween_property(axe, "speed", 100, 3)
	axe_traps = []
	can_act = true


func fire_bubble_storm():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	var target_angle = (player.global_position - global_position).normalized()
	var delay = BUBBLE_STORM_DURATION / TOTAL_BUBBLES_TO_FIRE
	for i in TOTAL_BUBBLES_TO_FIRE:
		var lerp_amount = float(i) / float(TOTAL_BUBBLES_TO_FIRE)
		var current_arc = lerp(BUBBLE_STORM_MIN_ARC, BUBBLE_STORM_MAX_ARC, lerp_amount)
		var angle_random = deg_to_rad(current_arc/2)
		var angle = target_angle.rotated(randf_range(-angle_random, angle_random))
		var speed = randf_range(BUBBLE_MIN_SPEED, BUBBLE_MAX_SPEED)
		bullet_emitter_component.fire(angle, speed, 3, float(AXE_DAMAGE)/2.0, 10)
		knife_shot_player_2d.play()
		await get_tree().create_timer(delay).timeout
	# When finished, restart our attack timer and resume animation
	animation_player.play("bubble_storm_end")
	await animation_player.animation_finished
	animation_player.play("walk")
	can_act = true

func use_blood_orbs():
	used_blood_orbs = true
	var main = get_tree().get_first_node_in_group("main")
	if main == null:
		can_act = true
		return
	
	var collected_blood_orbs = main.blood_orbs_consumed
	if collected_blood_orbs >= 4:
		can_act = true
		return
		
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		can_act = true
		return
	
	var foreground = get_tree().get_first_node_in_group("foreground_layer")
	if foreground == null:
		can_act = true
		return
		
	
	var blood_orbs_to_create = 0
	var max_unlocked_blood_orbs = MetaProgression.get_upgrade_quantity("blood_orbs")
	if max_unlocked_blood_orbs < 4:
		blood_orbs_to_create = 4 - max_unlocked_blood_orbs
	
	if get_tree().get_nodes_in_group("blood_orbs").size() > 0 || blood_orbs_to_create > 0:
		final_boss_audio_player.play_blood_orb_audio()
	
	var dir = Vector2.RIGHT.rotated(deg_to_rad(45))
	if blood_orbs_to_create > 0:
		for i in blood_orbs_to_create:
			var blood_orb_instance = blood_orb_scene.instantiate()
			foreground.add_child(blood_orb_instance)
			blood_orb_instance.global_position = global_position
			
			var direction = dir.rotated(deg_to_rad(90 * i))
			var distance = 75
			var target_position = global_position + (direction * distance)
			var query_parameters = PhysicsRayQueryParameters2D.create(global_position, target_position, 1 << 0)
			var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
			if !result.is_empty():
				target_position = result["position"]
			var tween = create_tween()
			tween.tween_property(blood_orb_instance, "global_position", target_position, 1.2) \
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		await get_tree().create_timer(1.5).timeout
		
	var orbs = get_tree().get_nodes_in_group("blood_orbs")
	var orb_number = 0
	for orb in orbs:
		orb_number += 1
		orb.original_position = orb.global_position
		var tween = create_tween()
		tween.tween_method(tween_blood_orb.bind(orb), 0.0, 1.0, 5.0 + orb_number*3)
	await get_tree().create_timer(1.5).timeout
	can_act = true
	
	
func tween_blood_orb(percent:float, blood_orb: Node2D):
	if blood_orb == null:
		return

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	blood_orb.global_position = blood_orb.original_position.lerp(player.global_position, percent)
