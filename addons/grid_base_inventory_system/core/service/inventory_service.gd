extends BaseContainerService
## 背包业务类
class_name InventoryService

## 向背包添加物品
## 如果是可堆叠物品，如果当前数量大于可堆叠数量，会重置为允许的最大值，成功后发射信号 sig_inv_item_updated
## 如果是不可堆叠物品，或堆叠后还有剩余，成功后发射 sig_inv_item_added
func add_item(inv_name: String, item_data: ItemData) -> bool:
	var new_item_data = item_data.duplicate()
	if new_item_data is StackableData:
		if new_item_data.current_amount > new_item_data.stack_size:
			new_item_data.current_amount = new_item_data.stack_size
		var items = find_item_data_by_item_name(inv_name, new_item_data.item_name)
		for item in items:
			if not item.is_full():
				new_item_data.current_amount = item.add_amount(new_item_data.current_amount)
				var new_item_grids = _container_repository.get_container(inv_name).find_grids_by_item_data(item)
				assert(not new_item_grids.is_empty())
				GBIS.sig_inv_item_updated.emit(inv_name, new_item_grids[0])
				if new_item_data.current_amount <= 0:
					return true
	# 增加不可堆叠物品，或堆叠后剩余的物品
	var grids = _container_repository.get_container(inv_name).add_item(new_item_data)
	if not grids.is_empty():
		GBIS.sig_inv_item_added.emit(inv_name, new_item_data, grids)
		return true
	return false

## 尝试把正在移动的物品堆叠到这个格子上
func stack_moving_item(inv_name: String, grid_id: Vector2i) -> void:
	if not GBIS.moving_item_service.moving_item:
		return
	var item_data = find_item_data_by_grid(inv_name, grid_id)
	if not item_data is StackableData:
		return
	if item_data.item_name == GBIS.moving_item_service.moving_item.item_name:
		var amount_left = item_data.add_amount(GBIS.moving_item_service.moving_item.current_amount)
		if amount_left > 0:
			GBIS.moving_item_service.moving_item.current_amount = amount_left
		else:
			GBIS.moving_item_service.clear_moving_item()
		GBIS.sig_inv_item_updated.emit(inv_name, grid_id)

## 尝试放置正在移动的物品到这个格子
func place_moving_item(inv_name: String, grid_id: Vector2i) -> bool:
	if place_to(inv_name, GBIS.moving_item_service.moving_item, grid_id):
		GBIS.moving_item_service.clear_moving_item()
		初始化.保存存档()
		
		return true
	return false

## 使用物品（默认：鼠标右键点击格子）
func use_item(inv_name: String, grid_id: Vector2i) -> bool:
	var item_data = find_item_data_by_grid(inv_name, grid_id)
	if not item_data:
		return false
	if item_data is 标准物品:
		if item_data.物品使用():
			remove_item_by_data(inv_name, item_data)
		else:
			GBIS.sig_inv_item_updated.emit(inv_name, grid_id)
		return true
	elif item_data is EquipmentData:
		if GBIS.equipment_slot_service.try_equip(item_data):
			remove_item_by_data(inv_name, item_data)
			return true
	elif item_data is ConsumableData:
		if item_data.use():
			remove_item_by_data(inv_name, item_data)
		else:
			GBIS.sig_inv_item_updated.emit(inv_name, grid_id)
		return true
	return false

## 分割物品
func split_item(inv_name: String, grid_id: Vector2i, offset: Vector2i, base_size: int) -> ItemData:
	var inv = _container_repository.get_container(inv_name)
	if inv:
		var item = inv.find_item_data_by_grid(grid_id)
		if item and item is StackableData and item.stack_size > 1 and item.current_amount > 1:
			var origin_amount = item.current_amount
			var new_amount_1 = origin_amount / 2
			var new_amount_2 = origin_amount - new_amount_1
			item.current_amount = new_amount_1
			GBIS.sig_inv_item_updated.emit(inv_name, grid_id)
			
			var new_item = item.duplicate()
			new_item.current_amount = new_amount_2
			GBIS.moving_item_service.move_item_by_data(new_item, offset, base_size)
			return new_item
	return null

## 快速移动（默认：Shift + 鼠标右键）
func quick_move(inv_name: String, grid_id: Vector2i) -> void:
	var target_inventories = _container_repository.get_quick_move_relations(inv_name)
	var item_to_move = _container_repository.get_container(inv_name).find_item_data_by_grid(grid_id)
	if target_inventories.is_empty() or not item_to_move:
		return
	for target_container in target_inventories:
		# 目标背包必须打开
		if not GBIS.opened_containers.has(target_container):
			continue
		if add_item(target_container, item_to_move):
			remove_item_by_data(inv_name, item_to_move)
			break
		elif item_to_move is StackableData:
			GBIS.sig_inv_item_updated.emit(inv_name, grid_id)

## 增加背包间的快速移动关系
func add_quick_move_relation(inv_name: String, target_inv_name: String) -> void:
	_container_repository.add_quick_move_relation(inv_name, target_inv_name)

## 删除背包间的快速移动关系
func remove_quick_move_relation(inv_name: String, target_inv_name: String) -> void:
	_container_repository.remove_quick_move_relation(inv_name, target_inv_name)

## 删除背包中的物品，成功后触发 sig_inv_item_removed
func remove_item_by_data(inv_name: String, item_data: ItemData) -> void:
	if _container_repository.get_container(inv_name).remove_item(item_data):
		GBIS.sig_inv_item_removed.emit(inv_name, item_data)

## 只返回背包
func get_container(container_name: String) -> ContainerData:
	if GBIS.inventory_names.has(container_name):
		return _container_repository.get_container(container_name)
	return null


# 消耗指定数量的物品
# 参数：背包名称、物品名称(匹配.item_name)、消耗数量
# 当消耗数量为-1时移除所有匹配物品；大于实际数量时也移除所有
func 消耗指定数量物品(背包名称: String, 物品名称: String, 消耗数量: int) -> bool:
	# 查找背包中所有匹配名称的物品
	var 物品列表 = find_item_data_by_item_name(背包名称, 物品名称)
	if 物品列表.is_empty():
		return false  # 没有找到对应物品
	
	var 剩余需消耗数量 = 消耗数量
	var 是否有消耗 = false  # 标记是否实际消耗了物品
	
	for 物品 in 物品列表:
		if not 消耗数量==-1 and 剩余需消耗数量 <= 0:
			break  # 已满足消耗数量，提前跳出循环
		
		if 物品 is StackableData:
			# 处理可堆叠物品
			if 消耗数量==-1:
				# 消耗所有：直接移除整个物品
				remove_item_by_data(背包名称, 物品)
				是否有消耗 = true
			else:
				if 物品.current_amount > 剩余需消耗数量:
					# 数量充足，仅减少数量
					物品.current_amount -= 剩余需消耗数量
					var 物品格子 = _container_repository.get_container(背包名称).find_grids_by_item_data(物品)
					if not 物品格子.is_empty():
						GBIS.sig_inv_item_updated.emit(背包名称, 物品格子[0])
					剩余需消耗数量 = 0
					是否有消耗 = true
				else:
					# 数量不足，移除整个物品
					剩余需消耗数量 -= 物品.current_amount
					remove_item_by_data(背包名称, 物品)
					是否有消耗 = true
		else:
			# 处理不可堆叠物品（每个算1个）
			remove_item_by_data(背包名称, 物品)
			是否有消耗 = true
			if not 消耗数量==-1:
				剩余需消耗数量 -= 1
	
	return 是否有消耗  # 返回是否实际消耗了物品
	
	
