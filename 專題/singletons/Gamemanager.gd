extends Node

# 【重要】請用您的場景路徑替換以下內容。
# 關卡順序清單 (Level1.tscn 是第 0 個，Level2.tscn 是第 1 個，依此類推)
const LEVELS = [
	"C:/Users/a0968/Desktop/gotdot_2d_game/專題/scenes/level/level2.tscn",
	"C:/Users/a0968/Desktop/gotdot_2d_game/專題/scenes/level/level3.tscn",
	"C:/Users/a0968/Desktop/gotdot_2d_game/專題/scenes/level/level4.tscn" # 假設這是倒數第二關
]
# 最後一關結束後要切換到的場景 (感謝畫面)
const END_SCENE = "C:/Users/a0968/Desktop/gotdot_2d_game/專題/scenes/level/end.tscn" 

var current_level_index = 0

# 負責切換到下一個場景或結束遊戲
func go_to_next_level():
	current_level_index += 1

	if current_level_index < LEVELS.size():
		# 還有下一個關卡：切換到下一個場景
		AudioManager.play_sfx("goal")
		var next_scene_path = LEVELS[current_level_index]
		get_tree().call_deferred("change_scene_to_file", next_scene_path)
	else:
		# 所有關卡都已完成：切換到結束畫面
		AudioManager.play_music("victory")
		get_tree().call_deferred("change_scene_to_file", END_SCENE)
