extends Control
## 格子视图，用于绘制格子
class_name BaseGridView

## 格子的绘制状态：空、占用、冲突、可用
enum State{
	EMPTY, TAKEN, CONFLICT, AVILABLE
}

## 默认边框颜色
const DEFAULT_BORDER_COLOR: Color = Color.GRAY
## 默认空置颜色
const DEFAULT_EMPTY_COLOR: Color = Color.DARK_SLATE_GRAY
## 默认占用颜色
const DEFAULT_TAKEN_COLOR: Color = Color.LIGHT_SLATE_GRAY
## 默认冲突颜色
const DEFAULT_CONFLICT_COLOR: Color = Color.INDIAN_RED
## 默认可用颜色
const DEFAULT_AVILABLE_COLOR: Color = Color.STEEL_BLUE

## 当前绘制状态
var state: State = State.EMPTY:
	set(value):
		state = value
		queue_redraw()

## 格子ID（格子在当前背包的坐标）
var grid_id: Vector2i = Vector2i.ZERO
## 偏移（格子存储物品时的偏移坐标，如：一个2*2的物品，这个格子是它右下角的格子，则 offset = [1,1]）
var offset: Vector2i = Vector2i.ZERO
## 是否被占用
var has_taken: bool = false

## 格子大小
var _size: int = 32
## 边框大小
var _border_size: int = 1
## 边框颜色
var _border_color: Color = DEFAULT_BORDER_COLOR
## 空置颜色
var _empty_color: Color = DEFAULT_EMPTY_COLOR
## 占用颜色
var _taken_color: Color = DEFAULT_TAKEN_COLOR
## 冲突颜色
var _conflict_color: Color = DEFAULT_CONFLICT_COLOR
## 可用颜色
var _avilable_color: Color = DEFAULT_AVILABLE_COLOR

## 所属的背包View
var _container_view: BaseContainerView

## 占用格子
func taken(in_offset: Vector2i) -> void:
	has_taken = true
	offset = in_offset
	state = State.TAKEN

## 释放格子
func release() -> void:
	has_taken = false
	self.offset = Vector2i.ZERO
	state = State.EMPTY

## 构造函数
func _init(inventoryView: BaseContainerView, in_grid_id: Vector2i,size: int, border_size: int, 
	border_color: Color, empty_color: Color, taken_color: Color, conflict_color: Color, avilable_color: Color):
		_avilable_color = avilable_color
		_container_view = inventoryView
		grid_id = in_grid_id
		_size = size
		_border_size = border_size
		_border_color = border_color
		_empty_color = empty_color
		_taken_color = taken_color
		_conflict_color = conflict_color
		custom_minimum_size = Vector2(_size, _size)

## 初始化
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	mouse_entered.connect(_container_view.grid_hover.bind(grid_id))
	mouse_exited.connect(_container_view.grid_lose_hover.bind(grid_id))

## 绘制逻辑
func _draw() -> void:
	draw_rect(Rect2(0, 0, _size, _size), _border_color, true)
	var inner_size = _size - _border_size * 2
	var background_color = null
	match state:
		State.EMPTY:
			background_color = _empty_color
		State.TAKEN:
			background_color = _taken_color
		State.CONFLICT:
			background_color = _conflict_color
		State.AVILABLE:
			background_color = _avilable_color
	draw_rect(Rect2(_border_size, _border_size, inner_size, inner_size), background_color, true)
