extends CanvasLayer
@onready var animation_player = $AnimationPlayer
@onready var main_menu_scene = load("res://scenes/main/main_menu.tscn")

func play_ending():
	animation_player.play("fade_to_white")
	await animation_player.animation_finished
	
	# Delete the "current" scene (the main game scene)
	get_tree().get_current_scene().queue_free()
	
	# Finally, inform the scene tree that the new scene is now the "current" scene
	get_tree().set_current_scene(self)
	MusicPlayer.play_ending_theme()
	animation_player.play("epilogue")
	await animation_player.animation_finished
	await get_tree().create_timer(1.5).timeout
	ScreenTransition.transition_halfway.connect(switch_to_main)
	ScreenTransition.transition()

func switch_to_main():
	MusicPlayer.play_menu_theme()
	
	var main_menu_instance = main_menu_scene.instantiate()
	# Add the new scene to the root 
	get_tree().get_root().add_child(main_menu_instance)
	
	# Delete the "current" scene (the menu)
	get_tree().get_current_scene().queue_free()
	
	# Finally, inform the scene tree that the new scene is now the "current" scene
	get_tree().set_current_scene(main_menu_instance)
