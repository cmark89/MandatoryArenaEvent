extends Button

@onready var audio_stream_player = $AudioStreamPlayer

func _ready():
	pressed.connect(on_pressed)


func on_pressed():
	audio_stream_player.pitch_scale = randf_range(0.9,1.2)
	audio_stream_player.play()
