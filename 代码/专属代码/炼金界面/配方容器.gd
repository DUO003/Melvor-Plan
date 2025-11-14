extends Control
var 当前值=10
var 道具名称=null
@export var 催化剂:bool=false
@export var 可修改:bool=false
func _ready() -> void:
	$"输入".visible=可修改
	if 可修改:
		gui_input.connect(鼠标信号处理)
		$"输入".value_changed.connect(func(_值):更新文本())
		$"输入".value=当前值
	更新文本()
func 更新文本():
	$"数量".text=str(int($"输入".value))
func 鼠标信号处理(鼠标信号):
	if 鼠标信号 is InputEventMouseButton and not 鼠标信号.pressed:
		if GBIS.has_moving_item():
			var 正在移动的物品=GBIS.moving_item_service.moving_item
			print("正在移动的物品",正在移动的物品)
			道具名称=GBIS.moving_item_service.moving_item.item_name
			if not 催化剂 and 梅表格.缓存蓝图标签[道具名称]=="炼金":
				$"图片".texture=GBIS.moving_item_service.moving_item.icon
			if 催化剂 and 梅表格.缓存蓝图标签[道具名称]=="催化":
				$"图片".texture=GBIS.moving_item_service.moving_item.icon
			GBIS.moving_item_service.安全清除移动物品()
			
