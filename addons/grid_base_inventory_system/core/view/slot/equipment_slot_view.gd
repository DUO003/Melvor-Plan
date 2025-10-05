@tool
extends Control
## 装备槽视图
class_name EquipmentSlotView

## 装备槽的绘制状态：正常、可用、不可用
enum State{
	NORMAL, AVILABLE, INVILABLE
}

## 装备槽名称，如果重复则展示相同来源的数据
@export var slot_name: String = GBIS.DEFAULT_SLOT_NAME:
	set(value):
		slot_name = value
		_recalculate_size()

## 基础大小（格子大小）
@export var base_size: int = 32:
	set(value):
		base_size = value
		_recalculate_size()
## 列数（仅显示，与物品大小无关）
@export var columns: int = 2:
	set(value):
		columns = value
		_recalculate_size()
## 行数（仅显示，与物品大小无关）
@export var rows: int = 2:
	set(value):
		rows = value
		_recalculate_size()
## 背景图片
@export var background: Texture2D:
	set(value):
		background = value
		queue_redraw()
## 可用时的颜色（推荐半透明）
@export var avilable_color: Color = Color.GREEN * 0.3:
	set(value):
		avilable_color = value
		queue_redraw()
## 不可用时的颜色（推荐半透明）
@export var INVILABLE_color: Color = Color.DARK_RED * 0.3:
	set(value):
		INVILABLE_color = value
		queue_redraw()
## 可以装备的物品类型，对应 ItemData.type
@export var avilable_types: Array[String] = ["ANY"]

## 物品容器
var _item_container: Control
## 物品视图
var _item_view: ItemView
## 当前绘制状态
var _state: State = State.NORMAL

## 是否为空
func is_empty() -> bool:
	return _item_view == null

## 刷新装备槽显示
func refresh() -> void:
	_clear_slot()
	var slot_data = GBIS.equipment_slot_service.get_slot(slot_name)
	if slot_data:
		var item_data = slot_data.equipped_item
		if item_data:
			_on_item_equipped(slot_name, item_data)

## 初始化
func _ready() -> void:
	if Engine.is_editor_hint():
		call_deferred("_recalculate_size")
		return
	
	if not slot_name:
		push_error("Slot must have a name.")
		return
	
	var ret = GBIS.equipment_slot_service.regist_slot(slot_name, avilable_types)
	if not ret:
		return
	
	if visible:
		GBIS.opened_equipment_slots.append(slot_name)
	
	mouse_filter = Control.MOUSE_FILTER_PASS
	_init_item_container()
	GBIS.sig_slot_item_equipped.connect(_on_item_equipped)
	GBIS.sig_slot_item_unequipped.connect(_on_item_unequipped)
	GBIS.sig_slot_refresh.connect(refresh)
	mouse_entered.connect(_on_slot_hover)
	mouse_exited.connect(_on_slot_lose_hover)
	
	visibility_changed.connect(_on_visible_changed)
	
	call_deferred("refresh")

func _on_visible_changed() -> void:
	if is_visible_in_tree():
		GBIS.opened_equipment_slots.append(slot_name)
	else:
		GBIS.opened_equipment_slots.erase(slot_name)

## 高亮
func _on_slot_hover() -> void:
	if not GBIS.moving_item_service.moving_item:
		var item_data = GBIS.equipment_slot_service.get_slot(slot_name).equipped_item
		if item_data:
			GBIS.item_focus_service.focus_item(item_data, slot_name)
		return
	if GBIS.moving_item_service.moving_item is EquipmentData:
		GBIS.moving_item_service.moving_item_view.base_size = base_size
		var is_avilable = GBIS.equipment_slot_service.get_slot(slot_name).is_item_avilable(GBIS.moving_item_service.moving_item)
		_state = State.AVILABLE if is_avilable and is_empty() else State.INVILABLE
	else:
		_state = State.INVILABLE
	queue_redraw()

## 失去高亮
func _on_slot_lose_hover() -> void:
	_state = State.NORMAL
	GBIS.item_focus_service.item_lose_focus()
	queue_redraw()

## 监听穿装备
@warning_ignore("shadowed_variable")
func _on_item_equipped(slot_name: String, item_data: ItemData):
	if slot_name != self.slot_name:
		return
	
	_item_view = _draw_item(item_data)
	_item_container.add_child(_item_view)
	_state = State.NORMAL
	queue_redraw()

## 监听脱装备
@warning_ignore("shadowed_variable")
func _on_item_unequipped(slot_name: String, _item_data: ItemData):
	if slot_name != self.slot_name:
		return
	
	_clear_slot()

## 绘制装备
func _draw_item(item_data: ItemData) -> ItemView:
	var item = ItemView.new(item_data, base_size)
	var center = size / 2 - item.size / 2
	item.position = center
	return item

## 清空装备槽显示（仅清空显示，与数据无关）
func _clear_slot() -> void:
	if _item_view:
		_item_view.queue_free()
		_item_view = null

## 初始化物品容器
func _init_item_container() -> void:
	_item_container = Control.new()
	add_child(_item_container)

## 绘制装备槽背景
func _draw() -> void:
	if background:
		draw_texture_rect(background, Rect2(0, 0, columns * base_size, rows * base_size), false)
		match _state:
			State.AVILABLE:
				draw_rect(Rect2(0, 0, columns * base_size, rows * base_size), avilable_color)
			State.INVILABLE:
				draw_rect(Rect2(0, 0, columns * base_size, rows * base_size), INVILABLE_color)
	else:
		draw_rect(Rect2(0, 0, columns * base_size, rows * base_size), INVILABLE_color * 10)
	if is_empty():
		var 加载字体=load("res://字体/AlibabaPuHuiTi-3/AlibabaPuHuiTi-3-55-Regular/阿里巴巴普惠55号.otf")
		var 字号=32
		var 文本宽度 = 加载字体.get_string_size(slot_name, 字号).x
		var 水平居中=(columns * base_size - 文本宽度*2) / 2
		draw_string(
			加载字体,  # 默认字体
			Vector2(水平居中, rows * base_size-10),         # 文本位置（左上角内边距）
			slot_name,             # 装备部位名称
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,                    # 不限制宽度
			字号,                    # 默认字号
			Color(0, 0, 0))         # 默认白色
	

## 重新计算大小
func _recalculate_size() -> void:
	var new_size = Vector2(columns * base_size, rows * base_size)
	if size != new_size:
		size = new_size
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	# 点击动作处理
	if event.is_action_pressed(GBIS.input_click):
		GBIS.item_focus_service.item_lose_focus()
		if GBIS.moving_item_service.moving_item and is_empty():
			GBIS.equipment_slot_service.equip_moving_item(slot_name)
		elif not GBIS.moving_item_service.moving_item and not is_empty():
			GBIS.equipment_slot_service.move_item(slot_name, base_size)
			_on_slot_hover()
	
	# 使用动作处理
	elif event.is_action_pressed(GBIS.input_use) and not is_empty():
		GBIS.equipment_slot_service.unequip(slot_name)
