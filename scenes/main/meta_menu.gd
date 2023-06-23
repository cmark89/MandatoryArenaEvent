extends CanvasLayer

signal back_pressed

@export var upgrades: Array[MetaUpgrade] = []
@onready var grid_container = %GridContainer
@onready var currency = %Currency
@onready var back_button = $%BackButton

var meta_upgrade_card_scene = preload("res://scenes/ui/meta_upgrade_card.tscn")

func _ready():
	for child in grid_container.get_children():
		child.queue_free()
	
	back_button.pressed.connect(on_back_pressed)
	currency.text = str(round(MetaProgression.get_currency()))
	for upgrade in upgrades:
		var meta_upgrade_card_instance = meta_upgrade_card_scene.instantiate()
		grid_container.add_child(meta_upgrade_card_instance)
		meta_upgrade_card_instance.set_meta_upgrade(upgrade)
		meta_upgrade_card_instance.update_progress()
		meta_upgrade_card_instance.purchased.connect(on_upgrade_purchased)


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		get_tree().root.set_input_as_handled()
		back_pressed.emit()


func on_upgrade_purchased(meta_upgrade_card_instance: Node):
	currency.text = str(round(MetaProgression.get_currency()))


func update_currency_display():
	currency.text = str(round(MetaProgression.get_currency()))


func on_back_pressed():
	back_pressed.emit()
