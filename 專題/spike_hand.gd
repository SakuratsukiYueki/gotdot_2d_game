extends Node2D

@export var attack_distance: float = 100.0
@export var attack_speed: float = 300.0

@onready var attack_area: Area2D = $Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var player_detector: RayCast2D = $Area2D/PlayerDetector
@onready var attack_timer: Timer = $AttackTimer

var can_attack: bool = true
var original_position: Vector2

func _ready() -> void:
	original_position = attack_area.global_position
	player_detector.target_position.y = attack_distance

func _physics_process(_delta: float) -> void:
	if player_detector.is_colliding():
		attack()

func attack():
	if !can_attack:
		return

	can_attack = false
	animated_sprite_2d.play("blink")
	attack_timer.start()

	move_to_position(original_position + Vector2(0, attack_distance))

func move_to_position(target_position: Vector2):
	var distance = attack_area.global_position.distance_to(target_position)
	var time_to_move = distance / attack_speed

	var tween = get_tree().create_tween()
	tween.tween_property(attack_area, "global_position", target_position, time_to_move).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(0.1)
	tween.tween_property(attack_area, "global_position", original_position, time_to_move).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func _on_attack_timer_timeout() -> void:
	can_attack = true
