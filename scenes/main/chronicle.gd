extends CanvasLayer

signal back_pressed

@export var entries: Array[ChronicleEntry]
@onready var previous_entry_button = $MarginContainer/HBoxContainer/PreviousEntryButton
@onready var next_entry_button = $MarginContainer/HBoxContainer/NextEntryButton
@onready var back_button = %BackButton
@onready var name_label = %name
@onready var description_label = %Description
@onready var scroll_container = $MarginContainer/HBoxContainer/VBoxContainer/PanelContainer/VBoxContainer/MarginContainer2/ScrollContainer

var index = 0

func _ready():
	back_button.pressed.connect(on_back_pressed)
	next_entry_button.pressed.connect(on_next_entry_pressed)
	previous_entry_button.pressed.connect(on_previous_entry_pressed)
	set_page(0)
	
func set_page(new_index: int):
	var entry = entries[new_index]
	name_label.text = entry.name
	description_label.text = entry.description
	
	scroll_container.scroll_vertical = 0
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
