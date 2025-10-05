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

## 当前存放的物品数据列表
@export_storage var items: Array[ItemData] = []
## 物品到占据网格的映射(Array[grid_id: Vector2i])
@export_storage var item_grids_map: Dictionary[ItemData, Array]
## 格子到物品的映射
@export_storage var grid_item_map: Dictionary[Vector2i, ItemData] = {}

## 构造函数
@warning_ignore("shadowed_variable")
func _init(container_name: String = GBIS.DEFAULT_INVENTORY_NAME, columns: int = 0, rows: int = 0, avilable_types: Array[String] = []) -> void:
	self.container_name = container_name
	self.avilable_types = avilable_types
	self.columns = columns
	self.rows = rows
	for row in rows:
		for col in columns:
			var pos = Vector2i(col, row)
			grid_item_map[pos] = null

## 清空重启
func clear() -> void:
	items = []
	item_grids_map = {}
	for row in rows:
		for col in columns:
			var pos = Vector2i(col, row)
			grid_item_map[pos] = null

## 深度复制当前库存数据
func deep_duplicate() -> ContainerData:
	var ret = ContainerData.new(container_name, columns, rows, avilable_types)
	for item_data in item_grids_map.keys():
		ret.item_grids_map[item_data.duplicate()] = item_grids_map[item_data].duplicate(true)
	ret.items.append_array(ret.item_grids_map.keys())
	for item in ret.items:
		var grids = ret.item_grids_map[item]
		for grid in grids:
			ret.grid_item_map[grid] = item
	return ret

## 添加物品到库存，返回物品占用的网格坐标列表
func add_item(item_data: ItemData) -> Array[Vector2i]:
	if not is_item_avilable(item_data):
		return []
	var grids = _find_first_availble_grids(item_data)
	_add_item_to_grids(item_data, grids)
	return grids

## 从库存中移除物品，返回是否移除成功
func remove_item(item: ItemData) -> bool:
	if items.has(item):
		var grids = item_grids_map[item]
		for grid in grids:
			grid_item_map[grid] = null
		items.erase(item)
		item_grids_map.erase(item)
		return true
	return false

## 检查物品是否可以被放入当前库存
func is_item_avilable(item_data: ItemData) -> bool:
	if item_data is 物品装备:
		return avilable_types.has(item_data.type)
	return avilable_types.has("ANY") or avilable_types.has(item_data.type)

## 根据物品数据查找其占用的网格坐标列表
func find_grids_by_item_data(item_data: ItemData) -> Array[Vector2i]:
	return item_grids_map.get(item_data, [] as Array[Vector2i])

## 检查库存中是否包含指定物品
func has_item(item: ItemData) -> bool:
	return items.has(item)

## 根据网格坐标查找对应的物品数据
func find_item_data_by_grid(grid_id: Vector2i) -> ItemData:
	return grid_item_map.get(grid_id)

## 尝试将物品添加到指定网格位置，返回实际占用的网格坐标列表
func try_add_to_grid(item_data: ItemData, grid_id: Vector2i) -> Array[Vector2i]:
	if not is_item_avilable(item_data):
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
func _add_item_to_grids(item_data: ItemData, grids: Array[Vector2i]) -> bool:
	if not grids.is_empty():
		items.append(item_data)
		item_grids_map[item_data] = grids
		for grid in grids:
			grid_item_map[grid] = item_data
		return true
	return false

## 查找第一个可用的网格位置来放置物品
func _find_first_availble_grids(item: ItemData) -> Array[Vector2i]:
	var item_shape = item.get_shape()
	for row in rows:
		for col in columns:
			# 如果当前格子中没有东西，则判断能否放下这个物品的形状
			if grid_item_map[Vector2i(col, row)] == null:
				var grids = _try_get_empty_grids_by_shape(Vector2i(col, row), item_shape)
				if not grids.is_empty():
					return grids
	return []

## 尝试根据物品形状获取从指定位置开始的空网格
func _try_get_empty_grids_by_shape(start: Vector2i, shape: Vector2i) -> Array[Vector2i]:
	var ret: Array[Vector2i] = []
	for row in shape.y:
		for col in shape.x:
			var grid_id = Vector2i(start.x + col, start.y + row)
			if grid_item_map.has(grid_id) and grid_item_map[grid_id] == null:
				ret.append(grid_id)
			else:
				return []
	return ret
