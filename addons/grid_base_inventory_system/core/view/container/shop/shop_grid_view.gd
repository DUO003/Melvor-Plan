extends BaseGridView
## 格子视图，用于绘制格子
class_name ShopGridView

## 输入控制
func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(GBIS.input_click):
		if has_taken:
			if not GBIS.moving_item_service.moving_item:
				var item = GBIS.shop_service.find_item_data_by_grid(_container_view.container_name, grid_id)
				GBIS.shop_service.buy(_container_view.container_name, item)
				GBIS.emit_signal("sig_inv_refresh")
				初始化.保存存档()
		elif GBIS.has_moving_item():
				GBIS.shop_service.sell(GBIS.moving_item_service.moving_item)
