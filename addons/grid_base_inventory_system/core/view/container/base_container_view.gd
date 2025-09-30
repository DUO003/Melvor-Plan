@tool
extends Control
## 背包视图，控制背包的绘制
class_name BaseContainerView

@export_group("Container Settings")
## 背包名字，如果重复，则显示同一来源的数据
@export var container_name: String = GBIS.DEFAULT_INVENTORY_NAME
	#set(value):
		#print("背包名字:",GBIS.DEFAULT_INVENTORY_NAME)
## 背包列数，如果背包名字重复，列数需要一样
@export var container_columns: int = 2:
	set(value):
		container_columns = value
		_recalculate_size()
## 背包行数，如果背包名字重复，行数需要一样
@export var container_rows: int = 2:
	set(value):
		container_rows = value
		_recalculate_size()

@export_group("Grid Settings")
## 格子大小
@export var base_size: int = 32:
	set(value):
		base_size = value
		_recalculate_size()
## 格子边框大小
@export var grid_border_size: int = 1:
	set(value):
		grid_border_size = value
		queue_redraw()
## 格子边框颜色
@export var grid_border_color: Color = BaseGridView.DEFAULT_BORDER_COLOR:
	set(value):
		grid_border_color = value
		queue_redraw()
## 格子空置颜色
@export var gird_background_color_empty: Color = BaseGridView.DEFAULT_EMPTY_COLOR:
	set(value):
		gird_background_color_empty = value
		queue_redraw()
## 格子占用颜色
@export var gird_background_color_taken: Color = BaseGridView.DEFAULT_TAKEN_COLOR:
	set(value):
		gird_background_color_taken = value
		queue_redraw()
## 格子冲突颜色
@export var gird_background_color_conflict: Color = BaseGridView.DEFAULT_CONFLICT_COLOR:
	set(value):
		gird_background_color_conflict = value
		queue_redraw()
## 格子可用颜色
@export var grid_background_color_avilable: Color = BaseGridView.DEFAULT_AVILABLE_COLOR:
	set(value):
		grid_background_color_avilable = value
		queue_redraw()

@export_group("Stack Settings")
## 堆叠数量的字体
@export var stack_num_font: Font:
	set(value):
		stack_num_font = value
		queue_redraw()
## 堆叠数量的字体大小
@export var stack_num_font_size: int = 16:
	set(value):
		stack_num_font_size = value
		queue_redraw()
## 堆叠数量的边距（右下角）
@export var stack_num_margin: int = 4:
	set(value):
		stack_num_margin = value
		queue_redraw()
## 堆叠数量的颜色
@export var stack_num_color: Color = Color.WHITE:
	set(value):
		stack_num_color = value
		queue_redraw()

## 格子容器
var _grid_container: GridContainer
## 物品容器
var _item_container: Control

## 所有物品的View
var _items: Array[ItemView]
## 物品到格子的映射（Array[Vector2i]）
var _item_grids_map: Dictionary[ItemView, Array]
## 格子到格子View的映射
var _grid_map: Dictionary[Vector2i, BaseGridView]
## 格子到物品的映射
var _grid_item_map: Dictionary[Vector2i, ItemView]

## 刷新背包显示
func refresh() -> void:
	_clear_inv()
	var container_data = GBIS.inventory_service.get_container(container_name)
	if not container_data:
		container_data = GBIS.shop_service.get_container(container_name)
	
	var handled_item: Dictionary[ItemData, ItemView]
	for grid in _grid_map.keys():
		var item_data = container_data.grid_item_map[grid]
		if item_data and not handled_item.has(item_data):
			var grids = container_data.item_grids_map[item_data]
			var item = _draw_item(item_data, grids[0])
			handled_item[item_data] = item
			_items.append(item)
			_item_grids_map[item] = grids
			for g in grids:
				_grid_map[g].taken(g - grids[0])
				_grid_item_map[g] = item
			continue
		elif item_data:
			_grid_item_map[grid] = handled_item[item_data]
		else:
			_grid_item_map[grid] = null

## 通过格子ID获取物品视图
func find_item_view_by_grid(grid_id: Vector2i) -> ItemView:
	return _grid_item_map.get(grid_id)

func _on_visible_changed() -> void:
	if is_visible_in_tree():
		GBIS.opened_containers.append(container_name)
		# 需要等待GirdContainer处理完成，否则其下的所有grid没有position信息
		await get_tree().process_frame
		refresh()
	else:
		GBIS.opened_containers.erase(container_name)

## 清空背包显示
## 注意，只清空显示，不清空数据库
func _clear_inv() -> void:
	for item in _items:
		item.queue_free()
	_items = []
	_item_grids_map = {}
	for grid in _grid_map.values():
		grid.release()
	_grid_item_map = {}

## 从指定格子开始，获取形状覆盖的格子
func _get_grids_by_shape(start: Vector2i, shape: Vector2i) -> Array[Vector2i]:
	var ret: Array[Vector2i] = []
	for row in shape.y:
		for col in shape.x:
			var grid_id = Vector2i(start.x + col, start.y + row)
			if _grid_map.has(grid_id):
				ret.append(grid_id)
	return ret

## 绘制物品
func _draw_item(item_data: ItemData, first_grid: Vector2i) -> ItemView:
	var item = ItemView.new(item_data, base_size, stack_num_font, stack_num_font_size, stack_num_margin, stack_num_color)
	_item_container.add_child(item)
	item.global_position = _grid_map[first_grid].global_position
	return item

## 初始化格子容器
func _init_grid_container() -> void:
	_grid_container = GridContainer.new()
	_grid_container.add_theme_constant_override("h_separation", 0)
	_grid_container.add_theme_constant_override("v_separation", 0)
	_grid_container.columns = container_columns
	_grid_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_grid_container)

## 初始化物品容器
func _init_item_container() -> void:
	_item_container = Control.new()
	add_child(_item_container)

## 编辑器中绘制示例
func _draw() -> void:
	if Engine.is_editor_hint():
		var inner_size = base_size - grid_border_size * 2
		for row in container_rows:
			for col in container_columns:
				draw_rect(Rect2(col * base_size, row * base_size, base_size, base_size), grid_border_color, true)
				draw_rect(Rect2(col * base_size + grid_border_size, row * base_size + grid_border_size, inner_size, inner_size), gird_background_color_empty, true)
				var font = stack_num_font if stack_num_font else get_theme_font("font")
				var text_size = font.get_string_size("99", HORIZONTAL_ALIGNMENT_RIGHT, -1, stack_num_font_size)
				var pos = Vector2(
					base_size - text_size.x - stack_num_margin,
					base_size - font.get_descent(stack_num_font_size) - stack_num_margin
				)
				pos += Vector2(col * base_size, row * base_size)
				draw_string(font, pos, "99", HORIZONTAL_ALIGNMENT_RIGHT, -1, stack_num_font_size, stack_num_color)

## 重新计算大小
func _recalculate_size() -> void:
		var new_size = Vector2(container_columns * base_size, container_rows * base_size)
		if size != new_size:
			size = new_size
		queue_redraw()
