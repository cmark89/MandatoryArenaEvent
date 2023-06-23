extends CanvasLayer

signal back_pressed
@onready var close_button = %CloseButton

func _ready():
	close_button.pressed.connect(on_close_pressed)

func on_close_pressed():
	MetaProgression.closed_totorial()
	GameEvents.emit_tutorial_closed()
	GameEvents.emit_play_global_click_sound()
	queue_free()
