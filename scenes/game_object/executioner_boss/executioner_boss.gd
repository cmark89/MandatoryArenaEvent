extends CharacterBody2D

@export var bestiary_entry_id: String
@export var damage = 2
@export var boss_name = "GRAND EXECUTIONER"
@onready var visuals = $Visuals as Node2D
@onready var velocity_component = $VelocityComponent
@onready var enemy_sound_player_component = $EnemySoundPlayerComponent
@onready var health_component = $HealthComponent
@onready var bullet_emitter_component = $BulletEmitterComponent
@onready var animation_player = $AnimationPlayer
@onready var attack_timer = $AttackTimer

@onready var knife_shot_player_2d = $KnifeShotPlayer2D
@onready var dash_player_2d = $DashPlayer2D

var axe_bullet_scene = preload("res://scenes/game_object/enemy_bullet/enemy_bullet_axe.tscn")

var axe_traps = []
const PREPARE_AXES_CHANCE = 0.3
const DASH_CHANCE = 0.4


const ACTION_COUNTER_TRIGGER_MIN = 2
const ACTION_COUNTER_TRIGGER_MAX = 3
var action_counter = 0

const AXE_DAMAGE = 5
var difficulty
var can_act = true
var charging = false
var throwing_knives = false
var charge_direction
@export var current_charge_speed = 60

func _ready():
	$HurtboxComponent.hit.connect(on_hit)
	attack_timer.timeout.connect(on_attack_timer_timeout)
	await get_tree().create_timer(5).timeout
	attack_timer.start()

func set_death_callback(callback):
	$HealthComponent.died.connect(callback)


func set_next_action_trigger():
	action_counter = randi_range(ACTION_COUNTER_TRIGGER_MIN, ACTION_COUNTER_TRIGGER_MAX)

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
		set_next_action_trigger()
		can_act = false
		if randf() < DASH_CHANCE:
			use_charge()
		else:
			# First, check for an axe throw
			if randf() < 0.6:
				throw_axes()
			elif axe_traps.size() > 0 && randf() < get_jump_chance():
				animation_player.play("jump")
				await animation_player.animation_finished
				animation_player.play("walk")
			elif randf() < 0.2:
				spawn_executed()
			elif randf() <0.2:
				spawn_gladiators()
			else:
				throw_trap_axes()

func use_charge():
	var roll = randf()
	if roll < 0.5:
		lunge()
	else:
		side_dash()


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
	dash(charge_direction)
	action_counter -= 2


func get_jump_chance():
	var count = axe_traps.size()
	if count < 10:
		return 0
	
	return count * 0.005

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
		
	var patterns = ["cluster", "quick_collapse"]
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
		var knives_to_throw = 6
		for i in knives_to_throw:
			knife_shot_player_2d.play()
			var spawn_position = get_spawn_position()
			var instance = bullet_emitter_component.fire(Vector2.ZERO, 170, 3.5, AXE_DAMAGE, 10)
			instance.position = spawn_position
			instance.direction = (player.global_position - spawn_position).normalized()
			await get_tree().create_timer(0.1).timeout
		await get_tree().create_timer(0.7).timeout
	
	can_act = true
	throwing_knives = false


func spawn_gladiators():
	GameEvents.emit_spawn_gladiators()
	can_act = true

func spawn_executed():
	GameEvents.emit_spawn_executed()
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
	var angle_to_player = (player.global_position - global_position).normalized()
	var distances = [50, 100, 150]
	for i in 3:
		var direction = angle_to_player.rotated(deg_to_rad(-90))
		var target_position = global_position + (direction * distances[i])
		var query_parameters = PhysicsRayQueryParameters2D.create(global_position, target_position, 1 << 0)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		if !result.is_empty():
			continue
		create_trap_axe(target_position)
		await get_tree().create_timer(0.1).timeout
		
	for i in 3:
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
		var dir = (player.global_position - axe.global_position).normalized()
		dir = dir.rotated(deg_to_rad(randf_range(-45, 45)))
		axe.direction = dir
		var tween = create_tween()
		tween.tween_property(axe, "speed", 100, 3)
	axe_traps = []
	can_act = true
