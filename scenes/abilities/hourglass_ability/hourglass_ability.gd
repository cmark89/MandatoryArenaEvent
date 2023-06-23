extends Node2D

@onready var hitbox_component = $HitboxComponent
@onready var collision_shape_2d = $HitboxComponent/CollisionShape2D
@onready var animation_player = $AnimationPlayer
@onready var ring_particle = $RingParticle
@onready var dirt_particles = $DirtParticles


func set_radius(amount: float):
	collision_shape_2d.shape.radius = amount
	
	ring_particle.process_material.scale_min = (amount / 10) * 0.06
	ring_particle.process_material.scale_max = (amount / 10) * 0.06
	
	dirt_particles.process_material.emission_sphere_radius = amount
	dirt_particles.amount = 4 + (amount / 5)
	dirt_particles.process_material.scale_min = amount / 100
	dirt_particles.process_material.scale_max = amount / 100
	

func play():
	animation_player.play("default")
