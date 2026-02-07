extends Panel
class_name 道具卡片类
var 道具:ItemData#基础类物品StackableData#可堆叠物品
var 物品名称:String
var 物品贴图
var 数量
var 名称详情=false
@onready var 范围: VBoxContainer = $范围
@onready var 图片: TextureRect = $范围/图片
@onready var 特殊标签: Label = $范围/图片/特殊标签
@onready var 名称标签: Label = $范围/名称
@onready var 数量标签: Label = $范围/数量
func _ready() -> void:
	if 道具:
		物品名称=道具.item_name
		var 缓存贴图=道具.icon
		#var 缓存表格=计划.表格.获取表格字典(计划.表格.创世蓝图,-1,物品名称)
		#var 缓存贴图=load(缓存表格.get("icon",""))
		if 缓存贴图:
			物品贴图=缓存贴图
		if 道具 is StackableData:
			数量=道具.数量
		else :
			数量=1
		图片.texture=物品贴图
		if 道具 is 标准物品:
			特殊标签.text=道具.特殊标签
		else :
			特殊标签.text=""
		名称标签.text=物品名称
		数量标签.text=str(数量)
	名称标签.visible=名称详情
	var 文本长度: int = 物品名称.length()
	var 目标宽度: int = 120 if 文本长度 >= 6 else 100
	名称标签.custom_minimum_size=Vector2(目标宽度,35)
	#名称标签.set_size(名称标签.get_combined_minimum_size())
	范围.set_size(范围.get_combined_minimum_size())
	范围.position=Vector2(5,5)
	custom_minimum_size=范围.size+Vector2(10,10)
	size=custom_minimum_size
func 调整位置():
	范围.position=Vector2((size.x-范围.size.x)/2,5)
#func _process(delta: float) -> void:
	#调整位置()
