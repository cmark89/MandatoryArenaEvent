extends Node

var difficulty = "NORMAL"
@export var pause_menu: PackedScene

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		add_child(pause_menu.instantiate())
		get_tree().root.set_input_as_handled()
