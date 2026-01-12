extends BaseContainerService
## 背包业务类
class_name InventoryService

## 向背包/容器中添加物品的核心函数
## 参数说明：
## - inv_name: 容器/背包的名称（唯一标识）
## - item_data: 要添加的物品数据对象（包含物品名称、数量、堆叠属性等）
## 返回值：bool - 添加成功返回true，失败返回false
## 核心逻辑规则：
## 1. 可堆叠物品：若当前数量超过堆叠上限，先重置为堆叠最大值；堆叠后有剩余则按新物品添加
## 2. 信号发射规则：
##    - 可堆叠物品堆叠成功 → 发射 sig_inv_item_updated 信号
##    - 不可堆叠物品/堆叠后剩余物品添加成功 → 发射 sig_inv_item_added 信号
func add_item(inv_name: String, item_data: ItemData) -> bool:
	# 复用传入的物品数据对象（避免复制丢失堆叠上限等关键数据）
	var new_item_data = item_data#不能复制,会丢失上限数据
	# 处理可堆叠物品的逻辑分支
	if new_item_data is StackableData:
		# 校验并修正堆叠数量：超过上限则重置为堆叠最大值
		if new_item_data.current_amount > new_item_data.stack_size:
			new_item_data.current_amount = new_item_data.stack_size
		# 根据物品名称查找容器中已存在的同类型可堆叠物品
		var items = find_item_data_by_item_name(inv_name, new_item_data.item_name)
		# 遍历已存在的同类型物品，尝试堆叠
		for item in items:
			# 仅处理未堆满的物品槽位
			if not item.is_full():
				# 执行堆叠操作：返回堆叠后剩余的物品数量
				new_item_data.current_amount = item.add_amount(new_item_data.current_amount)
				
				# 获取该物品所在的容器格子信息（用于信号传参）
				var new_item_grids = _container_repository.get_container(inv_name).find_grids_by_item_data(item)
				# 断言：确保能找到物品对应的格子（防止逻辑异常）
				assert(not new_item_grids.is_empty())
				
				# 堆叠成功，发射物品更新信号
				GBIS.sig_inv_item_updated.emit(inv_name, new_item_grids[0])
				
				# 若堆叠后无剩余物品，直接返回添加成功
				if new_item_data.current_amount <= 0:
					return true
	
	
	# 处理两种情况：
	# 1. 不可堆叠物品
	# 2. 可堆叠物品堆叠后仍有剩余数量
	var grids = _container_repository.get_container(inv_name).add_item(new_item_data)
	
	# 若成功找到可放置的格子并添加物品
	if not grids.is_empty():
		# 发射物品新增信号
		GBIS.sig_inv_item_added.emit(inv_name, new_item_data, grids)
		return true
	
	# 无可用格子/堆叠失败，返回添加失败
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
		if item and item is StackableData and item.stack_size > 1 and item.current_amount > 1:
			var origin_amount = item.current_amount
			var new_amount_1 = origin_amount / 2
			var new_amount_2 = origin_amount - new_amount_1
			item.current_amount = new_amount_1
			GBIS.sig_inv_item_updated.emit(inv_name, grid_id)
			
			var new_item = item.duplicate()
			new_item.current_amount = new_amount_2
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
	if 剩余需消耗数量>0:
		var 鼠标物品=GBIS.moving_item_service.moving_item
		if 鼠标物品 and 鼠标物品.item_name==物品名称:
			鼠标物品.current_amount-=剩余需消耗数量
			if 鼠标物品.current_amount<0:#为0不会影响释放代码,但不能直接移物品
				鼠标物品.current_amount=0
	return 是否有消耗  # 返回是否实际消耗了物品
	
	
