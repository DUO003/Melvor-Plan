extends Label
class_name 右键取消物品

func _ready() -> void:
	text = "右键取消"
	visible = true
	var standard_theme: Theme = preload("res://界面/主题/标准界面.tres")
	self.theme = standard_theme


var 右键已按下: bool = false
var 右键已抬起: bool = false

func _process(_delta: float) -> void:
	# Label跟随鼠标移动
	global_position = get_global_mouse_position() + Vector2(-64, 64)
	
	# 1. 检测右键按下（仅在未按下时标记）
	if Input.is_action_pressed("inv_use"):
		if 右键已抬起 and not 右键已按下:
			右键已按下 = true
	# 2. 检测右键松开（已按下且当前未按住，即完整点击）
	if not Input.is_action_pressed("inv_use"):
		if 右键已按下:
			右键取消物品逻辑()
		if not 右键已抬起:
			右键已抬起=true
func 右键取消物品逻辑() -> void:
	GBIS.moving_item_service.安全清除移动物品()
