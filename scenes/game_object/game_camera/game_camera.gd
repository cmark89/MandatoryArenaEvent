extends Camera2D

var target_position = Vector2.ZERO

@onready var animation_player = $AnimationPlayer
@export var shake_amount = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	GameEvents.shake_camera.connect(on_shake_camera)
	make_current()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	acquire_target()
	global_position = global_position.lerp(target_position, 1.0 - exp(-delta * 20))
	
	if (shake_amount > 0):
		set_offset(Vector2( \
			randf_range(-1.0, 1.0) * shake_amount, \
			randf_range(-1.0, 1.0) * shake_amount \
		))
	else:
		set_offset(Vector2.ZERO)


func acquire_target():
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		var player = player_nodes[0] as Node2D
		target_position = player.global_position
	
func on_shake_camera():
	animation_player.play("shake")
