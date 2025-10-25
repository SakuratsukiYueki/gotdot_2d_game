extends Node2D

func _ready() -> void:
	get_tree().paused = false
	AudioManager.play_music("snow")
