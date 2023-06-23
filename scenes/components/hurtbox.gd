extends Area2D
class_name HurtboxComponent

signal hit(audio_stream: AudioStream)

@export var health_component: HealthComponent
@export var is_ghost: bool = false
var floating_text_scene: PackedScene = preload("res://scenes/ui/floating_text.tscn")
func _ready():
	area_entered.connect(on_area_entered)


func on_area_entered(other_area: Area2D):
	if not other_area is HitboxComponent:
		return
	
	if health_component == null:
		return
	
	var hitbox_component = other_area as HitboxComponent
	var damage = hitbox_component.damage
	var is_crit = false
	if hitbox_component.crit_chance > 0 && randf() <= hitbox_component.crit_chance:
		damage *= hitbox_component.crit_damage_multiplier
		is_crit = true
	
	var color_override = Color.WHITE
	if is_ghost:
		damage = 1
		color_override = Color.MEDIUM_PURPLE
	
	hit.emit(hitbox_component.damage_sound)
	health_component.damage(damage, hitbox_component.damage_source)
	
	var floating_text = floating_text_scene.instantiate() as Node2D
	get_tree().get_first_node_in_group("foreground_layer").add_child(floating_text)
	floating_text.global_position = global_position + (Vector2.UP * 16)
	var format_string = "%0.0f"
	floating_text.start(format_string % damage, is_crit, color_override)
	if !hitbox_component.callback.is_null():
		hitbox_component.callback.call()
