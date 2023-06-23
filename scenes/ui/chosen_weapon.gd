extends MarginContainer

@onready var icon = $Box/Icon
@onready var box = $Box

func set_weapon(weapon: Ability):
	icon.texture = weapon.icon

func set_weapon_texture(weapon_texture: Texture2D):
	icon.texture = weapon_texture

func hide_frame():
	box.texture = null
