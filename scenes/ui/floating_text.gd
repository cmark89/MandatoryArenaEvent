extends Node2D

@onready var label = $Label


func _ready():
	pass
	
	
func start(text: String, is_crit: bool = false, color_override: Color = Color.WHITE):
	var scale_up_value = Vector2.ONE * 1.8
	if is_crit:
		text += "!"
		label.add_theme_color_override("font_color", Color.ORANGE)
		scale_up_value = Vector2.ONE * 2.2
		
	if color_override != Color.WHITE:
		label.add_theme_color_override("font_color", color_override)
		
	label.text = text
		
	var tween = create_tween()
	tween.tween_property(self, "global_position", global_position + (Vector2.UP * 16), 0.3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_position", global_position + (Vector2.UP * 48), 0.5)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(queue_free)
	
	var scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", scale_up_value, 0.2)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	scale_tween.tween_property(self, "scale", Vector2.ONE, 0.2)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	scale_tween.tween_property(self, "scale", Vector2.ZERO, 0.4)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)\
	.set_delay(0.5)
