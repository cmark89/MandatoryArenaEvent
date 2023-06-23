extends CanvasLayer
@onready var label = $MarginContainer/MarginContainer/Label
@onready var animation_player = $MarginContainer/MarginContainer/AnimationPlayer
@onready var timer = $Timer


func _ready():
	timer.timeout.connect(on_timer_timeout)

func set_text(string: String, wait_time: float):
	if animation_player.is_playing():
		animation_player.stop()
		animation_player.play("RESET")
		await animation_player.animation_finished

	label.text = string
	animation_player.play("show")
	timer.wait_time = wait_time
	timer.start()

func on_timer_timeout():
	animation_player.play("hide")
