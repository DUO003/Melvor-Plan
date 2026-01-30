extends Resource
class_name 梅点数
@export var 点数字典:Dictionary={}
func _init() -> void:
	var 梅存档:Dictionary=计划.梅存档
	if 梅存档.is_empty():
		return
	if 梅存档.has("手工") and 梅存档.手工.has("基础资源") and 梅存档.手工.基础资源.has("贤者点数"):
		增加点数("贤者点数",int(梅存档.手工.基础资源.贤者点数))
		梅存档.手工.基础资源.erase("贤者点数")
# 核心判断：指定点数是否足够消耗，修复原代码0点数的判断bug
func 消耗点数判断(点数名称:String, 消耗量:int) -> bool:
	# 1. 先判断变量是否存在且是int类型 2. 消耗量必须是正整数 3. 点数≥消耗量
	var 点数数量 = 查看点数(点数名称)
	if 点数数量 is int and 消耗量 >= 0 and 点数数量 >= 消耗量:
		return true
	return false
# 核心操作：消耗指定点数，成功返回true，失败返回false
func 消耗点数(点数名称:String, 消耗量:int) -> bool:
	if 消耗点数判断(点数名称, 消耗量):
		var 剩余点数 = 查看点数(点数名称) - 消耗量
		点数字典[点数名称]=剩余点数
		return true
	return false
# 新增：增加指定点数
func 增加点数(点数名称:String, 增加量:int):
	var 点数数量 = 查看点数(点数名称)
	if 点数数量 is int and 增加量 > 0:
		点数字典[点数名称]=点数数量 + 增加量
func 查看点数(点数名称:String)->int:
	return 点数字典.get(点数名称,0)
