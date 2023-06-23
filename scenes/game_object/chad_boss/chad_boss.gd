extends CharacterBody2D

@export var bestiary_entry_id: String
@export var damage = 2
@export var boss_name = "CHADICUS THE VALIANT"
@onready var visuals = $Visuals as Node2D
@onready var velocity_component = $VelocityComponent
@onready var enemy_sound_player_component = $EnemySoundPlayerComponent
@onready var health_component = $HealthComponent
@onready var bullet_emitter_component = $BulletEmitterComponent
@onready var animation_player = $AnimationPlayer
@onready var attack_timer = $AttackTimer

@onready var knife_shot_player_2d = $KnifeShotPlayer2D
@onready var dash_player_2d = $DashPlayer2D

const DASH_CHANCE = 0.5
const ACTION_COUNTER_TRIGGER_MIN = 2
const ACTION_COUNTER_TRIGGER_MAX = 3
var action_counter = 0

const KNIFE_DAMAGE = 4
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
			# We either throw knives or summon lesser chads
			if randf() < 0.75:
				throw_knives()
			else:
				spawn_lesser_chads()

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


func throw_knives():
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	var player_angle = (player.global_position - global_position).normalized()
		
	var patterns = ["single_fast", "spread", "cluster", "enclosing"]
	var pattern = patterns.pick_random()
	throwing_knives = true
	await get_tree().create_timer(0.25).timeout
	if pattern == "single_fast":
		knife_shot_player_2d.play()
		bullet_emitter_component.fire(player_angle, 280, 3.5, KNIFE_DAMAGE, 7)
		await get_tree().create_timer(0.25).timeout
	elif pattern == "spread":
		knife_shot_player_2d.play()
		var knives_to_throw = 7
		var arc = 110.00
		var start_angle = player_angle.rotated(deg_to_rad(-arc/2))
		var angle_step = arc / knives_to_throw
		for i in knives_to_throw:
			var new_angle = start_angle.rotated(deg_to_rad(i * angle_step))
			bullet_emitter_component.fire(new_angle, 180, 3.5, KNIFE_DAMAGE, 7)
		await get_tree().create_timer(0.35).timeout
	elif pattern == "cluster":
		var knives_to_throw = 7
		var arc = 30.00
		for i in knives_to_throw:
			knife_shot_player_2d.play()
			var new_angle = player_angle.rotated(deg_to_rad(randf_range(-arc/2, arc/2)))
			bullet_emitter_component.fire(new_angle, 180 + randf_range(20,50), 3.5, KNIFE_DAMAGE, 7)
			await get_tree().create_timer(0.08).timeout
		await get_tree().create_timer(0.25).timeout
	elif pattern == "enclosing":
		knife_shot_player_2d.play()
		var knives_to_throw = 14
		var offsets = [ \
		-27.5, -35, -42.5, -50, -57.5, -65, -72.5, \
		27.5, 35, 42.5, 50, 57.5, 65, 72.5 \
		]
		for i in knives_to_throw:
			var new_angle = player_angle.rotated(deg_to_rad(offsets[i]))
			bullet_emitter_component.fire(new_angle, 220, 3.5, KNIFE_DAMAGE, 7)
		await get_tree().create_timer(0.4).timeout
	
	can_act = true
	throwing_knives = false


func spawn_lesser_chads():
	GameEvents.emit_spawn_lesser_chads()
	can_act = true
