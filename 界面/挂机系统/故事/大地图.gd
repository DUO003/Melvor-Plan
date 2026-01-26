extends Node2D
class_name 大地图管理
# 地图层节点引用
@onready var 地图层: TileMapLayer = $地图
@onready var 家具层: TileMapLayer = $家具
@onready var 鼠标层: TileMapLayer = $鼠标
# 保存TileMapPattern数据（导出变量）
@export var 地图资源: TileMapPattern
# 保存原始单元格的起点坐标（绝对坐标）- 改为导出变量类型，满足你的要求
@export var 图案起点坐标: Vector2i = Vector2i(0, 0)
@onready var 玩家: CharacterBody2D = $"../玩家"

# 自定义Resource用于保存完整的地图数据
@export var 地图存档资源: Resource
# 保存地图数据到内存和Resource中
#func _ready() -> void:
	#加载地图数据(家具层)
func _exit_tree() -> void:
	保存地图数据(家具层)
func _physics_process(_间隔: float) -> void:
	var 鼠标全局:Vector2 = get_global_mouse_position()
	var 玩家全局:Vector2 = 玩家.global_position
	玩家全局.y-=70
	var 鼠标局部 = 地图层.to_local(鼠标全局)
	var 方块坐标:Vector2i = 地图层.local_to_map(鼠标局部)
	var 无方块:bool= 鼠标位置无方块(鼠标全局)
	var 平方距离:float = 鼠标全局.distance_squared_to(玩家全局)
	鼠标层.clear()
	if 无方块 and 平方距离<128**2:
		return
	if Input.is_action_just_pressed("放置"):
		var 鼠标节点: Node = get_viewport().gui_get_hovered_control()
		#print("鼠标节点",鼠标节点)
		if not 鼠标节点==null:
			return
		if 无方块:
			家具层.set_cell(方块坐标,0,Vector2i(0, 1))
		else :
			if 地图层.get_cell_source_id(方块坐标)!=-1:
				玩家.启用自动前进=true
				玩家.自动前进目标=鼠标全局.x
			if 家具层.get_cell_source_id(方块坐标)!=-1:
				家具层.erase_cell(方块坐标)
	else :
		鼠标层.set_cell(方块坐标,1,Vector2i(0, 0)if 无方块 else Vector2i(1, 0))
func 鼠标位置无方块(鼠标全局)->bool:
	var 鼠标局部 = 地图层.to_local(鼠标全局)
	var 方块坐标:Vector2i = 地图层.local_to_map(鼠标局部)
	return 地图层.get_cell_source_id(方块坐标)==-1 and 家具层.get_cell_source_id(方块坐标)==-1
func 返回方块ID(鼠标全局,节点: TileMapLayer):
	var 鼠标局部 = 节点.to_local(鼠标全局)
	var 方块坐标:Vector2i = 节点.local_to_map(鼠标局部)
	return 节点.get_cell_source_id(方块坐标)
##保存地图进入存档
func 保存地图数据(地图: TileMapLayer):
	var 地图存档:Dictionary=计划.梅存档.挂机.地图
	var 所有使用的单元格 = 地图.get_used_cells()
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
	地图资源 = 地图.get_pattern(所有使用的单元格)
	地图存档[地图.name]={"坐标":图案起点坐标,"图块":地图资源}
	print("保存成功地图")
## 加载地图数据从TileMapPattern
func 加载地图数据(地图: TileMapLayer) -> void:
	var 地图存档:Dictionary=计划.梅存档.挂机.地图
	if not 地图存档.has(地图.name):
		return
	var 数据字典:Dictionary=地图存档[地图.name]
	var 资源: TileMapPattern=数据字典.图块
	var 坐标:Vector2i=数据字典.坐标
	if 地图 and 资源 and not 资源.is_empty():
		# 用保存的导出变量起点坐标还原，避免位置偏移
		地图.clear()
		地图.set_pattern(坐标, 资源)
		print("加载成功地图")
	else:
		print("⚠无法加载：TileMapPattern为空或无效")
