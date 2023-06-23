extends CharacterBody2D


@export var damage = 3
@onready var velocity_component = $VelocityComponent
@onready var visuals = $Visuals
@onready var enemy_sound_player_component = $EnemySoundPlayerComponent
var difficulty

@export var bestiary_entry_id: String
var is_moving = false

func _ready():
	$HurtboxComponent.hit.connect(on_hit)
	adjust_for_difficulty()


func adjust_for_difficulty():
	pass


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
