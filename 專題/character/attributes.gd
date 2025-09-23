extends Node

class_name Attributes

# 血量屬性
@export_group("Health")
@export var max_health: int = 100
var current_health: int = 100:
	set(value):
		current_health = clamp(value, 0, max_health)
		if current_health <= 0:
			emit_signal("died") # 之後可以改為 emit_signal("died")

# 攻擊屬性
@export_group("Attack")
@export var attack_damage: int = 20

# 移動屬性
@export_group("Movement")
@export var move_speed: float = 200.0
@export var run_speed_multiplier: float = 2.0
@export var jump_force: float = 400.0

# -----------------
# 屬性相關的函數
# -----------------

# 增加血量
func heal(amount: int):
	current_health += amount

# 扣除血量
func take_damage(amount: int):
	current_health -= amount

# 獲取角色當前的跑速
func get_current_run_speed() -> float:
	return move_speed * run_speed_multiplier
