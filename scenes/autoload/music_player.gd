extends AudioStreamPlayer

var normal_battle_theme = preload("res://assets/audio/SurviveOrDie_IfYouWantToIGuess.mp3")
var true_last_boss_theme = preload("res://assets/audio/PrayINeverFindYou.mp3")
var menu_theme = preload("res://assets/audio/EnterTheArena.mp3")
var ending_theme = preload("res://assets/audio/WhenNoBloodRemainsToSpill.mp3")

var default_volume

func _ready():
	default_volume = volume_db


func play_normal_battle_theme():
	reset_volume()
	stream = normal_battle_theme
	play()


func play_menu_theme():
	reset_volume()
	stream = menu_theme
	play()

func play_true_last_boss_theme():
	volume_db = 5
	reset_volume()
	stream = true_last_boss_theme
	play()


func play_ending_theme():
	reset_volume()
	stream = ending_theme
	play()


func stop_music(fade_time: float):
	if (fade_time <= 0):
		stop()
		
	# TODO: Test this works
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -50, fade_time)
	tween.tween_callback(stop)
	
	await tween.finished
	reset_volume()


func reset_volume():
	volume_db = default_volume
