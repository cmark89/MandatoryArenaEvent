extends Node2D
class_name SwordAbility

@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var sprite_2d = $Sprite2D

func set_texture(new_texture: Texture2D):
	sprite_2d.texture = new_texture
