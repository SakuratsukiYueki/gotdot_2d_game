extends Node

var sounds = {
	"death": load("res://assets/audio/SFX/death.wav"),
	"climb": load("res://assets/audio/SFX/Climb.wav"),
	"jump": load("res://assets/audio/SFX/Jump.wav"),
	"press_button": load("res://assets/audio/SFX/press_button.wav"),
	"victory": load("res://assets/audio/music/victory.wav"),
	"desert": load("res://assets/audio/music/desert.wav"),
	"green": load("res://assets/audio/music/green.wav"),
	"main_menu": load("res://assets/audio/music/Main_menu.wav"),
	"snow": load("res://assets/audio/music/snow.wav"),
	"stone": load("res://assets/audio/music/stone.wav"),
	"goal": load("res://assets/audio/SFX/goal.wav"),
}

@onready var sound_players: Array[AudioStreamPlayer] = []
@onready var music_player: AudioStreamPlayer = null

const MAX_SFX: int = 5

func _ready() -> void:
	# 1. 初始化音樂播放器
	music_player = AudioStreamPlayer.new()
	# 設定 Music Bus
	music_player.bus = "Music" 
	add_child(music_player)

	# 2. 初始化音效播放器池
	for i in range(MAX_SFX):
		var player = AudioStreamPlayer.new()
		# 設定 SFX Bus
		player.bus = "SFX"
		add_child(player)
		sound_players.append(player)

func play_sfx(sound_name: String):
	var sound_to_play = sounds.get(sound_name)
	if sound_to_play == null:
		print("Invalid sound name: ", sound_name)
		return

	for sound_player in sound_players:
		if !sound_player.playing:
			sound_player.stream = sound_to_play
			sound_player.play()
			return

func play_music(sound_name: String):
	var music_to_play = sounds.get(sound_name)
	if music_to_play == null:
		print("Invalid music name: ", sound_name)
		return

	stop_music()

	music_player.stream = music_to_play
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.play()

func stop_music():
	if music_player.playing:
		music_player.stop()
		
