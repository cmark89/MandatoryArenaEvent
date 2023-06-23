extends AudioStreamPlayer2D

func play_damage_sound(damage_sound: AudioStream):
	if damage_sound == null:
		return
		
	stream = damage_sound
	pitch_scale = randf_range(0.8, 1.2)
	play()
