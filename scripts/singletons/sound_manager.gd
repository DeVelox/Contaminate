extends Node
# Music
const MUSIC_NORMAL = preload("res://assets/music/Controlled Chaos - no percussion.ogg")
const MUSIC_COMBAT = preload("res://assets/music/Controlled Chaos.ogg")
const MUSIC_MENU = preload("res://assets/music/344778__rokzroom__dilemma-music-loop.ogg")
# SFX
const BOOM = preload("res://assets/sounds/Boom.ogg")
const DEATH = preload("res://assets/sounds/Death.ogg")
const HIT = preload("res://assets/sounds/Hit.ogg")
const PISTOL = preload("res://assets/sounds/Pistol.ogg")
const ROLL = preload("res://assets/sounds/Roll.ogg")
const WHOOSH = preload("res://assets/sounds/Whoosh.ogg")

# Events

var current_track: AudioStreamPlayer
var rock_shift: AudioStreamPlayer


func sfx(sound: AudioStream, pitch: float = 1) -> AudioStreamPlayer:
	var audio: AudioStreamPlayer = AudioStreamPlayer.new()
	audio.bus = "Sounds"
	audio.stream = sound
	audio.stream.loop = false
	audio.pitch_scale = pitch
	get_tree().current_scene.add_child(audio)
	audio.finished.connect(audio.queue_free)
	audio.play()
	return audio


func event(sound: AudioStream) -> AudioStreamPlayer:
	var audio: AudioStreamPlayer = AudioStreamPlayer.new()
	audio.bus = "Events"
	audio.stream = sound
	audio.stream.loop = false
	get_tree().current_scene.add_child(audio)
	audio.finished.connect(audio.queue_free)
	audio.play()
	return audio


func music(track: AudioStream, loop: bool = true) -> AudioStreamPlayer:
	if is_instance_valid(current_track) and current_track.stream == track:
		return
	var audio: AudioStreamPlayer = AudioStreamPlayer.new()
	audio.process_mode = Node.PROCESS_MODE_ALWAYS
	audio.bus = "Music"
	audio.stream = track
	audio.stream.loop = loop
	get_tree().current_scene.add_child(audio)
	audio.finished.connect(audio.queue_free)
	if is_instance_valid(current_track):
		current_track.queue_free()
	current_track = audio
	audio.play()
	return audio


func crossfade(track: AudioStream, loop: bool = true) -> AudioStreamPlayer:
	if is_instance_valid(current_track) and current_track.stream == track:
		return
	var audio: AudioStreamPlayer = AudioStreamPlayer.new()
	var audio_old = current_track
	audio.process_mode = Node.PROCESS_MODE_ALWAYS
	audio.bus = "Music"
	audio.stream = track
	audio.stream.loop = loop
	audio.volume_db = -60
	get_tree().current_scene.add_child(audio)
	audio.finished.connect(audio.queue_free)
	current_track = audio
	audio.play()

	var tween := create_tween()
	if is_instance_valid(audio_old):
		tween.tween_property(audio_old, "volume_db", -60, 2)
	tween.parallel().tween_property(audio, "volume_db", 0, 2)
	if is_instance_valid(audio_old):
		tween.tween_callback(audio_old.queue_free)
	return audio
