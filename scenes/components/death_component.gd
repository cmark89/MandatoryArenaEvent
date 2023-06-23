extends Node2D

@export var health_component: Node
@export var sprite: Sprite2D
@export var particle_scale: float = 1
@onready var enemy_sound_player_component = $EnemySoundPlayerComponent
@onready var gpu_particles_2d = $GPUParticles2D

var death_sounds = {
	"sword": preload("res://assets/audio/hit_sword.wav"),
	"axe": preload("res://assets/audio/hit_axe.wav"),
	"hammer": preload("res://assets/audio/hit_hammer.ogg"),
	"shuriken": preload("res://assets/audio/hit_shuriken.wav"),
	"butterflyknife": preload("res://assets/audio/hit_butterflyknife.wav"),
	"kingsbane": preload("res://assets/audio/hit_sword.wav")
}
func _ready():
	$GPUParticles2D.texture = sprite.texture
	health_component.died.connect(on_died)


func on_died(damage_source: DamageSource):
	if owner == null || not owner is Node2D:
		return
		
	var spawn_position = owner.global_position
	
	var entities = get_tree().get_first_node_in_group("entities_layer")
	get_parent().remove_child(self)	
	entities.add_child(self)
	gpu_particles_2d.process_material.scale_min = particle_scale
	gpu_particles_2d.process_material.scale_min = particle_scale
	global_position = spawn_position
	$AnimationPlayer.play("default")
	
	if damage_source != null && death_sounds.has(damage_source.source_name):	
		enemy_sound_player_component.play_damage_sound(death_sounds[damage_source.source_name])

