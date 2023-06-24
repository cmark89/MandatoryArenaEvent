extends CanvasLayer

signal back_pressed
@onready var back_button = %BackButton
@onready var normal_button = %NormalButton
@onready var maniac_button = %ManiacButton
@onready var nightmare_button = %NightmareButton

@onready var main_scene = preload("res://scenes/main/main.tscn")

func _ready():
	normal_button.pressed.connect(start_game.bind("NORMAL"))
	maniac_button.pressed.connect(start_game.bind("MANIAC"))
	nightmare_button.pressed.connect(start_game.bind("NIGHTMARE"))
	back_button.pressed.connect(on_back_pressed)
	
	maniac_button.disabled = !MetaProgression.has_upgrade("maniac_mode")
	nightmare_button.disabled = !MetaProgression.has_upgrade("nightmare_mode")


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		get_tree().root.set_input_as_handled()
		back_pressed.emit()


func start_game(difficulty: String):
	MusicPlayer.stop_music(0.3)
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	MusicPlayer.play_normal_battle_theme()
	GlobalVariables.current_difficulty = difficulty
	SceneManager.change_scene_to_packed(main_scene, true)


func on_back_pressed():
	back_pressed.emit()
