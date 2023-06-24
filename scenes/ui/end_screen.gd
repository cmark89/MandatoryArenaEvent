extends CanvasLayer

@onready var panel_container = %PanelContainer
@onready var audio_stream_player = $AudioStreamPlayer

var victory_theme = preload("res://assets/audio/victory.mp3")
var defeat_theme = preload("res://assets/audio/defeat.mp3")
@onready var main_menu_scene = load("res://scenes/main/main_menu.tscn")
@onready var main_game_scene = load("res://scenes/main/main.tscn")
func _ready():
	var tween = create_tween()
	panel_container.pivot_offset = panel_container.size / 2
	
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0)
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0.3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	get_tree().paused = true
	$%RestartButton.pressed.connect(on_restart_button_pressed)
	$%QuitButton.pressed.connect(on_quit_button_pressed)


func on_restart_button_pressed():
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	MusicPlayer.play_normal_battle_theme()
	get_tree().paused = false
	SceneManager.change_scene_to_packed(main_game_scene)


func on_quit_button_pressed():
	MusicPlayer.stop_music(0.3)
	ScreenTransition.transition()
	await ScreenTransition.transition_halfway
	MusicPlayer.play_menu_theme()
	get_tree().paused = false
	SceneManager.change_scene_to_packed(main_menu_scene)


func set_defeat():
	MusicPlayer.stop_music(0)
	$%TitleLabel.text = "Defeat"
	$%DescriptionLabel.text = "You died..."
	audio_stream_player.stream = defeat_theme
	audio_stream_player.play()
	
func set_victory():
	MusicPlayer.stop_music(0)
	$%TitleLabel.text = "Victory"
	var difficulty = get_tree().get_first_node_in_group("main").difficulty
	if difficulty == "NORMAL":
		$%DescriptionLabel.text = "You survived! But freedom still eludes you... Try Maniac Mode next!"
	if difficulty == "MANIAC":
		$%DescriptionLabel.text = "You survived! But the battle rages on in Nightmare Mode!"
	if difficulty == "NIGHTMARE":
		$%DescriptionLabel.text = "You survived! But still the Dark Lord holds you captive. If only there were a way to break this cycle..."
	audio_stream_player.stream = victory_theme
	audio_stream_player.play()
