extends Node2D

@onready var spiked_ball: RigidBody2D = $Spikedball 
@onready var timer: Timer = $Timer # 取得 Timer 節點

# 調整這個值來控制單次推力的大小。
@export var single_impulse_force: float = 600.0 

# ------------------------------------------------------------
# 📌 程式碼主體
# ------------------------------------------------------------

func _ready() -> void:
	# 選擇一個初始推力方向 (例如向右)
	spiked_ball.apply_central_impulse(Vector2(single_impulse_force, 0))

	# 如果 Timer 沒有設定 Autostart，則在這裡啟動
	# timer.start() 


var is_pushing_right: bool = false # 追蹤下一次推力的方向

func _on_timer_timeout() -> void:
	"""每當 Timer 倒數結束時呼叫此函式 (即每 5 秒)"""
	if not is_instance_valid(spiked_ball):
		return
		
	var direction: float
	var push_force: float
	
	# 1. 決定方向和施力
	if is_pushing_right:
		# 下一次推力：向左 (負值)
		direction = -1.0
		is_pushing_right = false
	else:
		# 下一次推力：向右 (正值)
		direction = 1.0
		is_pushing_right = true
		
	push_force = direction * single_impulse_force
	
	# 2. 施加中央衝量
	# 注意：使用 Impulse (衝量) 而不是 Force (力) 
	# 因為我們只在單一時間點施力。
	spiked_ball.apply_central_impulse(Vector2(push_force, 0))
