extends CanvasLayer

signal upgrade_selected(upgrade: AbilityUpgrade)
signal reroll_selected(upgrade_screen_instance: Node2D)
signal emergency_heal_selected(upgrade_screen_instance: Node2D)
@onready var audio_stream_player = $AudioStreamPlayer

@export var upgrade_card_scene: PackedScene
@onready var card_container: HBoxContainer = $%CardContainer

@onready var meta_button_container = %MetaButtonContainer
@onready var reroll_button = %RerollButton
@onready var reroll_label = %RerollLabel
@onready var emergency_healing_button = %EmergencyHealingButton
@onready var emergency_healing_label = %EmergencyHealingLabel
@onready var reroll_container = %RerollContainer
@onready var emergency_healing_container = %EmergencyHealingContainer

var ignore_input = false
var main
func _ready():
	main = get_tree().get_first_node_in_group("main")
	if MetaProgression.has_upgrade("reroll"):
		reroll_button.pressed.connect(on_reroll_button_pressed)
	else:
		reroll_container.visible = false
		
	if MetaProgression.has_upgrade("emergency_healing"):
		emergency_healing_button.pressed.connect(on_emergency_healing_button_pressed)
	else:
		emergency_healing_container.visible = false
	update_meta_display()
	get_tree().paused = true


func update_meta_display():
	if reroll_container.visible:
		reroll_label.text = str(main.rerolls_left) + " Remaining"
		reroll_button.disabled = main.rerolls_left <= 0
	if emergency_healing_container.visible:
		emergency_healing_label.text = str(main.emergency_heals_left) + " Remaining"
		emergency_healing_button.disabled = main.emergency_heals_left <= 0


func set_ability_upgrades(upgrades: Array[AbilityUpgrade]):
	var i = 0
	for upgrade in upgrades:
		var card_instance = upgrade_card_scene.instantiate()
		card_container.add_child(card_instance)
		card_instance.set_ability_upgrade(upgrade)
		card_instance.play_in(i * 0.25)
		card_instance.selected.connect(on_upgrade_selected.bind(upgrade))
		i += 1

func on_upgrade_selected(upgrade: AbilityUpgrade):
	upgrade_selected.emit(upgrade)
	$%AnimationPlayer.play("out")
	await $%AnimationPlayer.animation_finished
	get_tree().paused = false
	queue_free()


func on_reroll_button_pressed():
	if ignore_input:
		return
	ignore_input = true
	var last_card	# THIS IS STUPID
	for card in card_container.get_children():
		last_card = card
		card.play_discard()
		
	await last_card.animation_player.animation_finished
	for card in card_container.get_children():
		card.queue_free()
	main.rerolls_left -= 1
	update_meta_display()
	reroll_selected.emit(self)
	await get_tree().create_timer(0.5).timeout
	ignore_input = false


func on_emergency_healing_button_pressed():
	# TODO: Play a sting
	if ignore_input:
		return
	ignore_input = true
	for card in card_container.get_children():
		card.play_discard()
	main.emergency_heals_left -= 1
	update_meta_display()
	$%AnimationPlayer.play("out")
	await $%AnimationPlayer.animation_finished
	get_tree().get_first_node_in_group("player").emergency_healing()
	get_tree().paused = false
	queue_free()
