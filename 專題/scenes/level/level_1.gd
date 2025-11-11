extends Node2D
@onready var dude_monster: CharacterBody2D = $Dude_monster

func _ready() -> void:
	get_tree().paused = false
