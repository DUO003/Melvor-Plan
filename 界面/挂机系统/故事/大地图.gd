extends Node2D
class_name 大地图管理
# 地图层节点引用
@onready var 地图层: TileMapLayer = $地图
@onready var 家具层: TileMapLayer = $家具
@onready var 鼠标层: TileMapLayer = $鼠标
@onready var 碰撞层: TileMapLayer = $碰撞
# 保存TileMapPattern数据（导出变量）
@export var 地图资源: TileMapPattern
# 保存原始单元格的起点坐标（绝对坐标）- 改为导出变量类型，满足你的要求
@export var 图案起点坐标: Vector2i = Vector2i(0, 0)
@onready var 玩家: CharacterBody2D = $"../玩家"

# 自定义Resource用于保存完整的地图数据
@export var 地图存档资源: Resource
var 地图层数组:Array
# 保存地图数据到内存和Resource中
func _ready() -> void:
	加载地图数据(家具层)
	碰撞层.visible=false
	地图层数组=[地图层,家具层]
	加载碰撞范围()
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
	var 鼠标节点: Node = get_viewport().gui_get_hovered_control()
	if not 鼠标节点==null:
		return
	var 物品:物品方块=计划.地图.返回快捷键物品()
	if 物品:
		碰撞层.visible=true
	else :
		碰撞层.visible=false
	if Input.is_action_just_pressed("放置"):
		if 物品 and 无方块:
			var 列:int=物品.columns
			var 排:int=物品.rows
			var 碰撞结果:bool
			if 地图层.get_cell_source_id(方块坐标+Vector2i(0,1))==-1:
				碰撞结果=false
			else :
				碰撞结果=检查碰撞(方块坐标,Vector2i(列,排))
			if 碰撞结果:
				家具层.set_cell(方块坐标,物品.瓦片集,Vector2i(物品.瓦片列, 物品.瓦片排))
				加载碰撞范围()
				计划.地图.放置快捷键物品()
			else :
				计划.语法糖通知("当前位置不能放置建筑","建筑提示")
		else :
			if 家具层.get_cell_source_id(方块坐标)!=-1:
				家具层.erase_cell(方块坐标)
				加载碰撞范围()
			if 地图层.get_cell_source_id(方块坐标)!=-1:
				玩家.启用自动前进=true
				玩家.自动前进目标=鼠标全局.x
	else :
		if 物品:
			var 列:int=物品.columns
			var 排:int=物品.rows
			var 碰撞结果:bool
			if 地图层.get_cell_source_id(方块坐标+Vector2i(0,1))==-1:
				碰撞结果=false
			else :
				碰撞结果=检查碰撞(方块坐标,Vector2i(列,排))
			填充碰撞(方块坐标,Vector2i(列,排),鼠标层,1,Vector2i(1, 1)if 碰撞结果 else Vector2i(0, 1))
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
func 加载碰撞范围():
	碰撞层.clear()
	var 方块检索字典:=计划.表格.方块检索字典
	var 方块字典:=计划.表格.方块字典
	for 地图层级: TileMapLayer in 地图层数组:
		var 已使用单元格数组= 地图层级.get_used_cells()
		for 单元格坐标 in 已使用单元格数组:
			var 源ID := 地图层级.get_cell_source_id(单元格坐标)
			var 图集坐标 :Vector2i= 地图层级.get_cell_atlas_coords(单元格坐标)
			var 访问坐标:Vector3i=Vector3i(源ID,图集坐标.x,图集坐标.y)
			if 方块检索字典.has(访问坐标):
				var 方块名称:String=方块检索字典[访问坐标]
				var 当前方块字典:Dictionary=方块字典[方块名称]
				var 列:int=当前方块字典.get("列",1)
				var 排:int=当前方块字典.get("排",1)
				填充碰撞(单元格坐标,Vector2i(列,排))
			else :
				碰撞层.set_cell(单元格坐标,1,Vector2i(0,1))
func 填充碰撞(单元格坐标:Vector2i,填充范围:Vector2i=Vector2i(1,1),地图:TileMapLayer=碰撞层,
	源ID:int=1,填充图块:Vector2i=Vector2i(0,1)):
	for X in 填充范围.x:
		for Y in 填充范围.y:
			var 填充:Vector2i=单元格坐标+Vector2i(X,-Y)
			地图.set_cell(填充,源ID,填充图块)
func 检查碰撞(单元格坐标:Vector2i,填充范围:Vector2i=Vector2i(1,1))->bool:
	for X in 填充范围.x:
		for Y in 填充范围.y:
			var 检查:Vector2i=单元格坐标+Vector2i(X,-Y)
			var 源ID := 碰撞层.get_cell_source_id(检查)
			if not 源ID==-1:
				return false
	return true
func 获取方块(方块坐标:Vector2i)->String:
	var 方块检索字典:=计划.表格.方块检索字典
	for 地图层级: TileMapLayer in 地图层数组:
		var 源ID := 地图层级.get_cell_source_id(方块坐标)
		if not 源ID==-1:
			var 图集坐标 :Vector2i= 地图层级.get_cell_atlas_coords(方块坐标)
			var 访问坐标:Vector3i=Vector3i(源ID,图集坐标.x,图集坐标.y)
			return 方块检索字典.get(访问坐标,"")
	return ""
