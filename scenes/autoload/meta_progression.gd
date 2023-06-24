extends Node

const SAVE_FILE_PATH = "user://game.save"

var tutorial_screen = preload("res://scenes/main/first_boot_screen.tscn")

var save_data: Dictionary = {
	"tutorial_seen" = false,
	"window_mode" = DisplayServer.WINDOW_MODE_FULLSCREEN,
	"sfx_volume" = 1,
	"music_volume" = 1,
	"meta_upgrade_currency" = 0,
	"meta_upgrades" = {},
	"bestiary_progress" = {
		"vermin": true,
		"failed_wizard": false,
		"shadow_bat": false,
		"ratfink": false
	}
}

func _ready():
	GameEvents.experience_vial_collected.connect(on_experience_vial_connected)
	
	load_save_file()
	apply_loaded_settings()
	if !save_data["tutorial_seen"]:
		var tutorial_screen_instance = tutorial_screen.instantiate()
		get_tree().get_root().add_child.call_deferred(tutorial_screen_instance)

func load_save_file():
	if !FileAccess.file_exists(SAVE_FILE_PATH):
		return
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	save_data = file.get_var()


func save():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(save_data)

func add_meta_upgrade(upgrade: MetaUpgrade, total_cost):
	if !save_data["meta_upgrades"].has(upgrade.id):
		save_data["meta_upgrades"][upgrade.id] = {
			"quantity": 0
		}
		
	save_data["meta_upgrades"][upgrade.id]["quantity"] += 1
	save_data["meta_upgrade_currency"] -= total_cost
	save()

func save_settings(window_mode: int, sfx_volume: float, music_volume: float):
	save_data["window_mode"] = window_mode
	save_data["sfx_volume"] = sfx_volume
	save_data["music_volume"] = music_volume
	save()


func apply_loaded_settings():
	var mode = save_data["window_mode"]
	DisplayServer.window_set_mode(mode)
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	else:
		var width = ProjectSettings.get_setting("display/window/size/viewport_width")
		var height = ProjectSettings.get_setting("display/window/size/viewport_height")
		DisplayServer.window_set_size(Vector2(width*2,height*2))

	var bus_index = AudioServer.get_bus_index("SFX")
	var volume_db = linear_to_db(save_data["sfx_volume"])
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	
	bus_index = AudioServer.get_bus_index("Music")
	volume_db = linear_to_db(save_data["music_volume"])
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	

func on_experience_vial_connected(number: float):
	save_data["meta_upgrade_currency"] += number


func get_currency():
	return save_data["meta_upgrade_currency"]


func has_upgrade(id: String):
	return save_data["meta_upgrades"].has(id)


func get_upgrade_quantity(id: String):
	if !save_data["meta_upgrades"].has(id):
		return 0
	return save_data["meta_upgrades"][id]["quantity"]


func has_bestiary_entry(id: String):
	if id.is_empty():
		return
		
	if !save_data["bestiary_progress"].has(id):
		save_data["bestiary_progress"][id] = false
	
	return save_data["bestiary_progress"][id]	


func add_bestiary_entry(id: String):
	save_data["bestiary_progress"][id] = true

func closed_totorial():
	save_data["tutorial_seen"] = true
	save()
