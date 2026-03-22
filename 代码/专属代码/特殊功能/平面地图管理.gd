extends Node
class_name 梅地图
@warning_ignore("unused_signal")
##当玩家进入可交互目标位置时又交互目标发出
signal 更新_交互(增加:bool,内容:String,节点:Node,强制:bool)
@warning_ignore("unused_signal")
##快捷栏物品更新后发出
signal 更新_快捷键栏()
@warning_ignore("unused_signal")
##期望玩家前往到当前坐标
signal 玩家导航(目标:float)
@warning_ignore("unused_signal")
##当传送门
signal 传送门更新()
@warning_ignore("unused_signal")
##当生命值法力护盾变化时触发
signal 伤害跳字(数值:float,位置:Vector2,类型:String)
var 交互字典:Dictionary={}
##编号从0计数默认快捷键1
var 快捷栏编号:int=0
var 背包单利:ContainerRepository
var 方块背包:ContainerData
var 快捷键字典:Dictionary[int,物品方块]={}
var 方块检查器:检查器方块
var 背包检查器:检查器背包

var 子弹管理器:Node2D=null
var 关卡战线:float=0

##游历地图切换
var 接触传送点:bool=false
var 传送点有效:bool=false
## 地图图块搜索算法[br]
## 返回值: Array[Vector2i] - 所有符合条件的图块坐标数组
func 搜索图块(地图图块: TileMapLayer, 目标源ID: int, 目标图集坐标: Vector2i) -> Array[Vector2i]:
	# 存储所有符合条件的坐标
	var 符合条件的坐标数组: Array[Vector2i] = []
	
	# 安全校验：确保传入的地图图块节点有效
	if 地图图块 == null:
		push_warning("搜索算法：传入的地图图块节点为空！")
		return 符合条件的坐标数组
	
	# 获取地图中所有已使用的格子坐标
	var 所有已使用格子: Array[Vector2i] = 地图图块.get_used_cells()
	
	# 遍历每个已使用的格子，检查匹配条件
	for 方块坐标:Vector2i in 所有已使用格子:
		# 获取当前格子的源ID
		var 当前源ID: int = 地图图块.get_cell_source_id(方块坐标)
		# 获取当前格子的图集坐标
		var 当前图集坐标: Vector2i = 地图图块.get_cell_atlas_coords(方块坐标)
		
		# 检查是否同时匹配源ID和图集坐标
		if 当前源ID == 目标源ID and 当前图集坐标 == 目标图集坐标:
			符合条件的坐标数组.append(方块坐标)
	
	# 返回最终匹配的坐标数组
	return 符合条件的坐标数组
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
