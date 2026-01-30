extends BaseContainerService
## 背包业务类
class_name InventoryService

## 向背包添加物品返回添加成功
func add_item(inv_name: String, 物品: ItemData) -> bool:
	var 同名数组 = find_item_data_by_item_name(inv_name, 物品.item_name)#通过物品名称找所有同名物品
	if 同名数组.has(物品):return true#如果存在自己就无需继续
	if 物品 is StackableData:# 处理可堆叠物品的逻辑分支
		if 物品.数量 > 物品.堆叠上限:# 校验并修正堆叠数量：超过上限则重置为堆叠最大值
			物品.数量 = 物品.堆叠上限
			print("错误,物品添加方法不能处理超出物品数量的逻辑")
		var 背包数据:ContainerData=_container_repository.get_container(inv_name)
		for 同名物品 in 同名数组:# 遍历已存在的同类型物品，尝试堆叠
			if 同名物品 is StackableData:
				if not 同名物品.满堆叠():# 仅处理未堆满的物品槽位
					物品.数量 = 同名物品.add_amount(物品.数量)# 执行堆叠操作：返回堆叠后剩余的物品数量
					var 物品格子:Array[Vector2i]= 背包数据.find_grids_by_item_data(同名物品)# 获取该物品所在的容器格子信息
					assert(not 物品格子.is_empty())# 断言：确保能找到物品对应的格子
					GBIS.sig_inv_item_updated.emit(inv_name, 物品格子[0])#发射物品更新信号
					if 物品.数量 <= 0:
						return true#堆叠无剩余返回成功
	var 可用格 = _container_repository.get_container(inv_name).add_item(物品)
	if not 可用格.is_empty():# 若成功找到可放置的格子并添加物品
		GBIS.sig_inv_item_added.emit(inv_name, 物品, 可用格)# 发射物品新增信号
		return true
	return false# 无可用格子/堆叠失败，返回添加失败
## 尝试把正在移动的物品堆叠到这个格子上
func stack_moving_item(inv_name: String, grid_id: Vector2i) -> void:
	if not GBIS.moving_item_service.moving_item:
		return
	var item_data = find_item_data_by_grid(inv_name, grid_id)
	if not item_data is StackableData:
		return
	if item_data.item_name == GBIS.moving_item_service.moving_item.item_name:
		var amount_left = item_data.add_amount(GBIS.moving_item_service.moving_item.数量)
		if amount_left > 0:
			GBIS.moving_item_service.moving_item.数量 = amount_left
		else:
			GBIS.moving_item_service.clear_moving_item()
		GBIS.sig_inv_item_updated.emit(inv_name, grid_id)

## 尝试放置正在移动的物品到这个格子
func place_moving_item(inv_name: String, grid_id: Vector2i) -> bool:
	if place_to(inv_name, GBIS.moving_item_service.moving_item, grid_id):
		GBIS.moving_item_service.clear_moving_item()
		计划.保存存档("背包:物品格子移动")
		
		return true
	return false

## 使用物品（默认：鼠标右键点击格子）
func use_item(inv_name: String, grid_id: Vector2i) -> bool:
	var item_data = find_item_data_by_grid(inv_name, grid_id)
	if not item_data:
		return false
	if item_data is 标准物品 or item_data is 物品宝石 or item_data is 物品装备:
		if item_data.物品点击(inv_name):
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
func split_item(inv_name: String, grid_id: Vector2i, offset: Vector2i, base_size: int,背包本体=null) -> ItemData:
	var inv = _container_repository.get_container(inv_name)
	if inv:
		var item = inv.find_item_data_by_grid(grid_id)
		if item and item is StackableData and item.堆叠上限 > 1 and item.数量 > 1:
			var origin_amount = item.数量
			var new_amount_1 = origin_amount / 2
			var new_amount_2 = origin_amount - new_amount_1
			item.数量 = new_amount_1
			GBIS.sig_inv_item_updated.emit(inv_name, grid_id)
			
			var new_item = item.duplicate()
			new_item.数量 = new_amount_2
			GBIS.moving_item_service.move_item_by_data(new_item, offset, base_size,背包本体)
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
			if 消耗数量==-1:# 消耗所有：直接移除整个物品
				remove_item_by_data(背包名称, 物品)
				是否有消耗 = true
			else:
				if 物品.数量 > 剩余需消耗数量:
					# 数量充足，仅减少数量
					物品.数量 -= 剩余需消耗数量
					var 物品格子 = _container_repository.get_container(背包名称).find_grids_by_item_data(物品)
					if not 物品格子.is_empty():
						GBIS.sig_inv_item_updated.emit(背包名称, 物品格子[0])
					剩余需消耗数量 = 0
					是否有消耗 = true
				else:
					# 数量不足，移除整个物品
					剩余需消耗数量 -= 物品.数量
					remove_item_by_data(背包名称, 物品)
					是否有消耗 = true
		else:
			# 处理不可堆叠物品（每个算1个）
			remove_item_by_data(背包名称, 物品)
			是否有消耗 = true
			if not 消耗数量==-1:
				剩余需消耗数量 -= 1
	if 剩余需消耗数量>0:
		var 鼠标物品=GBIS.moving_item_service.moving_item
		if 鼠标物品 and 鼠标物品.item_name==物品名称:
			鼠标物品.数量-=剩余需消耗数量
			if 鼠标物品.数量<0:#为0不会影响释放代码,但不能直接移物品
				鼠标物品.数量=0
	return 是否有消耗  # 返回是否实际消耗了物品
	
	
