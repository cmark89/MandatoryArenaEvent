extends PanelContainer

signal purchased
@onready var animation_player = $AnimationPlayer

@onready var name_label: Label = $%NameLabel
@onready var description_label: Label = $%DescriptionLabel
@onready var icon = $%Icon
@onready var audio_stream_player_click = $AudioStreamPlayer_Click
@onready var purchase_button = %PurchaseButton
@onready var upgrade_cost = %UpgradeCost
@onready var count_label = %CountLabel
@onready var price_container = %PriceContainer

var upgrade: MetaUpgrade
var can_purchase
var handling_input = false

func _ready():
	purchase_button.pressed.connect(on_purchase_pressed)


func set_meta_upgrade(meta_upgrade: MetaUpgrade):
	name_label.text = meta_upgrade.title
	description_label.text = meta_upgrade.description
	icon.texture = meta_upgrade.icon
	upgrade = meta_upgrade
	
	upgrade_cost.text = str(round(get_next_level_xp_cost()))


func get_next_level_xp_cost():
	var base_cost = upgrade.xp_cost
	if upgrade.max_quantity == 1 || upgrade.cost_increase_per_level == 0:
		return base_cost
	var current_level = MetaProgression.get_upgrade_quantity(upgrade.id)
	return base_cost + (upgrade.cost_increase_per_level * min(current_level, upgrade.max_quantity - 1))


func on_purchase_pressed():
	if upgrade == null:
		return
		
	if can_purchase && !handling_input:
		select_card()
		MetaProgression.add_meta_upgrade(upgrade, get_next_level_xp_cost())
		purchased.emit(self)
		get_tree().call_group("meta_upgrade_card", "update_progress")


func select_card():
	handling_input = true
	animation_player.play("selected")
	await animation_player.animation_finished
	handling_input = false


func update_progress():
	var owned_upgrades = MetaProgression.get_upgrade_quantity(upgrade.id)
	var max_upgrades = upgrade.max_quantity
	upgrade_cost.text = str(get_next_level_xp_cost())
	count_label.text = "Purchased: %d/%d" % [owned_upgrades, max_upgrades]
	can_purchase = owned_upgrades < max_upgrades && MetaProgression.get_currency() >= get_next_level_xp_cost()
	purchase_button.disabled = !can_purchase
	
	if owned_upgrades== max_upgrades:
		purchase_button.text = "Sold Out!"
		%PriceContainer.visible = false

