extends CharacterBody2D

@onready var damage_interval_timer = $DamageIntervalTimer
@onready var collision_area_2d = $CollisionArea2D
@onready var health_component = $HealthComponent
@onready var health_bar = $HealthBar
@onready var abilities = $Abilities
@onready var visuals: Node2D = $Visuals
@onready var animation_player = $AnimationPlayer
@onready var velocity_component = $VelocityComponent
@onready var audio_stream_player_2d = $AudioStreamPlayer2D

var enemy_damage = 0
var base_speed = 0
var health_regen_per_30_seconds = 0
var invincible = false
@export var arena_time_manager: Node

func _ready():
	health_regen_per_30_seconds = MetaProgression.get_upgrade_quantity("health_regen") * 1
	var extra_health = MetaProgression.get_upgrade_quantity("health_boost") * 5
	if extra_health > 0:
		health_component.add_health(extra_health, true)
	
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)
	base_speed = velocity_component.max_speed
	damage_interval_timer.timeout.connect(on_damage_interval_timer_timeout)
	collision_area_2d.body_entered.connect(on_body_entered)
	collision_area_2d.body_exited.connect(on_body_exited)
	health_component.health_changed.connect(on_health_changed)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	GameEvents.healing_vial_collected.connect(heal)
	GameEvents.blood_orb_collected.connect(on_blood_orb_collected)
	update_health_display()

func set_invincible():
	invincible = true
	collision_area_2d.visible = false

func _process(delta):
	var direction = get_movement_vector().normalized()
	velocity_component.accelerate_in_direction(direction)
	velocity_component.move(self)
	
	if direction.x != 0 || direction.y != 0:
		animation_player.play("walk")
	else:
		animation_player.play("RESET")
		
	var move_sign = sign(direction.x)
	if move_sign != 0:
		visuals.scale.x = move_sign


func get_movement_vector():
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")	
	return Vector2(x_movement, y_movement)


func on_body_entered(other_body: Node2D):
	if other_body.get_collision_layer() & 1<<3 == 1<<3:
		enemy_damage += other_body.damage
		check_deal_damage()
	elif other_body.get_collision_layer() & 1<<5 == 1<<5:
		self_damage(other_body.damage)


func check_deal_damage():
	if invincible:
		return
	if (enemy_damage <= 0 || not damage_interval_timer.is_stopped()):
		return
	health_component.damage(enemy_damage, DamageSource.new("enemy"))
	damage_interval_timer.start()


func on_body_exited(other_body: Node2D):
	if other_body.get_collision_layer() & 1<<3 == 1<<3:
		enemy_damage -= other_body.damage
	
	
func on_damage_interval_timer_timeout():
	check_deal_damage()


func update_health_display():
	health_bar.value = health_component.get_health_percent()


func emergency_healing():
	var max_health = health_component.max_health
	var amount_to_heal = max_health * 0.25	
	heal(amount_to_heal)


func on_health_changed():
	update_health_display()
	GameEvents.emit_player_damaged()
	audio_stream_player_2d.play()


func on_ability_upgrade_added(ability_upgrade:AbilityUpgrade, current_upgrades: Dictionary):
	if ability_upgrade is Ability:
		abilities.add_child((ability_upgrade as Ability).ability_controller_scene.instantiate())
	elif ability_upgrade.id == "player_speed":
		velocity_component.max_speed = base_speed + (base_speed * 0.10 * current_upgrades["player_speed"]["quantity"])


func on_arena_difficulty_increased(difficulty: int):
	if health_regen_per_30_seconds <= 0:
		return
	elif difficulty % 6 == 0:	# Every 30 seconds
		heal(health_regen_per_30_seconds)


func heal(amount):
	health_component.add_health(amount, false)
	update_health_display()
	var combat_text = load("res://scenes/ui/floating_text.tscn")
	var combat_text_instance = combat_text.instantiate()
		
	get_tree().get_first_node_in_group("foreground_layer").add_child(combat_text_instance)
	combat_text_instance.global_position = global_position + (Vector2.UP * 16)
	combat_text_instance.start(str("%0.0f" % amount), false, Color.GREEN)


func on_blood_orb_collected():
	self_damage(health_component.current_health * 0.5)


func self_damage(amount):	
	if invincible:
		return

	health_component.damage(amount, DamageSource.new("self"))
	update_health_display()
	var combat_text = load("res://scenes/ui/floating_text.tscn")
	var combat_text_instance = combat_text.instantiate()
		
	get_tree().get_first_node_in_group("foreground_layer").add_child(combat_text_instance)
	combat_text_instance.global_position = global_position + (Vector2.UP * 16)
	combat_text_instance.start(str("%0.0f" % amount), false, Color.RED)
