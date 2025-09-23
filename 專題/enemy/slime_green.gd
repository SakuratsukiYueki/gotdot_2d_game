extends CharacterBody2D

# 速度變數
@export var speed: float = 80.0
# 敵人的移動範圍
@export var walk_range: float = 150.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

var direction: float = 1.0 # 1.0 代表向右，-1.0 代表向左
var start_x: float = 0.0

func _ready() -> void:
	start_x = global_position.x
	anim.play("Run")
	
func _physics_process(delta: float) -> void:
	# 處理水平移動
	velocity.x = direction * speed
	
	# 檢查是否超出移動範圍，然後變換方向
	if direction == 1.0 and global_position.x > start_x + walk_range:
		direction = -1.0
		anim.flip_h = false
	elif direction == -1.0 and global_position.x < start_x - walk_range:
		direction = 1.0
		anim.flip_h = true
	
	# 讓怪物移動，並檢查是否碰到牆壁或物體
	var was_colliding = move_and_slide()
	
	# 如果碰到物體，就變換方向
	if was_colliding:
		# 檢查是否撞到牆壁
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider(): # 假設你的牆壁節點在 "walls" 分組中
				direction *= -1.0
				anim.flip_h = !anim.flip_h # 反轉圖片
				break # 跳出迴圈，因為已經變換方向
				
# 偵測進入攻擊範圍的物體
func _on_hitbox_body_entered(body: Node2D) -> void:
	# 這裡你可以檢查 body 是否是玩家，並對其造成傷害
	if body.has_method("take_damage"):
		body.take_damage(10) # 假設敵人造成 10 點傷害
