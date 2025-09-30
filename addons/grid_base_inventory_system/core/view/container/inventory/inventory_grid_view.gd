extends BaseGridView
## 格子视图，用于绘制格子
class_name InventoryGridView

func _gui_input(event: InputEvent) -> void:
	if not event.is_pressed():  # 只处理按键按下事件
		return
	
	GBIS.item_focus_service.item_lose_focus()
	
	# 处理点击动作
	if event.is_action_pressed(GBIS.input_click):
		if has_taken:
			if not GBIS.moving_item_service.moving_item:
				GBIS.moving_item_service.move_item_by_grid(_container_view.container_name, grid_id, offset, _size)
			elif GBIS.moving_item_service.moving_item is StackableData:
				GBIS.inventory_service.stack_moving_item(_container_view.container_name, grid_id)
			_container_view.grid_hover(grid_id)  # 点击时手动调用高亮
		else:
			GBIS.inventory_service.place_moving_item(_container_view.container_name, grid_id)
		return
	
	# 如果不是点击动作且格子没有物品，直接返回
	if not has_taken:
		print("没有物品")
		return
	
	if event.is_action_pressed(GBIS.input_quick_move):
		print("快速移动操作操作 容器名: %s\r坐标: %s" % [_container_view.container_name,grid_id])
		GBIS.inventory_service.quick_move(_container_view.container_name, grid_id)
	elif event.is_action_pressed(GBIS.input_use):
		print("使用物品")
		GBIS.inventory_service.use_item(_container_view.container_name, grid_id)
	elif event.is_action_pressed(GBIS.input_split) and not GBIS.moving_item_service.moving_item:
		print("拆分物品参数 - 容器名: %s, 格子坐标: %s, 偏移量: %s, 尺寸: %s" % [_container_view.container_name, grid_id, offset, _size])
		GBIS.inventory_service.split_item(_container_view.container_name, grid_id, offset, _size)
