extends CharacterBody2D

# ==================== 節點引用 ====================
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var effects: AnimatedSprite2D = $effects
@onready var main_sm: LimboHSM # 狀態機將在 _ready() 中實例化

# ==================== 屬性設定 ====================
@export var speed = 100.0
@export var run_speed_multiplier = 2.0
@export var jump_velocity = -400.0
@export var gravity = 980.0
@export var climb_speed = 150.0
@export var max_jumps = 2
@export var jump_cooldown = 0.2

# ==================== 狀態變數 ====================
var is_on_ladder = false
var can_climb = false
var jump_count = 0
var can_jump = true
var is_dead: bool = false # 角色的死亡狀態

# 狀態機狀態物件
var climb_state: LimboState 


func _ready() -> void:
	instate_state_machine()
	# 連接動畫結束訊號，用於在 Death 動畫結束後處理場景重載
	anim.animation_finished.connect(_on_animation_finished) 


func _physics_process(delta):
	# --- 0. 死亡檢查 (最高優先級) ---
	if is_dead:
		# 確保狀態機進入 Die 狀態
		if main_sm.get_active_state().name != "die":
			main_sm.dispatch(&"to_die")
		
		# 即使在 Die 狀態中，也要讓重力將角色拉到地面
		if not is_on_floor():
			velocity.y += gravity * delta
			
		move_and_slide()
		return # 死亡後，跳過所有輸入和移動邏輯

	# --- 1. 物理計算 ---
	if not is_on_floor() and not is_on_ladder:
		velocity.y += gravity * delta

	# 判斷是否可以攀爬
	if can_climb and Input.is_action_pressed("ui_up"):
		is_on_ladder = true
	else:
		is_on_ladder = false

	# 處理移動和輸入
	var direction = Input.get_axis("ui_left", "ui_right")
	var current_speed = speed
	
	if Input.is_action_pressed("ui_shift"):
		current_speed *= run_speed_multiplier
	
	if direction != 0:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

	flip_sprite(direction)

	# 重置跳躍計數
	if is_on_floor():
		jump_count = 0
		can_jump = true

	# --- 2. 狀態分派 ---
	
	# 優先級 1: 攀爬 
	if is_on_ladder:
		if main_sm.get_active_state() != climb_state: 
			main_sm.dispatch(&"to_climb")
	elif main_sm.get_active_state() == climb_state:
		main_sm.dispatch("state_ended") 

	# 優先級 2: 跳躍/二段跳
	elif Input.is_action_just_pressed("ui_accept") and can_jump:
		if is_on_floor():
			velocity.y = jump_velocity
			jump_count = 1
			main_sm.dispatch(&"to_jump")
			set_jump_cooldown()
		elif jump_count < max_jumps:
			velocity.y = jump_velocity
			jump_count += 1
			main_sm.dispatch(&"to_doublejump")
			set_jump_cooldown()
			
	# 狀態機更新
	main_sm.update(delta)
	
	move_and_slide()


# ==================== 輔助函數 ====================

func flip_sprite(direction):
	if direction == 1:
		anim.flip_h = false
	elif direction == -1:
		anim.flip_h = true
		
func play_animation(animation_name: String):
	if anim.get_animation() != animation_name:
		anim.play(animation_name)

func play_dust_effect():
	effects.show()
	effects.play("Double_Jump_Dust")
	effects.animation_finished.connect(effects.hide.bind(), CONNECT_ONE_SHOT)

func set_jump_cooldown():
	can_jump = false
	var timer = get_tree().create_timer(jump_cooldown)
	timer.timeout.connect(reset_jump_cooldown)

func reset_jump_cooldown():
	can_jump = true

# 處理動畫播放結束訊號
func _on_animation_finished():
	# 如果是死亡動畫播放完畢，則重載場景
	if anim.get_animation() == "Death":
		print("Death animation finished. Reloading scene.")
		# 這裡可以替換成您遊戲的 "Game Over" 畫面切換邏輯
		get_tree().reload_current_scene()


# ==================== 狀態機設定 (LimboHSM) ====================

func instate_state_machine():
	main_sm = LimboHSM.new()
	add_child(main_sm)
	
	# --- 狀態定義 ---
	var idle_state = LimboState.new().named("idle").call_on_enter(idle_start).call_on_update(idle_update)
	var walk_state = LimboState.new().named("walk").call_on_enter(walk_start).call_on_update(walk_update)
	var run_state = LimboState.new().named("run").call_on_enter(run_start).call_on_update(run_update)
	var jump_state = LimboState.new().named("jump").call_on_enter(jump_start).call_on_update(jump_update)
	var doublejump_state = LimboState.new().named("doublejump").call_on_enter(doublejump_start).call_on_update(doublejump_update)
	var die_state = LimboState.new().named("die").call_on_enter(die_start).call_on_update(die_update) 
	
	climb_state = LimboState.new().named("climb").call_on_enter(climb_start).call_on_update(climb_update)

	main_sm.add_child(idle_state)
	main_sm.add_child(walk_state)
	main_sm.add_child(run_state)
	main_sm.add_child(jump_state)
	main_sm.add_child(doublejump_state)
	main_sm.add_child(climb_state)
	main_sm.add_child(die_state) 

	main_sm.initial_state = idle_state
	
	# --- 狀態轉換定義 (Transitions) ---
	
	# 最高優先級：死亡
	main_sm.add_transition(main_sm.ANYSTATE, die_state, &"to_die")

	# 核心轉換
	main_sm.add_transition(main_sm.ANYSTATE, jump_state, &"to_jump")
	main_sm.add_transition(main_sm.ANYSTATE, doublejump_state, &"to_doublejump")
	main_sm.add_transition(main_sm.ANYSTATE, climb_state, &"to_climb") 
	main_sm.add_transition(main_sm.ANYSTATE, idle_state, &"state_ended") 
	
	# 地面核心動作轉換
	main_sm.add_transition(idle_state, walk_state, &"to_walk")
	main_sm.add_transition(idle_state, run_state, &"to_run")
	main_sm.add_transition(walk_state, run_state, &"to_run")
	main_sm.add_transition(run_state, walk_state, &"to_walk_back") 
	
	# 跳躍狀態的落地轉換
	main_sm.add_transition(jump_state, idle_state, &"jump_landed_idle")
	main_sm.add_transition(jump_state, walk_state, &"jump_landed_walk")
	main_sm.add_transition(jump_state, run_state, &"jump_landed_run")
	main_sm.add_transition(doublejump_state, idle_state, &"jump_landed_idle")
	main_sm.add_transition(doublejump_state, walk_state, &"jump_landed_walk")
	main_sm.add_transition(doublejump_state, run_state, &"jump_landed_run")

	main_sm.initialize(self)
	main_sm.set_active(true)

# ==================== 狀態函數 (State Functions) ====================

func idle_start():
	play_animation("idle")
func idle_update(delta:float):
	if velocity.x != 0:
		if Input.is_action_pressed("ui_shift"):
			main_sm.dispatch(&"to_run")
		else:
			main_sm.dispatch(&"to_walk")
		
func walk_start():
	play_animation("Walk")
func walk_update(delta:float):
	if velocity.x == 0:
		main_sm.dispatch("state_ended") 
	elif Input.is_action_pressed("ui_shift"):
		main_sm.dispatch(&"to_run") 
		
func run_start():
	play_animation("Run")
func run_update(delta:float):
	if velocity.x == 0:
		main_sm.dispatch("state_ended") 
	elif not Input.is_action_pressed("ui_shift"):
		main_sm.dispatch(&"to_walk_back") 
		
func jump_start():
	play_animation("Jump")
func jump_update(delta:float):
	if is_on_floor():
		if velocity.x != 0:
			if Input.is_action_pressed("ui_shift"):
				main_sm.dispatch(&"jump_landed_run")
			else:
				main_sm.dispatch(&"jump_landed_walk")
		else:
			main_sm.dispatch(&"jump_landed_idle")
			
func doublejump_start():
	play_animation("Jump")
	play_dust_effect()
func doublejump_update(delta:float):
	if is_on_floor():
		if velocity.x != 0:
			if Input.is_action_pressed("ui_shift"):
				main_sm.dispatch(&"jump_landed_run")
			else:
				main_sm.dispatch(&"jump_landed_walk")
		else:
			main_sm.dispatch(&"jump_landed_idle")
			
func climb_start():
	play_animation("Climb")
func climb_update(delta:float):
	var climb_direction = Input.get_axis("ui_down", "ui_up")
	
	if climb_direction == 0:
		anim.stop()
	else:
		anim.play("Climb")

# --- 死亡狀態函數 ---
func die_start():
	play_animation("Death") 
	velocity.x = 0
	velocity.y = 0 
	
func die_update(delta:float):
	# 死亡後，只處理重力，等待動畫結束重啟場景
	pass
