extends BaseGridView
## 格子视图，用于绘制格子
class_name InventoryGridView

func _gui_input(event: InputEvent) -> void:
	if not event.is_pressed():  # 只处理按键按下事件
		return
	if not GBIS.moving_item_service.moving_item and has_taken and _container_view.可拿取类型.size()>=1:
		if (event.is_action_pressed(GBIS.input_click) or 
		event.is_action_pressed(GBIS.input_use) or event.is_action_pressed(GBIS.input_split)):
			var 格子里的物品 = GBIS.inventory_service.find_item_data_by_grid(_container_view.container_name, grid_id)
			if 格子里的物品 and 格子里的物品.item_name in _container_view.可拿取类型:
				GBIS.moving_item_service.move_item_by_grid(_container_view.container_name, grid_id, offset, _size,_container_view)
		return
	GBIS.item_focus_service.item_lose_focus()
	if event.is_action_pressed(GBIS.input_click):# 处理左键点击动作
		if has_taken:
			if not GBIS.moving_item_service.moving_item:
				print("使用物品")
				GBIS.inventory_service.use_item(_container_view.container_name, grid_id)
			elif GBIS.moving_item_service.moving_item is StackableData:
				GBIS.inventory_service.stack_moving_item(_container_view.container_name, grid_id)
			_container_view.grid_hover(grid_id)  # 点击时手动调用高亮
		else:
			GBIS.inventory_service.place_moving_item(_container_view.container_name, grid_id)
		return
	elif event.is_action_pressed(GBIS.input_use):# 处理右键点击动作
		if has_taken:
			if not GBIS.moving_item_service.moving_item:
				#将物品加入移动
				GBIS.moving_item_service.move_item_by_grid(_container_view.container_name, grid_id, offset, _size,_container_view)
			elif GBIS.moving_item_service.moving_item is StackableData:
				GBIS.inventory_service.stack_moving_item(_container_view.container_name, grid_id)
			_container_view.grid_hover(grid_id)  # 点击时手动调用高亮
		else :
			GBIS.inventory_service.place_moving_item(_container_view.container_name, grid_id)
		return
	if not has_taken:# 如果不是点击动作且格子没有物品，直接返回
		#print("没有物品")
		return
	if event.is_action_pressed(GBIS.input_quick_move):
		print("快速移动操作操作 容器名: %s\r坐标: %s" % [_container_view.container_name,grid_id])
		GBIS.inventory_service.quick_move(_container_view.container_name, grid_id)
	elif event.is_action_pressed(GBIS.input_split) and not GBIS.moving_item_service.moving_item:
		print("拆分物品参数 - 容器名: %s, 格子坐标: %s, 偏移量: %s, 尺寸: %s" % [_container_view.container_name, grid_id, offset, _size])
		GBIS.inventory_service.split_item(_container_view.container_name, grid_id, offset, _size,_container_view)
