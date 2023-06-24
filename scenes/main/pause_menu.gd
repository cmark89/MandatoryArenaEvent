extends CanvasLayer

@onready var animation_player = %AnimationPlayer
@onready var panel_container = $PauseMenuContainer/PanelContainer
@onready var resume_button = %ResumeButton
@onready var options_button = %OptionsButton
@onready var menu_button = %MenuButton


var is_closing = false
var options_menu_scene = preload("res://scenes/main/options_menu.tscn")
@onready var main_menu_scene = load("res://scenes/main/main_menu.tscn")

func _ready():
	get_tree().paused = true
	panel_container.pivot_offset = panel_container.size / 2
	
	resume_button.pressed.connect(on_resume_pressed)
	options_button.pressed.connect(on_options_pressed)
	menu_button.pressed.connect(on_menu_pressed)
	
	animation_player.play("in")
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0)
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0.3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func on_resume_pressed():
	close()


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		get_tree().root.set_input_as_handled()
		close()


func close():
	if is_closing:
		return
	is_closing = true
	
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0)
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0.3)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	
	await tween.finished
	get_tree().paused = false
	queue_free()


func on_menu_pressed():
	MusicPlayer.stop_music(0.3)
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	MusicPlayer.play_menu_theme()
	get_tree().paused = false
	
	var main_menu_instance = main_menu_scene.instantiate()
	# Add the new scene to the root 
	get_tree().get_root().add_child(main_menu_instance)
	
	# Delete the "current" scene (the menu)
	get_tree().get_current_scene().queue_free()
	
	# Finally, inform the scene tree that the new scene is now the "current" scene
	get_tree().set_current_scene(main_menu_instance)
	

func on_options_pressed():
	var options_menu_instance = options_menu_scene.instantiate()
	add_child(options_menu_instance)
	options_menu_instance.back_pressed.connect(on_options_back_pressed.bind(options_menu_instance))


func on_options_back_pressed(options_menu:Node):
	options_menu.queue_free()
