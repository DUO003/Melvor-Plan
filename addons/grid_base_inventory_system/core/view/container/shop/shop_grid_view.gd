extends BaseGridView
## 格子视图，用于绘制格子
class_name ShopGridView

## 输入控制
func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed(GBIS.input_click):
		if has_taken and not GBIS.moving_item_service.moving_item:
			购买方法()
		elif GBIS.has_moving_item():
			出售手持物品()
func 购买方法():
	if has_taken:
		var item:ItemData = GBIS.shop_service.find_item_data_by_grid(_container_view.container_name, grid_id)
		if not item:
			print("错误,未获取物品")
			return  # 安全判断：物品不存在
		GBIS.shop_service.buy(_container_view.container_name, item)
		计划.保存存档("购买商品")
		if _container_view is ShopView:
			_container_view.grid_hover(grid_id)
func 出售手持物品():
	if GBIS.has_moving_item():
		GBIS.shop_service.sell(GBIS.moving_item_service.moving_item)
