extends Area2D

# 移除 @onready var timer: Timer = $Timer 的引用，因為不再需要計時器

# 確保連接到 Area2D 的 body_entered 訊號
func _on_body_entered(body: Node2D): 
	# 檢查進入的物體是否為玩家 (Player)
	if body.is_in_group("players"): 
		print("Player has entered Killzone. Triggering Death.")
		
		# 1. 觸發玩家角色的死亡狀態 (這是 Killzone 唯一的職責)
		# 玩家腳本會接收到這個指令，並自行處理動畫和場景重載。
		body.is_dead = true
		
		# 移除 timer.start() 邏輯
