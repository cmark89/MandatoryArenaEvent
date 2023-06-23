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
@onready var bubble_shot_player_2d = $BubbleShotPlayer2D

const BUBBLE_STORM_DURATION: float = 3
const TOTAL_BUBBLES_TO_FIRE: int = 150
const BUBBLE_STORM_MIN_ARC: float = 35
const BUBBLE_STORM_MAX_ARC: float = 150
const BUBBLE_MIN_SPEED: float = 80
const BUBBLE_MAX_SPEED: float = 180
const BUBBLE_MIN_SCALE: float = 1
const BUBBLE_MAX_SCALE: float = 1.5

const BUBBLE_STORM_CHANCE = 0.3
const ACTION_COUNTER_TRIGGER_MIN = 2
const ACTION_COUNTER_TRIGGER_MAX = 4
var action_counter = 0

var difficulty
var can_act = true
var charging = false

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
		
	else:
		velocity_component.accelerate_to_player()
		velocity_component.move(self)

		var move_sign = sign(velocity.x)
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
		if randf() < BUBBLE_STORM_CHANCE:
			animation_player.play("bubble_storm_start")
		else:
			var player = get_tree().get_first_node_in_group("player")
			if player == null:
				return
			charge_direction = (player.global_position - global_position).normalized()
			animation_player.play("charge")
			charging = true
			await animation_player.animation_finished
			charging = false
			can_act = true
			animation_player.play("walk")


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
		var bullet_scale = randf_range(BUBBLE_MIN_SCALE, BUBBLE_MAX_SCALE)
		bullet_emitter_component.fire(angle, speed, bullet_scale, 3, 10)
		bubble_shot_player_2d.play()
		await get_tree().create_timer(delay).timeout
	# When finished, restart our attack timer and resume animation
	animation_player.play("bubble_storm_end")
	await animation_player.animation_finished
	animation_player.play("walk")
	can_act = true
