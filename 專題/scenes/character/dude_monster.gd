extends CharacterBody2D

# ==================== 節點引用 ====================
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var effects: AnimatedSprite2D = $effects 
@onready var main_sm: LimboHSM 
@onready var ladder_ray_cast: RayCast2D = $ladderRayCast
# 引用 TileMapLayer 節點 (請確認路徑正確)
@onready var tile_map_layer: TileMapLayer = $"../TileMapLayer" 
@onready var marker_2d: Marker2D = $Marker2D


# ==================== 屬性設定 ====================
@export var base_speed = 200.0 # 基礎速度
@export var run_speed_multiplier = 1.6
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
var is_dead: bool = false 
var climb_state: LimboState

func _ready() -> void:
	# 確保這個函數定義在腳本中是頂級的
	instate_state_machine() 
	anim.animation_finished.connect(_on_animation_finished)

# -----------------------------------------------------------
## 輔助函數：獲取圖塊移動修正值
# -----------------------------------------------------------
func get_tile_movement_modifier() -> float:
	if not is_on_floor():
		return 1.0

	var tile_coords = tile_map_layer.local_to_map(marker_2d.global_position)
	print("角色所在圖塊座標: ", tile_coords)
	
	var tile_data: TileData = tile_map_layer.get_cell_tile_data(tile_coords)
	
	if tile_data:
		print("找到 TileData。正在檢查 movement_modifier...")
		# 讀取名為 "movement_modifier" 的自訂浮點數值
		var modifier = tile_data.get_custom_data("movement_modifier")
		
		if modifier != null:
			print("找到修正值: ", float(modifier))
			return float(modifier)
			
	print("未找到有效修正值，返回 1.0")
	return 1.0

# -----------------------------------------------------------
## 主要物理更新
# -----------------------------------------------------------
func _physics_process(delta):
	# --- 0. 死亡檢查 (最高優先級) ---
	if is_dead:
		if main_sm.get_active_state().name != "die":
			main_sm.dispatch(&"to_die")
		
		if not is_on_floor():
			velocity.y += gravity * delta
			
		move_and_slide()
		return

	# --- 1. 梯子偵測與狀態設定 ---
	ladder_ray_cast.force_raycast_update()
	var ladder_detected = ladder_ray_cast.is_colliding()
	
	can_climb = ladder_detected
	
	if main_sm.get_active_state().name == "climb" and not can_climb:
		is_on_ladder = false

	# --- 2. 物理計算：重力控制 ---
	if not is_on_floor() and not is_on_ladder:
		velocity.y += gravity * delta
	elif is_on_ladder:
		velocity.y = 0

	# -----------------------------------------------------------
	# 處理移動、輸入與圖塊效果
	# -----------------------------------------------------------
	var direction = Input.get_axis("ui_left", "ui_right")
	
	var modifier = get_tile_movement_modifier()
	var effective_base_speed = base_speed * modifier
	
	var current_speed = effective_base_speed
	if Input.is_action_pressed("ui_shift"):
		current_speed *= run_speed_multiplier

	if direction != 0:
		if not is_on_ladder:
			velocity.x = direction * current_speed
		else:
	# 如果在梯子上，則水平速度為 0
			velocity.x = 0
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

	flip_sprite(direction)

	# 重置跳躍計數
	if is_on_floor():
		jump_count = 1
		can_jump = true
	# -----------------------------------------------------------

	# --- 3. 狀態分派 ---
	
	# 優先級 1: 攀爬 
	if can_climb and Input.is_action_pressed("ui_up"):
		is_on_ladder = true
		if main_sm.get_active_state() != climb_state: 
			main_sm.dispatch(&"to_climb")
	elif main_sm.get_active_state() == climb_state:
		if not is_on_ladder:
			main_sm.dispatch("state_ended") 

	# 優先級 2: 跳躍/二段跳
	if not is_on_ladder:
		if Input.is_action_just_pressed("ui_accept") and can_jump:
			
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
	
	# 處理從梯子上跳躍
	elif is_on_ladder and Input.is_action_just_pressed("ui_accept"):
		is_on_ladder = false 
		velocity.y = jump_velocity
		jump_count = 1
		main_sm.dispatch(&"to_jump")
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
	# 使用 CONNECT_ONE_SHOT 確保動畫播完後只隱藏一次
	effects.animation_finished.connect(effects.hide.bind(), CONNECT_ONE_SHOT)

func set_jump_cooldown():
	can_jump = false
	var timer = get_tree().create_timer(jump_cooldown)
	timer.timeout.connect(reset_jump_cooldown)

func reset_jump_cooldown():
	can_jump = true

# 處理動畫播放結束訊號 (死亡後重載)
func _on_animation_finished():
	if anim.get_animation() == "Death":
		print("Death animation finished. Reloading scene.")
		get_tree().reload_current_scene()


# ==================== 狀態機設定 ====================

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
	main_sm.add_transition(main_sm.ANYSTATE, die_state, &"to_die")
	main_sm.add_transition(main_sm.ANYSTATE, jump_state, &"to_jump")
	main_sm.add_transition(main_sm.ANYSTATE, doublejump_state, &"to_doublejump")
	main_sm.add_transition(main_sm.ANYSTATE, climb_state, &"to_climb") 
	main_sm.add_transition(main_sm.ANYSTATE, idle_state, &"state_ended") 
	main_sm.add_transition(idle_state, walk_state, &"to_walk")
	main_sm.add_transition(idle_state, run_state, &"to_run")
	main_sm.add_transition(walk_state, run_state, &"to_run")
	main_sm.add_transition(run_state, walk_state, &"to_walk_back") 
	main_sm.add_transition(jump_state, idle_state, &"jump_landed_idle")
	main_sm.add_transition(jump_state, walk_state, &"jump_landed_walk")
	main_sm.add_transition(jump_state, run_state, &"jump_landed_run")
	main_sm.add_transition(doublejump_state, idle_state, &"jump_landed_idle")
	main_sm.add_transition(doublejump_state, walk_state, &"jump_landed_walk")
	main_sm.add_transition(doublejump_state, run_state, &"jump_landed_run")

	main_sm.initialize(self)
	main_sm.set_active(true)

# ==================== 狀態函數 ====================

func idle_start():
	play_animation("idle")
func idle_update(_delta:float):
	if velocity.x != 0:
		if Input.is_action_pressed("ui_shift"):
			main_sm.dispatch(&"to_run")
		else:
			main_sm.dispatch(&"to_walk")
		
func walk_start():
	play_animation("Walk")
func walk_update(_delta:float):
	if velocity.x == 0:
		main_sm.dispatch("state_ended") 
	elif Input.is_action_pressed("ui_shift"):
		main_sm.dispatch(&"to_run") 
		
func run_start():
	play_animation("Run")
func run_update(_delta:float):
	if velocity.x == 0:
		main_sm.dispatch("state_ended") 
	elif not Input.is_action_pressed("ui_shift"):
		main_sm.dispatch(&"to_walk_back") 
		
func jump_start():
	play_animation("Jump")
	AudioManager.play_sfx("jump")
func jump_update(_delta:float):
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
	AudioManager.play_sfx("jump")
	play_dust_effect() 
func doublejump_update(_delta:float):
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
	AudioManager.play_sfx("climb")
	
func climb_update(_delta:float):
	var climb_direction_y = Input.get_axis("ui_up", "ui_down") 
	var climb_direction_x = Input.get_axis("ui_left", "ui_right")
	
	var input_direction = Vector2(climb_direction_x, climb_direction_y)
	
	if input_direction.length() > 0:
		velocity = input_direction.normalized() * climb_speed
		
		anim.play("Climb")
		AudioManager.play_sfx("climb")
		if climb_direction_x == 1:
			anim.flip_h = false
		elif climb_direction_x == -1:
			anim.flip_h = true

	else:
		velocity.x = 0
		velocity.y = 0
		anim.stop() 

# --- 死亡狀態函數 ---
func die_start():
	play_animation("Death") 
	AudioManager.play_sfx("death")
	velocity.x = 0
	velocity.y = 0 
	
func die_update(_delta:float):
	pass
