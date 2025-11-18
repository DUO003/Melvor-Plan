extends Panel
class_name 道具卡片类
var 道具:ItemData#基础类物品StackableData#可堆叠物品
var 物品名称
var 物品贴图
var 数量
var 详情=false
func _ready() -> void:
	if 道具:
		物品名称=道具.item_name
		var 缓存贴图=道具.icon
		#var 缓存表格=梅表格.获取表格字典(梅表格.装备蓝图,-1,物品名称)
		#var 缓存贴图=load(缓存表格.get("icon",""))
		if 缓存贴图:
			物品贴图=缓存贴图
		if 道具 is StackableData:
			数量=道具.current_amount
		else :
			数量=1
		$"范围/图片".texture=物品贴图
		$"范围/名称".text=物品名称
		$"范围/数量".text=str(数量)
	$"范围/名称".visible=详情
	$"范围".size=Vector2(0,0)
	custom_minimum_size=$"范围".size+Vector2(10,10)
	size=custom_minimum_size
