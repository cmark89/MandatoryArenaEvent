extends Node

signal experience_vial_collected(number)
signal healing_vial_collected(number)
signal ability_upgrade_added(upgrade:AbilityUpgrade, current_upgrades: Dictionary)
signal player_damaged
signal game_time_elapsed
signal blood_orb_collected
signal spawn_lesser_chads
signal spawn_gladiators
signal spawn_executed
signal spawn_ghosts
signal shake_camera
signal true_last_boss_killed
signal tutorial_closed
signal play_global_click_sound

func emit_experience_vial_collected(number: float):
	experience_vial_collected.emit(number)

func emit_ability_upgrade_added(upgrade:AbilityUpgrade, current_upgrades: Dictionary):
	ability_upgrade_added.emit(upgrade, current_upgrades)

func emit_player_damaged():
	player_damaged.emit()

func emit_game_time_elapsed():
	game_time_elapsed.emit()

func emit_healing_vial_collected(number: float):
	healing_vial_collected.emit(number)

func emit_blood_orb_collected():
	blood_orb_collected.emit()

func emit_spawn_lesser_chads():
	spawn_lesser_chads.emit()

func emit_spawn_gladiators():
	spawn_gladiators.emit()

func emit_spawn_executed():
	spawn_executed.emit()


func emit_spawn_ghosts():
	spawn_ghosts.emit()

func emit_shake_camera():
	shake_camera.emit()

func emit_true_last_boss_killed():
	true_last_boss_killed.emit()

func emit_tutorial_closed():
	tutorial_closed.emit()

func emit_play_global_click_sound():
	play_global_click_sound.emit()
