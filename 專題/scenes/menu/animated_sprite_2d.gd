extends AnimatedSprite2D

# 1. 定義移動參數
const SPEED = 100.0   # 每秒移動的像素數
const MAX_X = 1152.0  # 右邊界
const MIN_X = 0.0     # 左邊界

# 追蹤當前的移動方向：1 代表向右，-1 代表向左
var direction = 1

# --- _process(delta) 函式用於每影格更新 ---
func _process(delta):
	# 2. 檢查邊界並改變方向
	
	# 檢查是否到達右邊界
	if position.x >= MAX_X:
		direction = -1        # 切換為向左移動
		flip_h = true         # 水平翻轉精靈 (面向左)

	# 檢查是否到達左邊界
	elif position.x <= MIN_X:
		direction = 1         # 切換為向右移動
		flip_h = false        # 取消水平翻轉 (面向右)

	# 3. 執行移動
	# 沿 X 軸移動 (速度 * 經過時間 * 方向)
	position.x += SPEED * delta * direction
