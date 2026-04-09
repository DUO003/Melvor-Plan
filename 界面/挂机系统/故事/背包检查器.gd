extends Panel
class_name 检查器背包
@onready var 关闭: Button = $关闭
@onready var 背包: InventoryView = %背包
@onready var 方块背包: InventoryView = %方块背包
func _ready() -> void:
	横版单例.背包检查器=self
	关闭.pressed.connect(切换)
	visible=false
	方块背包.背包内容更新.connect(刷新背包快捷栏)
func 关闭背包():
	visible=false
	GBIS.moving_item_service.安全清除移动物品()
func 切换():
	visible= not visible
	GBIS.moving_item_service.安全清除移动物品()
var 更新背包状态:bool=true
func 刷新背包快捷栏():
	#print("更新背包")
	if 更新背包状态:
		更新背包状态=false
		await get_tree().process_frame
		横版单例.获取背包消息()
		更新背包状态=true
