extends Resource
class_name 建筑资源
@export var 方块名称:String=""
@export var 文本数据:String=""
@export var 储物空间:Array[标准物品]=[]
@export var 产物:标准物品
@export var 耗时:float=1.0
@export var 产量:int=10
@export var 时间戳:float=-1
var 产物产量:Dictionary={
	"铁锭":{"耗时":5,"产量":10,"产物":"铁锭"},
	"纤维":{"耗时":5,"产量":10,"产物":"纤维"},
	"鞣革":{"耗时":5,"产量":10,"产物":"鞣革"},
	"麻布":{"耗时":5,"产量":10,"产物":"麻布"},
}
func _init(名称:String="") -> void:
	if not 名称=="":
		方块名称=名称
func 点数加工(物品:标准物品=null)->标准物品:
	var 当前时间:float=Time.get_unix_time_from_system()
	if 物品:
		if not 产物产量.has(物品.item_name):
			GBIS.moving_item_service.安全清除移动物品(物品)
			计划.语法糖通知("该物品不能作为点数材料")
			return
		if not 储物空间.is_empty() and not 储物空间[0]==物品:
			GBIS.moving_item_service.安全清除移动物品(储物空间[0])
			储物空间.clear()
			计划.语法糖通知("已将残留物品储存入背包")
		if 储物空间.is_empty():
			储物空间.append(物品)
			时间戳=当前时间
		if 产物 and not 产物.item_name==物品.item_name:
			计划.获得物品语法糖(产物.item_name,产物.数量,"点数")
			产物=null
		if not 产物:
			var 产物名:=物品.item_name
			产物=标准物品.new(1,产物产量[产物名].产物)
			产物.数量=0
			产物.特殊标签="点数"
			耗时=产物产量[产物名].耗时
			产量=产物产量[产物名].产量
		if 当前时间-时间戳>=耗时:
			var 完成次数=int((当前时间-时间戳)/耗时)
			if 完成次数>物品.数量:
				完成次数=物品.数量
			时间戳+=耗时*完成次数
			产物.数量+=完成次数*产量
			物品.数量-=完成次数
			if 物品.数量<=0:
				储物空间.clear()
	else :
		储物空间.clear()
	if 储物空间.is_empty():
		return null
	return 物品
func 耗时计算():
	if 产物:
		var 当前时间:float=Time.get_unix_time_from_system()
		return 当前时间-时间戳
	return 1
