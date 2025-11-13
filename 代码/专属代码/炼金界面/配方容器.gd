extends Control
var 当前值=10
var 道具名称=null
func _ready() -> void:
	gui_input.connect(鼠标信号处理)
	$"输入".value_changed.connect(func(_值):更新文本())
	$"输入".value=当前值
	更新文本()
func 更新文本():
	$"数量".text=str(int($"输入".value))
func 鼠标信号处理(鼠标信号):
	if 鼠标信号 is InputEventMouseButton and not 鼠标信号.pressed:
		if GBIS.has_moving_item():
			$"图片".texture=GBIS.moving_item_service.moving_item.icon
			GBIS.moving_item_service.安全清除移动物品()
			
