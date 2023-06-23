extends Node

@export var spawn_clips: Array[FinalBossVoiceLine] = []
@export var blood_orb_clips: Array[FinalBossVoiceLine] = []
@export var shooting_clips: Array[FinalBossVoiceLine] = []
@export var laughing_clips: Array[FinalBossVoiceLine] = []
@export var bubble_storm_clips: Array[FinalBossVoiceLine] = []
@export var trap_create_clips: Array[FinalBossVoiceLine] = []
@export var trap_spring_clips: Array[FinalBossVoiceLine] = []
@export var low_health_clip: FinalBossVoiceLine
@export var death_clip: FinalBossVoiceLine

@onready var audio_stream_player = $AudioStreamPlayer


const spawn_clip_chance = 1.00
const blood_orb_clip_chance = 1.00
const shoot_clip_chance = 0.25
const bubble_storm_clip_chance = 1.00
const laugh_clip_chance = 0.30
const trap_create_clip_chance = 0.20
const trap_spring_clip_chance = 1.00
const low_health_clip_chance = 1.00
const death_clip_chance = 1.00

var subtitles: Node

var playing_audio = false
func _ready():
	spawn_clips.shuffle()
	shooting_clips.shuffle()
	laughing_clips.shuffle()
	bubble_storm_clips.shuffle()
	trap_create_clips.shuffle()
	trap_spring_clips.shuffle()
	subtitles = get_tree().get_first_node_in_group("subtitles")


func play_clip(clip: FinalBossVoiceLine):
	var stream = clip.file as AudioStream
	playing_audio = true
	audio_stream_player.stream = stream
	audio_stream_player.play()
	if clip.text != null && clip.text != "":
		subtitles.set_text(clip.text, clip.file.get_length() + 0.5)
	await audio_stream_player.finished
	playing_audio = false

func play_spawn_audio():
	if playing_audio:
		return
	if spawn_clips.size() > 0 && randf() < spawn_clip_chance:
		var clip = spawn_clips.pick_random()
		play_clip(clip)

func play_blood_orb_audio():
	if playing_audio:
		return
	if blood_orb_clips.size() > 0 && randf() < blood_orb_clip_chance:
		var clip = blood_orb_clips.pick_random()
		play_clip(clip)

func play_bubble_storm_audio():
	if playing_audio:
		return
	if bubble_storm_clips.size() > 0 && randf() < bubble_storm_clip_chance:
		var clip = bubble_storm_clips.pick_random()
		play_clip(clip)

func play_shoot_audio():
	if playing_audio:
		return
	if shooting_clips.size() > 0 && randf() < shoot_clip_chance:
		var clip = shooting_clips.pick_random()
		play_clip(clip)

func play_laugh_audio():
	if playing_audio:
		return
	if laughing_clips.size() > 0 && randf() < laugh_clip_chance:
		var clip = laughing_clips.pick_random()
		play_clip(clip)

func play_trap_create_audio():
	if playing_audio:
		return
	if trap_create_clips.size() > 0 && randf() < trap_create_clip_chance:
		var clip = trap_create_clips.pick_random()
		play_clip(clip)


func play_trap_spring_audio():
	if playing_audio:
		return
	if trap_spring_clips.size() > 0 && randf() < trap_spring_clip_chance:
		var clip = trap_spring_clips.pick_random()
		play_clip(clip)


func play_low_health_audio():
	if playing_audio:
		await audio_stream_player.finished
	play_clip(low_health_clip)

func play_death_audio():
	if playing_audio:
		audio_stream_player.stop()
	play_clip(low_health_clip)
