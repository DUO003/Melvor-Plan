extends Node
class_name 梅地图
@warning_ignore("unused_signal")
##当玩家进入可交互目标位置时又交互目标发出
signal 更新_交互(增加:bool,内容:String,节点:Node,强制:bool)
@warning_ignore("unused_signal")
##快捷栏物品更新后发出
signal 更新_快捷键栏()
var 交互字典:Dictionary={}
##编号从0计数默认快捷键1
var 快捷栏编号:int=0
var 背包单利:ContainerRepository
var 方块背包:ContainerData
var 快捷键字典:Dictionary[int,物品方块]={}
var 方块检查器:检查器方块
var 背包检查器:检查器背包
func _ready() -> void:
	更新_交互.connect(交互保存)
	获取背包消息()
func 获取背包消息():
	背包单利=ContainerRepository.instance
	方块背包=背包单利.get_container("方块背包")
	var 物品数据:Dictionary=方块背包.背包_格子_物品映射
	快捷键字典={}
	var 已加载物品:Dictionary[物品方块,bool]={}
	var 序号=1
	#print(Vector2i(方块背包.columns,方块背包.rows),物品数据)
	for 列 in 方块背包.columns:
		for 行 in 方块背包.rows:
			var 格 = Vector2i(列,行)
			if 物品数据.has(格):
				var 物品=物品数据[格]
				if 物品 and 物品 is 物品方块 :
					if not 已加载物品.has(物品):
						快捷键字典[序号]=物品
						已加载物品[物品]=true
						序号+=1
			if 序号>9:
				更新_快捷键栏.emit()
				return
	if 快捷栏编号>=1 and not 快捷键字典.has(快捷栏编号):
		快捷栏编号=0
	更新_快捷键栏.emit()
func 交互保存(增加:bool,内容:String,节点:Node,_强制:bool):
	if 增加:
		交互字典[节点]=内容
	else :
		交互字典.erase(节点)
func 返回快捷键物品()->物品方块:
	return 快捷键字典.get(快捷栏编号,null)
##放置物品
func 放置快捷键物品():
	var 快捷物品:=返回快捷键物品()
	if 快捷物品:
		快捷物品.数量+=-1
		if 快捷物品.数量<=0:
			方块背包.从库存移除(快捷物品)
			获取背包消息()
		else :
			更新_快捷键栏.emit()
