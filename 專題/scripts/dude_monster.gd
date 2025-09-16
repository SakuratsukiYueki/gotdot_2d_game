extends CharacterBody2D

# 速度變數
@export var speed = 100.0
@export var run_speed_multiplier = 5
@export var jump_velocity = -400.0
@export var gravity = 980.0

# 攀爬變數
@export var climb_speed = 150.0
var is_on_ladder = false
var can_climb = false

# 二段跳變數
var jump_count = 0
@export var max_jumps = 2

func _physics_process(delta):
	# 處理重力
	if not is_on_floor() and not is_on_ladder:
		velocity.y += gravity * delta

	# 判斷是否在梯子上
	if can_climb and Input.is_action_pressed("ui_up"):
		is_on_ladder = true
	else:
		is_on_ladder = false

	# 處理攀爬
	if is_on_ladder:
		var climb_direction = Input.get_axis("ui_down", "ui_up")
		velocity.y = climb_direction * climb_speed
		velocity.x = 0
	else:
		# 處理跳躍和二段跳
		if is_on_floor():
			jump_count = 0

		if Input.is_action_just_pressed("ui_accept"):
			if is_on_floor() or jump_count < max_jumps:
				velocity.y = jump_velocity
				jump_count += 1

		# 處理移動和跑步
		var direction = Input.get_axis("ui_left", "ui_right")
		var current_speed = speed
		if Input.is_action_pressed("ui_shift"):
			current_speed *= run_speed_multiplier

		if direction:
			velocity.x = direction * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
	
	move_and_slide()

func _on_climb_area_body_entered(body):
	if body.name == "Player":
		can_climb = true

func _on_climb_area_body_exited(body):
	if body.name == "Player":
		can_climb = false
