extends CharacterBody2D

@export var bestiary_entry_id: String
@export var damage = 2
@onready var visuals = $Visuals as Node2D
@onready var velocity_component = $VelocityComponent
@onready var enemy_sound_player_component = $EnemySoundPlayerComponent
@onready var bullet_emitter_component = $BulletEmitterComponent
@onready var timer = $Timer

@onready var health_vial_drop_component = $HealthVialDropComponent
@onready var vial_drop_component = $VialDropComponent


var difficulty
var suicide = false
func _ready():
	$HurtboxComponent.hit.connect(on_hit)
	adjust_for_difficulty()
	$HealthComponent.died.connect(on_death)
	timer.timeout.connect(on_death_timer_timeout)


func adjust_for_difficulty():
	pass


func on_death_timer_timeout():
	suicide = true
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	vial_drop_component.queue_free()
	health_vial_drop_component.queue_free()
	var dir: Vector2 = (player.global_position - global_position).normalized()
	# If left alive too long, fires multiple bullets at the player
	bullet_emitter_component.fire(dir, 75, 1.3, 5, 30)
	bullet_emitter_component.fire(dir.rotated(deg_to_rad(25)), 75, 1.3, 5, 30)
	bullet_emitter_component.fire(dir.rotated(deg_to_rad(-25)), 75, 1.3, 5, 30)
	
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

func on_death(damage_source: DamageSource):
	if suicide:
		return
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
		
	var dir = (player.global_position - global_position).normalized()
	# The exhumed should fire a bullet at the player upon death
	bullet_emitter_component.fire(dir, 35, 1.3, 5, 30)
