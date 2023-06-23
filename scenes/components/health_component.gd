extends Node
class_name HealthComponent

signal died(damage_source: DamageSource)
signal health_changed

@export var max_health: float = 10
var current_health


func _ready():
	current_health = max_health


func damage(damage_amount: float, damage_source: DamageSource):
	current_health = max(current_health - damage_amount, 0)
	health_changed.emit()
	Callable(check_death.bind(damage_source)).call_deferred()


func check_death(damage_source: DamageSource):
	if current_health == 0:
		died.emit(damage_source)
		owner.queue_free()


func get_health_percent():
	if (max_health <= 0):
		return 0
	return min(current_health / max_health, 1)


func add_health(amount: int, allow_overheal: bool = false):
	current_health += amount
	if !allow_overheal:
		current_health = min(current_health, max_health)
	elif current_health > max_health:
		max_health = current_health
		
