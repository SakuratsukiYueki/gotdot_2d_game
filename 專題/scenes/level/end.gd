extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "C:/Users/a0968/Desktop/gotdot_2d_game/專題/scenes/menu/Menu.tscn")


func _on_button_2_pressed() -> void:
	get_tree().quit()
