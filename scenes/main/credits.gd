extends CanvasLayer

signal back_pressed

var index = 0
@onready var back_button = %BackButton

func _ready():
	back_button.pressed.connect(on_back_pressed)

func on_back_pressed():
	back_pressed.emit()
