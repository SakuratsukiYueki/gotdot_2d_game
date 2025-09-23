extends CharacterBody2D

# 引用 AnimatedSprite2D 節點 (角色動畫)
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
# 引用煙塵 AnimatedSprite2D 節點
@onready var effects: AnimatedSprite2D = $AnimatedSprite2D/effects

# 速度變數
@export var speed = 100.0
@export var run_speed_multiplier = 2
@export var jump_velocity = -400.0
@export var gravity = 980.0

# 攀爬變數
@export var climb_speed = 150.0
var is_on_ladder = false
var can_climb = false

# 二段跳變數
var jump_count = 0
@export var max_jumps = 2

# 新增一個變數來追蹤是否剛從地面起跳
var was_on_floor = true

# 新增跳躍冷卻變數
var can_jump = true
@export var jump_cooldown = 0.2  # 0.2 秒的冷卻時間

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
		anim.play("Climb")
		was_on_floor = false
	else:
		# 處理跳躍和二段跳
		if is_on_floor():
			jump_count = 0
			was_on_floor = true
			can_jump = true # 回到地面時重置冷卻
		else:
			was_on_floor = false
			
		if Input.is_action_just_pressed("ui_accept") and can_jump:
			if is_on_floor():
				velocity.y = jump_velocity
				jump_count = 1
				anim.play("Jump") # 播放第一次跳躍動畫
				set_jump_cooldown()
			elif jump_count < max_jumps:
				velocity.y = jump_velocity
				jump_count += 1
				anim.play("Jump") # 播放二段跳動畫
				play_dust_effect()
				set_jump_cooldown()
		
		# 處理移動和跑步
		var direction = Input.get_axis("ui_left", "ui_right")
		var current_speed = speed
		if Input.is_action_pressed("ui_shift"):
			current_speed *= run_speed_multiplier


		if direction:
			velocity.x = direction * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)

		# 根據角色狀態播放動畫
		if is_on_floor():
			if direction and Input.is_action_pressed("ui_shift"):
				anim.play("Run")
			elif direction:
				anim.play("Walk")
			else:
				anim.play("idle")
		
		# 將角色翻轉邏輯移到 if is_on_floor() 之外，以處理空中移動
		if direction:
			anim.flip_h = direction < 0
			
	move_and_slide()

# 播放煙塵效果的函數
func play_dust_effect():
		# 顯示節點，然後播放動畫
		effects.show()
		effects.play("Double_Jump_Dust")
		
		# 連接訊號，當動畫播完後，呼叫 effects 節點的 hide() 方法
		# CONNECT_ONE_SHOT 確保這個連接只觸發一次
		effects.connect("animation_finished", Callable(effects, "hide"), CONNECT_ONE_SHOT)

# 設定跳躍冷卻計時器
func set_jump_cooldown():
	can_jump = false
	
	var timer = get_tree().create_timer(jump_cooldown, false)
	timer.timeout.connect(reset_jump_cooldown)

# 重置跳躍冷卻狀態
func reset_jump_cooldown():
	can_jump = true

func _on_climb_area_body_entered(body):
	if body.name == "Player":
		can_climb = true

func _on_climb_area_body_exited(body):
	if body.name == "Player":
		can_climb = false
