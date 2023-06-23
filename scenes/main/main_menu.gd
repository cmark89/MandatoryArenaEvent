extends CanvasLayer

var options_scene = preload("res://scenes/main/options_menu.tscn")
var upgrades_scene = preload("res://scenes/main/meta_menu.tscn")
var difficulty_select_scene = preload("res://scenes/main/difficulty_menu.tscn")
var bestiary_scene = preload("res://scenes/main/bestiary.tscn")
var chronicle_scene = preload("res://scenes/main/chronicle.tscn")
var credits_scene = preload("res://scenes/main/credits.tscn")
@onready var main_menu_container = $MainMenuContainer
@onready var bestiary_button = %BestiaryButton
@onready var chronicle_button = %ChronicleButton
@onready var epitaphs_button = %EpitaphsButton
@onready var credits_button = %CreditsButton
@onready var credits_button_container = $MainMenuContainer/MarginContainer
@onready var release_version = %ReleaseVersion
@onready var audio_stream_player = $AudioStreamPlayer
@onready var global_click_player = $GlobalClickPlayer


func _ready():
	$%PlayButton.pressed.connect(on_play_pressed)
	$%OptionsButton.pressed.connect(on_options_pressed)
	$%QuitButton.pressed.connect(on_quit_pressed)
	$%UpgradesButton.pressed.connect(on_upgrades_pressed)
	
	bestiary_button.pressed.connect(on_bestiary_pressed)
	chronicle_button.pressed.connect(on_chronicle_pressed)
	epitaphs_button.pressed.connect(on_epitaphs_pressed)
	credits_button.pressed.connect(on_credits_pressed)
	credits_button_container.visible = MetaProgression.save_data["tutorial_seen"]
	release_version.text = ProjectSettings.get_setting("global/release_version")
	GameEvents.tutorial_closed.connect(show_credits_button)
	GameEvents.play_global_click_sound.connect(global_click_player.play)
	update_book_visibility()

func on_play_pressed():
	if MetaProgression.has_upgrade("nightmare_mode") || MetaProgression.has_upgrade("maniac_mode"):
		var difficulty_menu_instance = difficulty_select_scene.instantiate()
		add_child(difficulty_menu_instance)
		difficulty_menu_instance.back_pressed.connect(on_window_closed.bind(difficulty_menu_instance))
		main_menu_container.visible = false
	else:
		MusicPlayer.stop_music(0.3)
		ScreenTransition.transition()
		await ScreenTransition.transition_halfway
		MusicPlayer.play_normal_battle_theme()
		get_tree().change_scene_to_file("res://scenes/main/main.tscn")
	

func update_book_visibility():
	bestiary_button.visible = MetaProgression.has_upgrade("book_bestiary")
	chronicle_button.visible = MetaProgression.has_upgrade("book_chronicle")
	epitaphs_button.visible = MetaProgression.has_upgrade("book_epitaphs")


func on_options_pressed():
	var options_instance = options_scene.instantiate()
	add_child(options_instance)
	options_instance.back_pressed.connect(on_window_closed.bind(options_instance))
	main_menu_container.visible = false
	

func on_upgrades_pressed():
	var meta_menu_instance = upgrades_scene.instantiate()
	add_child(meta_menu_instance)
	meta_menu_instance.back_pressed.connect(on_window_closed.bind(meta_menu_instance))
	main_menu_container.visible = false


func on_quit_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	get_tree().quit()


func on_window_closed(window: Node):
	window.queue_free()
	global_click_player.play()
	update_book_visibility()
	main_menu_container.visible = true


func on_bestiary_pressed():
	var bestiary_instance = bestiary_scene.instantiate()
	add_child(bestiary_instance)
	bestiary_instance.back_pressed.connect(on_window_closed.bind(bestiary_instance))
	main_menu_container.visible = false


func on_credits_pressed():
	var credits_instance = credits_scene.instantiate()
	add_child(credits_instance)
	credits_instance.back_pressed.connect(on_window_closed.bind(credits_instance))
	main_menu_container.visible = false


func on_chronicle_pressed():
	var chronicle_instance = chronicle_scene.instantiate()
	add_child(chronicle_instance)
	chronicle_instance.back_pressed.connect(on_window_closed.bind(chronicle_instance))
	main_menu_container.visible = false


func on_epitaphs_pressed():
	if !audio_stream_player.playing:
		audio_stream_player.play()

func show_credits_button():
	credits_button_container.visible = true
