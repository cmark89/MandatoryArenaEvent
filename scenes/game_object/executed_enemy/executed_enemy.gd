extends CharacterBody2D

@export var bestiary_entry_id: String
@export var damage = 2
@onready var visuals = $Visuals as Node2D
@onready var velocity_component = $VelocityComponent
@onready var enemy_sound_player_component = $EnemySoundPlayerComponent
@onready var bullet_emitter_component = $BulletEmitterComponent
@onready var timer = $Timer
@onready var suicide_sound_player = $SuicideSoundPlayer


var difficulty
var suicide = false
func _ready():
	$HurtboxComponent.hit.connect(on_hit)
	timer.timeout.connect(on_death_timer_timeout)


func on_death_timer_timeout():
	suicide = true
	suicide_sound_player.play()
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var dir: Vector2 = (player.global_position - global_position).normalized()
	# If left alive too long, fires multiple bullets at the player
	for i in 7:
		bullet_emitter_component.fire(dir.rotated(deg_to_rad(randf_range(-10, 10))), 100 + randf_range(-35, 50), 3.5, 4, 30)
	
	$HealthComponent.died.emit(DamageSource.new("souldeath"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity_component.accelerate_to_player()
	velocity_component.move(self)

	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale.x = move_sign

func on_hit(audio_stream: AudioStream):
	enemy_sound_player_component.play_damage_sound(audio_stream)
