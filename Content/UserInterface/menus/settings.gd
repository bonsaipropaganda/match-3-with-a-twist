extends Control


@onready var menu_holder: MenuHolder = get_node("/root/Main").get_menu_holder()

# Use your audio to test volume manipulation
# TO-DO: Maybe add a sprite texture showing when the audio is mute or high

# Getting Audio Buses index in bottom panel below
var music_bus = AudioServer.get_bus_index("Music")
var voice_over_bus = AudioServer.get_bus_index("VoiceOver")
var sound_fx_bus = AudioServer.get_bus_index("SoundFx")


func _ready() -> void:
	# Sync slider value with bus value
	%MusicSlider.value = get_bus_volume(music_bus)
	%SoundFxSlider.value = get_bus_volume(sound_fx_bus)


func set_bus_volume(audio_bus, value) -> void:
	AudioServer.set_bus_volume_db(audio_bus, linear_to_db(value))

	if value == 0:
		AudioServer.set_bus_mute(audio_bus, true)
	else:
		AudioServer.set_bus_mute(audio_bus, false)


func get_bus_volume(audio_bus) -> float:
	return db_to_linear(AudioServer.get_bus_volume_db(audio_bus))


func _on_voice_over_slider_value_changed(value):
	set_bus_volume(voice_over_bus, value)


func _on_music_slider_value_changed(value):
	set_bus_volume(music_bus, value)


func _on_sound_fx_slider_value_changed(value):
	set_bus_volume(sound_fx_bus, value)


func _on_back_button_pressed() -> void:
	menu_holder.close_menu()
