extends CanvasLayer

signal back_pressed
@onready var back_button = %BackButton
@onready var normal_button = %NormalButton
@onready var maniac_button = %ManiacButton
@onready var nightmare_button = %NightmareButton

var main_scene = preload("res://scenes/main/main.tscn")

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
	# TODO: Here we need to pass some value to the game to make sure the difficulty
	# is properly set
	MusicPlayer.stop_music(0.3)
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	MusicPlayer.play_normal_battle_theme()
	
	var main_scene_instance = main_scene.instantiate()
	main_scene_instance.difficulty = difficulty
	# Since we want to parameterize our new scene, we cannot simply "change"
	# the scene. We need to do it manually. Thus we...
	
	# Add the new scene to the root 
	get_tree().get_root().add_child(main_scene_instance)
	
	# Delete the "current" scene (the menu)
	get_tree().get_current_scene().queue_free()
	
	# Finally, inform the scene tree that the new scene is now the "current" scene
	get_tree().set_current_scene(main_scene_instance)
	
func on_back_pressed():
	back_pressed.emit()
