extends CanvasLayer

@onready var health_bar = %HealthBar
@onready var boss_name_label = %BossName
@onready var animation_player = $AnimationPlayer
@onready var margin_container = $MarginContainer

var health_component

func _ready():
	visible = false


func setup(boss_health_component: HealthComponent, boss_name: String):
	boss_name_label.text = boss_name
	health_component = boss_health_component
	health_component.health_changed.connect(on_health_changed)


func show_boss_health_bar():
	visible = true
	margin_container.modulate = Color.TRANSPARENT
	animation_player.play("show")


func hide_boss_health_bar():
	animation_player.play("hide")
	await animation_player.animation_finished
	visible = false


func on_health_changed():
	health_bar.value = health_component.current_health / health_component.max_health
	if health_bar.value <= 0.0:
		hide_boss_health_bar()
