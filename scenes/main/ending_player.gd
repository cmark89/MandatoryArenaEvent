extends CanvasLayer
@onready var animation_player = $AnimationPlayer
@onready var main_menu_scene = load("res://scenes/main/main_menu.tscn")

func play_ending():
	animation_player.play("fade_to_white")
	await animation_player.animation_finished
	
	SceneManager.change_scene_to_existing(self)
	
	MusicPlayer.play_ending_theme()
	animation_player.play("epilogue")
	await animation_player.animation_finished
	await get_tree().create_timer(1.5).timeout
	ScreenTransition.transition_halfway.connect(switch_to_main)
	ScreenTransition.transition()

func switch_to_main():
	MusicPlayer.play_menu_theme()
	SceneManager.change_scene_to_packed(main_menu_scene)
