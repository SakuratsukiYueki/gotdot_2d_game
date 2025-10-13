extends Control




func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://level/level1.tscn")	
	print('play')
func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options.tscn")
	print('options')
func _on_quit_pressed() -> void:
	get_tree().quit()
