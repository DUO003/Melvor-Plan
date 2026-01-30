extends Resource
## 库存数据类，管理物品在网格中的存储和操作
class_name ContainerData

## 库存列数
@export_storage var columns: int = 2
## 库存行数
@export_storage var rows: int = 2
## 库存名称
@export_storage var container_name: String
## 允许存放的物品类型列表
@export_storage var avilable_types: Array[String]
#var 物品类型映射:Dictionary={"标准":标准物品,"装备":物品装备,"宝石":物品宝石,"方块":物品方块,}
## 物品到占据网格的映射(Array[grid_id: Vector2i])
@export_storage var item_grids_map: Dictionary[ItemData, Array]
## 当前存放的物品数据列表
var items: Array[ItemData] = []
## 格子到物品的映射
var 背包_格子_物品映射: Dictionary[Vector2i, ItemData] = {}
## 保存所有空格子
var 空格子数组:Array[Vector2i]=[]

## 构造函数
@warning_ignore("shadowed_variable")
func _init(默认名:String = GBIS.DEFAULT_INVENTORY_NAME, 宽度: int = 1, 高度: int = 1,标签: Array[String] = []) -> void:
	container_name = 默认名
	avilable_types = 标签
	columns = 宽度
	rows = 高度
	更新背包参数()
func 更新背包参数():
	for row in rows:
		for col in columns:
			var 格 = Vector2i(col, row)
			if not 背包_格子_物品映射.has(格):
				背包_格子_物品映射[格] = null
				空格子数组.append(格)
# 背包Y轴扩容方法（仅增加行数，纯数据层面，不处理UI）
# 参数：扩容数量 - 必须≥1，代表要新增的行数
func 扩容_增加行数(扩容数量: int) -> void:
	if 扩容数量 < 1:
		push_error("背包扩容失败：扩容数量必须大于等于1，当前传入值为：", 扩容数量)
		return
	var 原有总行数 = rows
	var 新总行数 = 原有总行数 + 扩容数量
	var 新增行起始索引 = 原有总行数
	var 新增行结束索引 = 新总行数 - 1
	for 新增行索引 in range(新增行起始索引, 新增行结束索引 + 1):
		for 列索引 in columns:# 遍历原有列数（仅扩Y轴，列数保持不变）
			var 新格子坐标 = Vector2i(列索引, 新增行索引)# 生成新格子的坐标
			if not 背包_格子_物品映射.has(新格子坐标):# 安全校验：避免重复初始化已有格子
				背包_格子_物品映射[新格子坐标] = null# 初始化新格子为null
				空格子数组.append(新格子坐标)
	rows = 新总行数
	print("背包【", container_name, "】扩容完成：原有行数=", 原有总行数, "，新行数=", 新总行数, "，新增行数=", 扩容数量)
##清空背包
func clear() -> void:
	items = []
	item_grids_map = {}
	for row in rows:
		for col in columns:
			var 格 = Vector2i(col, row)
			背包_格子_物品映射[格] = null
	更新空格子数组()
## 深度复制当前库存数据_初始化会使用
func deep_duplicate() -> ContainerData:#创建新的容器数据实例
	var ret = ContainerData.new(container_name, columns, rows, avilable_types)
	for item_data in item_grids_map.keys():
		ret.item_grids_map[item_data.duplicate()] = item_grids_map[item_data].duplicate(true)
	ret.items=ret.item_grids_map.keys()#更新物品列表
	for 物品 in ret.items:#重建映射 格子→物品
		var 格组 = ret.item_grids_map[物品]
		for 格 in 格组:
			ret.背包_格子_物品映射[格] = 物品
	return ret#返回副本

## 添加物品到库存，返回物品占用的网格坐标列表
func add_item(物品: ItemData) -> Array[Vector2i]:
	if not 检查物品类型(物品):
		return []
	var 占用网格 = 查找位置(物品)
	_add_item_to_grids(物品, 占用网格)
	return 占用网格

## 从库存中移除物品，返回是否移除成功
func 从库存移除(物品: ItemData,禁用排序:bool=false) -> bool:
	if items.has(物品):
		var 格组 = item_grids_map[物品]
		for 格 in 格组:
			背包_格子_物品映射[格] = null
		items.erase(物品)
		item_grids_map.erase(物品)
		if not 禁用排序:更新空格子数组()
		return true
	return false
## 移除大量物品时,降低排序的消耗,返回成功次数
func 从库存批量移除物品(物品数组:Array[ItemData])->int:
	var 移除次数:int=0
	for 物品 in 物品数组:
		if 从库存移除(物品,true):移除次数+=1
	更新空格子数组()
	return 移除次数
## 从库存中移除物品，返回是否移除成功
func remove_item(物品: ItemData) -> bool:#旧方法名称
	return 从库存移除(物品)
## 检查物品是否可以被放入当前库存
func 检查物品类型(物品: ItemData) -> bool:
	if 物品 is 物品装备:
		return avilable_types.has("装备")
	if 物品 is 物品宝石:
		return avilable_types.has("宝石")
	if 物品 is 物品方块:
		return avilable_types.has("方块")
	return avilable_types.has("ANY") or avilable_types.has(物品.type)

## 根据物品数据查找其占用的网格坐标列表
func find_grids_by_item_data(item_data: ItemData) -> Array[Vector2i]:
	return item_grids_map.get(item_data, [] as Array[Vector2i])

## 检查库存中是否包含指定物品
func has_item(item: ItemData) -> bool:
	return items.has(item)

## 根据网格坐标查找对应的物品数据
func find_item_data_by_grid(grid_id: Vector2i) -> ItemData:
	return 背包_格子_物品映射.get(grid_id)

## 尝试将物品添加到指定网格位置，返回实际占用的网格坐标列表
func try_add_to_grid(item_data: ItemData, grid_id: Vector2i) -> Array[Vector2i]:
	if not 检查物品类型(item_data):
		return []
	var grids = _try_get_empty_grids_by_shape(grid_id, item_data.get_shape())
	_add_item_to_grids(item_data, grids)
	return grids

## 根据物品名称查找所有匹配的物品数据
func find_item_data_by_item_name(item_name: String) -> Array[ItemData]:
	var ret: Array[ItemData] = []
	for item in items:
		if item.item_name == item_name:
			ret.append(item)
	return ret

## 将物品添加到指定网格位置，返回是否添加成功
func _add_item_to_grids(item_data: ItemData, 占用网格: Array[Vector2i]) -> bool:
	if not 占用网格.is_empty():
		items.append(item_data)
		item_grids_map[item_data] = 占用网格
		for 格 in 占用网格:
			背包_格子_物品映射[格] = item_data
			空格子数组.erase(格)
		return true
	计划.语法糖通知("物品%s添加失败"%item_data.item_name,"物品添加%s"%item_data.item_name)
	return false
func 更新空格子数组():
	var 所有空格子:Array[Vector2i] = []
	for row in rows:
		for col in columns:
			var 当前格子 = Vector2i(col, row)
			if 背包_格子_物品映射[当前格子] == null:
				所有空格子.append(当前格子)
	空格子数组=所有空格子
## 查找第一个可用的网格位置来放置物品
func 查找位置(物品: ItemData) -> Array[Vector2i]:
	var 物品形状 = 物品.get_shape()
	if 空格子数组.is_empty():
		更新空格子数组()
	for 起始格子 in 空格子数组:
		var 可用格子组 = _try_get_empty_grids_by_shape(起始格子, 物品形状)
		if not 可用格子组.is_empty():
			return 可用格子组
	return []
## 查找第一个可用的网格位置来放置物品
func _find_first_availble_grids(物品: ItemData) -> Array[Vector2i]:#旧版本名称
	return 查找位置(物品)
## 尝试根据物品形状获取从指定位置开始的空网格
func _try_get_empty_grids_by_shape(start: Vector2i, shape: Vector2i) -> Array[Vector2i]:
	var ret: Array[Vector2i] = []
	for row in shape.y:
		for col in shape.x:
			var grid_id = Vector2i(start.x + col, start.y + row)
			if 背包_格子_物品映射.has(grid_id) and 背包_格子_物品映射[grid_id] == null:
				ret.append(grid_id)
			else:
				return []
	return ret
## 整理背包物品（物品排列 + 可堆叠物品合并）
func 整理物品() -> void:
	GBIS.整理背包.emit()
	var 备份物品列表: Array[ItemData] = items.duplicate()# 1. 备份当前所有物品
	if 备份物品列表.is_empty():#背包为空停止逻辑
		print("背包【", container_name, "】暂无物品需要整理")
		return
	clear()# 2. 清空当前背包的所有数据
	备份物品列表.sort_custom(func(物品A: ItemData, 物品B: ItemData) -> bool:
		return 物品A.排序值() < 物品B.排序值())# 3. 按物品的排序值升序排序
	var 堆叠上限处理: Array[ItemData]
	for 待处理物品 in 备份物品列表:
		if 待处理物品 is StackableData:
			#print("容量",待处理物品.堆叠上限)
			if 待处理物品.数量>=待处理物品.堆叠上限:
				var 真实数量=待处理物品.数量
				var 容量:int=待处理物品.堆叠上限
				for i in ceili(待处理物品.数量*1.0/容量):
					var 克隆物品=待处理物品.duplicate()
					克隆物品.堆叠上限=待处理物品.堆叠上限
					if 真实数量>=容量:
						克隆物品.数量 = 容量
					else :
						克隆物品.数量 = 真实数量
					真实数量-=容量
					堆叠上限处理.append(克隆物品)
			else :堆叠上限处理.append(待处理物品)
		else  :堆叠上限处理.append(待处理物品)
	var 合并后物品列表: Array[ItemData] = []#可堆叠物品合并逻辑
	for 待处理物品 in 堆叠上限处理:
		if 待处理物品 is StackableData:# 仅处理继承自StackableData的可堆叠物品
			# 检查合并列表最后一个是否是同名称的可堆叠物品（排序后同名称必然连续）
			if (not 合并后物品列表.is_empty() and 合并后物品列表[-1] is StackableData 
			and 合并后物品列表[-1].item_name == 待处理物品.item_name):
				var 目标物品: StackableData = 合并后物品列表[-1]
				# 计算目标物品可接收的剩余数量（堆叠上限 - 当前数量）
				var 可合并数量 = min(目标物品.堆叠上限 - 目标物品.数量, 待处理物品.数量)
				if 可合并数量 > 0:# 合并数量到目标物品
					目标物品.数量 += 可合并数量
					待处理物品.数量 -= 可合并数量
				if 待处理物品.数量 > 0:# 若当前物品仍有剩余数量，加入合并列表；否则丢弃
					合并后物品列表.append(待处理物品)
			else:# 无同名称前置物品，直接加入合并列表
				合并后物品列表.append(待处理物品)
		else:# 非可堆叠物品，直接加入合并列表
			合并后物品列表.append(待处理物品)
	var 放入失败物品列表: Array[ItemData] = []
	for 待放入物品 in 合并后物品列表:# 4. 依次将合并后的物品重新放入背包
		var 实际占用网格 = add_item(待放入物品)
		if 实际占用网格.is_empty():# 检查物品是否成功放入
			放入失败物品列表.append(待放入物品)
			push_warning("背包【", container_name, "】整理时放入物品失败：", 
				待放入物品.item_name, "（排序值：", 待放入物品.排序值(), "）")
	GBIS.sig_inv_refresh.emit()#发送信号更新背包
