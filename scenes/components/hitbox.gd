extends Area2D
class_name HitboxComponent

var damage = 0
var crit_chance = 0.0
var crit_damage_multiplier = 1.5	#Default
var damage_source: DamageSource = null
var damage_sound: AudioStream = null
var callback: Callable = Callable()
