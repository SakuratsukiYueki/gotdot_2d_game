extends Control
func _ready():
	$AnimationPlayer.play("RESET")
	current_panel = menu
	_show_panel(menu)
	_update_back_button()
 
	back_button.pressed.connect(_on_back_pressed)
	settings_button.pressed.connect(_navigate_to.bind(main_settings))
	video_button.pressed.connect(_navigate_to.bind(video_settings))
	audio_button.pressed.connect(_navigate_to.bind(audio_settings))
	controls_button.pressed.connect(_navigate_to.bind(controls_settings))

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")

func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func testEsc():
	# 只需要檢查一次 ESC 鍵的按壓
	if Input.is_action_just_pressed("esc"):
		
		# 檢查遊戲是否已暫停
		if get_tree().paused:
			# 情況 1: 遊戲已暫停 (選單已開啟)
			
			# 優先檢查導航堆疊是否有元素
			if nav_stack.size() > 0:
				# 有子選單，執行返回上一層
				_on_back_pressed()
			else:
				# 已經在主選單層級，執行恢復遊戲
				resume()
				
		else:
			# 情況 2: 遊戲正在運行
			pause()


func _on_resume_pressed():
	resume()


func _on_quit_pressed():
	get_tree().quit()

func _process(_delta):
	testEsc()

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()



@onready var panel_container: PanelContainer = $PanelContainer
	
@export var menu: VBoxContainer
@export var main_settings: VBoxContainer
@export var video_settings: VBoxContainer
@export var audio_settings: VBoxContainer
@export var controls_settings: VBoxContainer
@export var back_button: Button
 
@export var settings_button : Button
@export var video_button: Button
@export var audio_button: Button
@export var controls_button: Button
 
var nav_stack: Array[Control] = []
var current_panel
 
func _show_panel(panel: Control):
	panel.visible = true
 
func _update_back_button():
	back_button.visible = nav_stack.size() > 0

 
func _navigate_to(panel: Control):
	if current_panel:
		nav_stack.append(current_panel)
		current_panel.visible = false

	current_panel = panel
	_show_panel(current_panel)
	_update_back_button()
 
func _on_back_pressed():
	if nav_stack.is_empty():
		return
 
	current_panel.visible = false
	current_panel = nav_stack.pop_back()
	_show_panel(current_panel)
	_update_back_button()
 
