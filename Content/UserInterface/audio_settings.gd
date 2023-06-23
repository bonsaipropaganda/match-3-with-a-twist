extends Control

# Use your audio to test volume manipulation
# TO-DO: Maybe add a sprite texture showing when the audio is mute or high

# Getting Audio Buses index in bottom panel below
var music_bus = AudioServer.get_bus_index("Music")
var voice_over_bus = AudioServer.get_bus_index("VoiceOver")
var sound_fx_bus = AudioServer.get_bus_index("SoundFx")


func set_bus_volume(audio_bus, value) -> void:
	AudioServer.set_bus_volume_db(audio_bus, value)

	if value == -30:
		AudioServer.set_bus_mute(audio_bus, true)
	else:
		AudioServer.set_bus_mute(audio_bus, false)


func _on_voice_over_slider_value_changed(value):
	set_bus_volume(voice_over_bus, value)


func _on_music_slider_value_changed(value):
	set_bus_volume(music_bus, value)


func _on_sound_fx_slider_value_changed(value):
	set_bus_volume(sound_fx_bus, value)


func _on_back_button_pressed() -> void:
	# TODO: change to previous scene (can be mainmenu / paused menu)
	pass
