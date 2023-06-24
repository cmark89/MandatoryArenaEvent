extends CanvasLayer

signal back_pressed
@onready var back_button = %BackButton

@onready var window_button: Button = %WindowButton
@onready var sfx_slider: Slider = %SfxSlider
@onready var music_slider: Slider = %MusicSlider

func _ready():
	window_button.pressed.connect(on_window_button_pressed)
	sfx_slider.value_changed.connect(on_audio_slider_changed.bind("SFX"))
	music_slider.value_changed.connect(on_audio_slider_changed.bind("Music"))
	back_button.pressed.connect(on_back_pressed)
	update_display()


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		get_tree().root.set_input_as_handled()
		back_pressed.emit()


func get_bus_volume_percent(bus_name: String):
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume_db)


func set_volume_percent(bus_name: String, percent: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = linear_to_db(percent)
	AudioServer.set_bus_volume_db(bus_index, volume_db)


func update_display():
	window_button.text = "Windowed"
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		window_button.text = "Fullscreen"
		
	sfx_slider.value = get_bus_volume_percent("SFX")
	music_slider.value = get_bus_volume_percent("Music")


func on_window_button_pressed():
	var mode = DisplayServer.window_get_mode()
	if mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		var width = ProjectSettings.get_setting("display/window/size/viewport_width")
		var height = ProjectSettings.get_setting("display/window/size/viewport_height")
		DisplayServer.window_set_size(Vector2(width*2,height*2))
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	update_display()


func on_audio_slider_changed(value: float, bus_name: String):
	set_volume_percent(bus_name, value)


func on_back_pressed():
	MetaProgression.save_settings(DisplayServer.window_get_mode(), get_bus_volume_percent("SFX"), get_bus_volume_percent("Music"))
	back_pressed.emit()
