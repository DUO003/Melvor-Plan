extends Node
## 移动物品业务类
class_name MovingItemService

## 正在移动的物品
var moving_item: ItemData
## 正在移动的物品View
var moving_item_view: ItemView
## 正在移动的物品的偏移（例：一个2*2的物品，点击左上角移动时，偏移是[0,0]，点击右下角移动时，偏移是[1,1]）
var moving_item_offset: Vector2i = Vector2i.ZERO
## 丢弃物品检测区域
var drop_area_view: DropAreaView

## 顶层，用于展示移动物品的View
var _moving_item_layer: CanvasLayer

## 获取顶层，没有则新建
func get_moving_item_layer() -> CanvasLayer:
	if not _moving_item_layer: 
		_moving_item_layer = CanvasLayer.new()
		_moving_item_layer.layer = 128
		GBIS.get_root().add_child(_moving_item_layer)
	return _moving_item_layer

## 清除正在移动的物品(不会删除版)
func 安全清除移动物品() -> void:
	if moving_item != null:
		var 背包类型 = "背包"
		if moving_item is 物品装备:
			背包类型 = "装备"
		GBIS.add_item(背包类型, moving_item)
		clear_moving_item()
func clear_moving_item() -> void:
	for o in _moving_item_layer.get_children():
		o.queue_free()
	moving_item = null
	moving_item_view = null
	if drop_area_view:
		drop_area_view.hide()

func move_item_by_data(item_data: ItemData, offset: Vector2i, base_size: int,背包本体=null) -> void:
	self.moving_item = item_data
	self.moving_item_offset = offset
	self.moving_item_view = ItemView.new(item_data, base_size)
	if 背包本体!=null and 背包本体 is BaseContainerView:
		moving_item_view.base_size = 背包本体.base_size  # 假设背包本体有base_size属性
		moving_item_view.stack_num_color = 背包本体.stack_num_color
		moving_item_view.stack_num_font = 背包本体.stack_num_font
		moving_item_view.stack_num_font_size = 背包本体.stack_num_font_size
		moving_item_view.stack_num_margin = 背包本体.stack_num_margin
	get_moving_item_layer().add_child(moving_item_view)
	moving_item_view.move(offset)
	if drop_area_view:
		drop_area_view.show()

func move_item_by_grid(inv_name: String, grid_id: Vector2i, offset: Vector2i, base_size: int) -> void:
	if moving_item:
		push_error("Already had moving item.")
		return
	var item_data = GBIS.inventory_service.find_item_data_by_grid(inv_name, grid_id)
	if item_data:
		move_item_by_data(item_data, offset, base_size)
		GBIS.inventory_service.remove_item_by_data(inv_name, item_data)
		if drop_area_view:
			drop_area_view.show()
