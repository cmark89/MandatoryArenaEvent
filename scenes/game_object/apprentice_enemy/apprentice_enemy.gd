extends CharacterBody2D


@export var damage = 3
@onready var velocity_component = $VelocityComponent
@onready var visuals = $Visuals
@onready var enemy_sound_player_component = $EnemySoundPlayerComponent
@onready var bullet_emitter_component = $BulletEmitterComponent
@onready var bullet_timer = $BulletTimer
@onready var bullet_sound_player = $BulletSoundPlayer

var difficulty
var bullet_readiness = 0
const FIRE_BULLET_AT_READINESS = 6
const MIN_BULLET_DISTANCE = 50

@export var bestiary_entry_id: String
var is_moving = false
var bullet_speed = 155

func _ready():
	$HurtboxComponent.hit.connect(on_hit)
	adjust_for_difficulty()
	bullet_readiness = randi_range(0,3)
	bullet_timer.timeout.connect(on_bullet_timer_timeout)
	

func on_bullet_timer_timeout():
	bullet_readiness += 1
	check_bullet()


func check_bullet():
	
	if bullet_readiness >= FIRE_BULLET_AT_READINESS:
		var player = get_tree().get_first_node_in_group("player")
		if player == null:
			return
		
		if global_position.distance_squared_to(player.global_position) >= pow(MIN_BULLET_DISTANCE, 2):		
			bullet_readiness = 0
			var vector2 = (player.global_position - global_position).normalized()
			bullet_emitter_component.fire(vector2, 155, 2, 7, 10)
			bullet_sound_player.play()

func adjust_for_difficulty():
	if difficulty == "NORMAL":
		bullet_speed -= 25


func _process(delta):
	if is_moving:
		velocity_component.accelerate_to_player()
	else:
		velocity_component.decelerate()
		
	velocity_component.move(self)

	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale.x = move_sign

func set_is_moving(moving: bool):
	is_moving = moving


func on_hit(audio_stream: AudioStream):
	enemy_sound_player_component.play_damage_sound(audio_stream)
