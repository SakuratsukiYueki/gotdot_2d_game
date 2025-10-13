extends CharacterBody2D

@export var speed: float = 60.0 # 敵人移動速度

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var gravity = 980

var direction: float = 1.0 # 1.0 = 右, -1.0 = 左

func _ready() -> void:
	'pass'
	# 連接訊號，當玩家進入攻擊區域時執行


func _physics_process(delta: float) -> void:
	# 根據方向設定速度
	velocity.x = direction * speed
	if not is_on_floor():
		velocity.y += gravity * delta
		move_and_slide()
		return

	# 執行移動，並將結果存入一個變數
	var was_colliding = move_and_slide()

	# 如果碰到物體，就變換方向
	if was_colliding:
		# 取得所有碰撞資訊
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			# 檢查碰撞的法線方向，判斷是否為側面碰撞
			if abs(collision.get_normal().x) > 0.1:
				direction *= -1.0
				animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h # 翻轉圖片
				break # 變換方向後就離開迴圈


# 當有物理物體進入 AttackArea 時呼叫
func _on_hitbox_body_entered(body: Node2D) -> void:
	# 檢查進入區域的物體是否在 "players" 分組中
	if body.is_in_group("players"):
		print("敵人碰到玩家了！")
		# 呼叫玩家腳本上的 take_damage 函數
