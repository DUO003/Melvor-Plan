@tool
extends BaseContainerView
## 背包视图，控制背包的绘制
class_name ShopView

#@export var goods: Array[ItemData]

## 格子高亮
func grid_hover(grid_id: Vector2i) -> void:
	if not GBIS.moving_item_service.moving_item:
		var 物品实例: ItemData = GBIS.inventory_service.find_item_data_by_grid(container_name, grid_id)
		if 物品实例:
			GBIS.item_focus_service.focus_item(物品实例, container_name)
			var 数据:梅提示数据=梅提示数据.new()
			数据.通用解析(物品实例,{"背包名":container_name})
			数据.节点=_grid_map.get(grid_id)
			计划.数据包提示.emit(数据)
		return
	移除提示(grid_id)
	var 移动物品格子: = GBIS.moving_item_service.moving_item_view
	移动物品格子.base_size = base_size
	移动物品格子.stack_num_color = stack_num_color
	移动物品格子.stack_num_font = stack_num_font
	移动物品格子.stack_num_font_size = stack_num_font_size
	移动物品格子.stack_num_margin = stack_num_margin
func 移除提示(grid_id: Vector2i):
	var 数据:梅提示数据=梅提示数据.new()
	if _grid_map.has(grid_id):
		数据.节点=_grid_map[grid_id]
	计划.数据包提示.emit(数据)
	
## 格子失去高亮
func grid_lose_hover(grid_id: Vector2i) -> void:
	GBIS.item_focus_service.item_lose_focus()
	移除提示(grid_id)
## 初始化
func _ready() -> void:
	if Engine.is_editor_hint():
		call_deferred("_recalculate_size")
		return
	
	if not container_name:
		push_error("Shop must have a name.")
		return
	
	加载背包数据()
	
	if visible:
		GBIS.opened_containers.append(container_name)
	
	
	# 加载货物
	GBIS.shop_service.get_container(container_name)#.clear()
	#GBIS.shop_service.load_goods(container_name, goods)
	
	mouse_filter = Control.MOUSE_FILTER_PASS
	_init_grid_container()
	_init_item_container()
	_init_grids()
	GBIS.sig_inv_refresh.connect(refresh)
	
	visibility_changed.connect(_on_visible_changed)
	
	if not stack_num_font:
		stack_num_font = get_theme_font("font")
	
	call_deferred("refresh")
func 加载背包数据():
	var 背包数据:Dictionary=计划.梅存档.挂机.背包数据
	if 背包数据.has(container_name):
		container_rows=int(背包数据[container_name].get("行数"))
	var ret = GBIS.shop_service.regist(container_name, container_columns, container_rows, true)
	# 使用已注册的信息覆盖View设置
	#container_columns = ret.columns
	#container_rows = ret.rows
	custom_minimum_size=Vector2(container_columns,container_rows)*Vector2(base_size,base_size)
	return ret
## 初始化格子View
func _init_grids() -> void:
	for row in container_rows:
		for col in container_columns:
			var grid_id = Vector2i(col, row)
			var grid = ShopGridView.new(self, grid_id, base_size, grid_border_size, grid_border_color, 
				gird_background_color_empty, gird_background_color_taken, gird_background_color_conflict, grid_background_color_avilable)
			if 启用焦点:
				grid.focus_mode=Control.FOCUS_ALL
				grid.focus_entered.connect(格子焦点更新.bind(grid_id,true))
				grid.focus_exited.connect(格子焦点更新.bind(grid_id,false))
			if 格子覆盖:
				grid.格子覆盖=true
				grid.覆盖样式_空=覆盖样式_空
				grid.覆盖样式_占用=覆盖样式_占用
				grid.覆盖样式_冲突=覆盖样式_冲突
				grid.覆盖样式_可用=覆盖样式_可用
			_grid_container.add_child(grid)
			_grid_map[grid_id] = grid
func 格子焦点更新(坐标:Vector2i,状态:bool):
	if 状态:
		焦点_格子=坐标
		var 格子:=_grid_map[坐标]
		格子.state=格子.State.焦点
		grid_hover(坐标)
	else :
		grid_lose_hover(焦点_格子)
		if 焦点_格子==坐标:
			焦点_格子=Vector2i(-1,-1)
		var 格子:=_grid_map[坐标]
		格子.复原样式()
func _input(按键: InputEvent) -> void:
	if 按键.is_action_pressed("ui_accept"):
		if not 焦点_格子==Vector2i(-1,-1):
			var 格子:=_grid_map[焦点_格子]
			if 格子 is ShopGridView:
				格子.购买方法()
			get_viewport().set_input_as_handled()
