extends CanvasLayer

signal back_pressed

@export var entries: Array[BestiaryEntry]
@onready var previous_entry_button = $MarginContainer/HBoxContainer/PreviousEntryButton
@onready var next_entry_button = $MarginContainer/HBoxContainer/NextEntryButton
@onready var back_button = %BackButton
@onready var name_label = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/VBoxContainer/name
@onready var image = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/MarginContainer/Control/Image
@onready var description_label = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/MarginContainer2/ScrollContainer/Description
@onready var scroll_container = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/MarginContainer2/ScrollContainer


var index = 0

func _ready():
	back_button.pressed.connect(on_back_pressed)
	next_entry_button.pressed.connect(on_next_entry_pressed)
	previous_entry_button.pressed.connect(on_previous_entry_pressed)
	set_page(0)
	
func set_page(new_index: int):
	var entry = entries[new_index]
	var unlocked = MetaProgression.has_bestiary_entry(entry.id)
	name_label.text = entry.name
	description_label.text = entry.description
	image.texture = entry.image
	image.modulate = Color.WHITE
	scroll_container.scroll_vertical = 0
	
	if !unlocked:
		name_label.text = "???"
		description_label.text = "ENTRY MISSING"
		image.modulate = Color.BLACK
	
	previous_entry_button.disabled = new_index <= 0
	next_entry_button.disabled = new_index >= entries.size() - 1


func on_next_entry_pressed():
	if index + 1 < entries.size():
		index += 1
		set_page(index)

func on_previous_entry_pressed():
	if index - 1 >= 0:
		index -= 1
		set_page(index)

func on_back_pressed():
	back_pressed.emit()
