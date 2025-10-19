extends Area2D

# 假設您的玩家節點已經被您加到名為 "player" 的群組中
# 您可以在玩家節點的「節點」->「群組」中添加它
const PLAYER_GROUP = "players" 

# 當有物理物體（例如 CharacterBody2D）進入 Area2D 區域時觸發
func _on_body_entered(body):
	# 1. 檢查進入的物體是否為玩家
	if body.is_in_group(PLAYER_GROUP):

		# 2. 呼叫 GameManager 進行場景切換
		Gamemanager.go_to_next_level()

		# 3. 觸發後，建議將目標物件從場景中移除或禁用，以防止重複觸發
		# 您也可以選擇性地播放一個音效或動畫
		queue_free()
