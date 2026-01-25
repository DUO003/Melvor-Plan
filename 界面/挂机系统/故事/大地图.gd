extends Node2D

# 地图层节点引用
@onready var 地图层: TileMapLayer = $地图
@onready var 鼠标层: TileMapLayer = $鼠标
# 保存TileMapPattern数据（导出变量）
@export var 地图资源: TileMapPattern
# 保存原始单元格的起点坐标（绝对坐标）- 改为导出变量类型，满足你的要求
@export var 图案起点坐标: Vector2i = Vector2i(0, 0)

# 自定义Resource用于保存完整的地图数据
@export var 地图存档资源: Resource
var 地图存档:Dictionary
# 保存地图数据到内存和Resource中
func _ready() -> void:
	地图存档=计划.梅存档.挂机.地图
	#if 地图存档.has(地图层.name):
		#var 数据字典:Dictionary=地图存档[地图层.name]
		#加载地图数据(数据字典.图块,数据字典.坐标)
	#else :
		#保存地图数据()
func _physics_process(间隔: float) -> void:
	var 鼠标全局 = get_global_mouse_position()
	var 鼠标局部 = 地图层.to_local(鼠标全局)
	var 方块坐标 = 地图层.local_to_map(鼠标局部)
	print("鼠标指向的方块坐标：", 方块坐标)
	鼠标层.clear()
	鼠标层.set_cell(方块坐标,0,Vector2i(0, 1))
##保存地图进入存档
func 保存地图数据():
	var 所有使用的单元格 = 地图层.get_used_cells()
	if 所有使用的单元格.is_empty():
		print("⚠ 没有可保存的单元格")
		return
	var min_x = 所有使用的单元格[0].x
	var min_y = 所有使用的单元格[0].y
	for cell in 所有使用的单元格:
		if cell.x < min_x:
			min_x = cell.x
		if cell.y < min_y:
			min_y = cell.y
	图案起点坐标 = Vector2i(min_x, min_y)
	地图资源 = 地图层.get_pattern(所有使用的单元格)
	地图存档[地图层.name]={"坐标":图案起点坐标,"图块":地图资源}
## 加载地图数据从TileMapPattern
func 加载地图数据(资源: TileMapPattern,坐标:Vector2i) -> void:
	if 地图层 and 资源 and not 资源.is_empty():
		# 用保存的导出变量起点坐标还原，避免位置偏移
		地图层.clear()
		地图层.set_pattern(坐标, 资源)
		print("加载成功地图")
	else:
		print("⚠ 无法加载：TileMapPattern为空或无效")
