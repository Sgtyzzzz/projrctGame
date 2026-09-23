extends Node

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

# --- MUSIK ---
func play_music():
	if not audio_player.playing:
		audio_player.play()

func stop_music():
	audio_player.stop()

func is_music_playing() -> bool:
	return audio_player.playing

func set_volume(linear_value: float):
	audio_player.volume_db = linear_to_db(linear_value)

func change_music(new_stream: AudioStream):
	audio_player.stream = new_stream
	audio_player.play()


# --- SFX ---
func play_sfx(stream: AudioStream, start_position: float = 0.0):
	if stream:
		sfx_player.stream = stream
		sfx_player.play(start_position)

func set_sfx_volume(linear_value: float):
	sfx_player.volume_db = linear_to_db(linear_value)
