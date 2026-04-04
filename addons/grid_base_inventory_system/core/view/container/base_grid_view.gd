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
@export var 格子覆盖:bool=false:
	set(值):
		格子覆盖 = 值
		queue_redraw()
		#空、占用、冲突、可用
@export var 覆盖样式_空: StyleBoxFlat:
	set(值):# 断开旧资源的信号连接
		_样式信号绑定(覆盖样式_空,false)
		_样式信号绑定(值,true)
		覆盖样式_空 = 值
		if Engine.is_editor_hint():
			queue_redraw()
@export var 覆盖样式_占用: StyleBoxFlat:
	set(值):# 断开旧资源的信号连接
		_样式信号绑定(覆盖样式_占用,false)
		_样式信号绑定(值,true)
		覆盖样式_占用 = 值
		if Engine.is_editor_hint():
			queue_redraw()
@export var 覆盖样式_冲突: StyleBoxFlat:
	set(值):# 断开旧资源的信号连接
		_样式信号绑定(覆盖样式_冲突,false)
		_样式信号绑定(值,true)
		覆盖样式_冲突 = 值
		if Engine.is_editor_hint():
			queue_redraw()
@export var 覆盖样式_可用: StyleBoxFlat:
	set(值):# 断开旧资源的信号连接
		_样式信号绑定(覆盖样式_可用,false)
		_样式信号绑定(值,true)
		覆盖样式_可用 = 值
		if Engine.is_editor_hint():
			queue_redraw()
func _样式信号绑定(样式:StyleBoxFlat,状态:bool,监听方法:=queue_redraw):
	if not Engine.is_editor_hint():
		return
	if 状态:
		if 样式 != null and not 样式.changed.is_connected(监听方法):
			样式.changed.connect(监听方法)# 连接资源的信号
	else :
		if 样式 != null and 样式.changed.is_connected(监听方法):
			样式.changed.disconnect(监听方法)# 断开资源的信号
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
	var 矩形新尺寸:=Rect2(_border_size, _border_size, inner_size, inner_size)
	if 格子覆盖:
		match state:
			State.EMPTY:
				draw_style_box(覆盖样式_空, 矩形新尺寸)
			State.TAKEN:
				draw_style_box(覆盖样式_占用, 矩形新尺寸)
			State.CONFLICT:
				draw_style_box(覆盖样式_冲突, 矩形新尺寸)
			State.AVILABLE:
				draw_style_box(覆盖样式_可用, 矩形新尺寸)
	else :
		match state:
			State.EMPTY:
				background_color = _empty_color
			State.TAKEN:
				background_color = _taken_color
			State.CONFLICT:
				background_color = _conflict_color
			State.AVILABLE:
				background_color = _avilable_color
		draw_rect(矩形新尺寸, background_color, true)
