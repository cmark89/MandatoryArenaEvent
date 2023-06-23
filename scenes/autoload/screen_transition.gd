extends CanvasLayer

signal transition_halfway

@onready var animation_player = $AnimationPlayer

func _ready():
	visible = false

func transition():
	visible = true
	animation_player.play("in")
	await transition_halfway
	
	animation_player.play("out")
	await animation_player.animation_finished
	visible = false

func emit_transition_halfway():
	transition_halfway.emit()
	
