extends CharacterBody2D

@export var bestiary_entry_id: String
@export var damage = 6
@onready var visuals = $Visuals as Node2D
@onready var velocity_component = $VelocityComponent
@onready var enemy_sound_player_component = $EnemySoundPlayerComponent
var difficulty

func _ready():
	$HurtboxComponent.hit.connect(on_hit)
	adjust_for_difficulty()


func adjust_for_difficulty():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)

	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale.x = -move_sign

func on_hit(audio_stream: AudioStream):
	enemy_sound_player_component.play_damage_sound(audio_stream)
