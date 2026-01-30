extends Node2D
class_name 大地图管理
# 地图层节点引用
@onready var 地图层: TileMapLayer = $地图
@onready var 家具层: TileMapLayer = $家具
@onready var 鼠标层: TileMapLayer = $鼠标
@onready var 碰撞层: TileMapLayer = $碰撞
# 保存TileMapPattern数据（导出变量）
@export var 地图资源: TileMapPattern

@export var 建筑数据:Dictionary={Vector2i(1, 4):"移动操作提示\nWASD或鼠标点击地面移动\n空格跳跃,点击高处平台传送"}
# 保存原始单元格的起点坐标（绝对坐标）- 改为导出变量类型，满足你的要求
@export var 图案起点坐标: Vector2i = Vector2i(0, 0)
@onready var 玩家: CharacterBody2D = $"../玩家"
@onready var 摄像机: Camera2D = $"../玩家/摄像机"
# 自定义Resource用于保存完整的地图数据
@export var 地图存档资源: Resource
var 地图层数组:Array
var 提示框 = preload("res://界面/挂机系统/故事/提示框.tscn").instantiate()
var 节点字典:Dictionary[Vector2i,Control]={}
enum 功能枚举{无,寻路,放置,挖掘}
var 当前功能:功能枚举=功能枚举.无
var 方块检索字典:=计划.表格.方块检索字典
var 方块字典:=计划.表格.方块字典
func _ready() -> void:
	加载地图数据(家具层)
	碰撞层.visible=false
	地图层数组=[地图层,家具层]
	加载碰撞范围()
	await get_tree().process_frame
	摄像机.position_smoothing_enabled=true
	计划.全局保存.connect(保存地图数据.bind(家具层))
func _exit_tree() -> void:
	保存地图数据(家具层)
var 挖掘计时器:float=0
func _physics_process(间隔: float) -> void:
	状态机更新()
	var 鼠标全局:Vector2 = get_global_mouse_position()
	var 鼠标局部 = 地图层.to_local(鼠标全局)
	var 方块坐标:Vector2i = 返回鼠标位置方块坐标(鼠标局部)
	var 无方块:bool= 鼠标位置无方块(方块坐标)
	var 点击屏幕:bool=Input.is_action_just_pressed("点击屏幕")
	鼠标层.clear()
	if not 功能枚举.挖掘:挖掘计时器=0
	var 鼠标节点: Node = get_viewport().gui_get_hovered_control()
	if not 鼠标节点==null:return
	match 当前功能:
		功能枚举.寻路:
			if 点击屏幕:
				if 地图层.get_cell_source_id(方块坐标)!=-1:
					玩家.启用自动前进=true
					玩家.自动前进目标=鼠标全局.x
					方块检查器.visible=false
				else :
					var 方块名称:=获取方块名称(方块坐标)
					if not 方块名称=="":方块检查器.加载方块(方块名称,方块坐标)
		功能枚举.挖掘:
			#if 点击屏幕:print(家具层.get_cell_source_id(方块坐标),家具层.get_cell_atlas_coords(方块坐标))
			if Input.is_action_pressed("点击屏幕") and 家具层.get_cell_source_id(方块坐标)!=-1:
				挖掘计时器+=间隔
				if 挖掘计时器>=1:
					移除方块(方块坐标)
					挖掘计时器=0
				else :
					var 挖掘帧:int=int(挖掘计时器*5)
					鼠标层.set_cell(方块坐标,1,Vector2i(挖掘帧, 2))
				return
			else :挖掘计时器=0
		功能枚举.放置:
			var 物品:物品方块=计划.地图.返回快捷键物品()
			if 物品:
				var 玩家全局:Vector2 = 玩家.global_position
				var 平方距离:float = 鼠标全局.distance_squared_to(玩家全局)
				if 无方块 and 平方距离<128**2:return
				var 列:int=物品.columns
				var 排:int=物品.rows
				var 碰撞结果:bool
				if 地图层.get_cell_source_id(方块坐标+Vector2i(0,1))==-1:
					碰撞结果=false
				else :
					碰撞结果=检查碰撞(方块坐标,Vector2i(列,排))
				if 点击屏幕:
					if 碰撞结果:放置方块(方块坐标,物品)
					else :
						var 方块名称:=获取方块名称(方块坐标)
						if 方块名称==物品.item_name:
							方块检查器.加载方块(方块名称,方块坐标)
						else :
							计划.语法糖通知("当前位置不能放置建筑","建筑提示")
				else :
					if 地图层.get_cell_source_id(方块坐标+Vector2i(0,1))==-1:
						碰撞结果=false
					else :碰撞结果=检查碰撞(方块坐标,Vector2i(列,排))
					填充碰撞(方块坐标,Vector2i(列,排),鼠标层,1,Vector2i(1, 1)if 碰撞结果 else Vector2i(0, 1))
	鼠标层.set_cell(方块坐标,1,Vector2i(0, 0)if 无方块 else Vector2i(1, 0))
func 状态机更新():
	var 快捷栏状态:int=计划.地图.快捷栏编号
	match 快捷栏状态:
		-1:当前功能=功能枚举.挖掘
		0:当前功能=功能枚举.寻路
		_:当前功能=功能枚举.放置
func 返回鼠标位置方块坐标(鼠标局部)->Vector2i:
	return 地图层.local_to_map(鼠标局部)
func 鼠标位置无方块(方块坐标)->bool:
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
		图案起点坐标 = Vector2i(0, 0)
		地图资源 = null  # 用null标识空地图
	else :
		var min_x = 所有使用的单元格[0].x
		var min_y = 所有使用的单元格[0].y
		for cell in 所有使用的单元格:
			if cell.x < min_x:
				min_x = cell.x
			if cell.y < min_y:
				min_y = cell.y
		图案起点坐标 = Vector2i(min_x, min_y)
		地图资源 = 地图.get_pattern(所有使用的单元格)
	地图存档[地图.name]={"坐标":图案起点坐标,"图块":地图资源,"玩家":玩家.global_position,"建筑":建筑数据}
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
		if 数据字典.has("玩家"):
			玩家.global_position=数据字典.玩家
		if 数据字典.has("建筑"):
			建筑数据=数据字典.建筑
		print("加载成功地图",地图.name,数据字典)
@onready var 按钮区: Control = $按钮区
@onready var 界面提示: Control = %界面提示
@onready var 方块检查器: 检查器方块 = %方块检查器
func 加载碰撞范围():
	碰撞层.clear()
	计划.清除子节点(按钮区)
	计划.清除子节点(界面提示)
	节点字典={}
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
				var 瓦片功能:String=当前方块字典.get("功能","")
				加载方块功能(单元格坐标,列,排,方块名称,瓦片功能)
			else :
				碰撞层.set_cell(单元格坐标,1,Vector2i(0,1))
func 放置方块(方块坐标:Vector2i,物品:物品方块):
	家具层.set_cell(方块坐标,物品.瓦片集,Vector2i(物品.瓦片列, 物品.瓦片排))
	填充碰撞(方块坐标,Vector2i(物品.columns, 物品.rows))
	if 物品.瓦片功能=="解锁窗口":
		计划.解锁窗口(物品.功能参数)
	elif 物品.瓦片功能=="显示提示":
		建筑数据[方块坐标]="点击方块打开设置提示"
	加载方块功能(方块坐标,物品.columns, 物品.rows,物品.item_name,物品.瓦片功能)
	if 物品.瓦片功能=="显示提示":
		var 节点=节点字典[方块坐标]
		if 节点:
			if 节点 is 提示框场景:
				节点.切换提示状态(true)
	保存地图数据(家具层)
	计划.地图.放置快捷键物品()
func 加载方块功能(单元格坐标,列,排,方块名称,瓦片功能):
	填充碰撞(单元格坐标,Vector2i(列,排))
	if 瓦片功能=="":
		pass
	elif ["解锁窗口","对话任务"].has(瓦片功能):
		var 按钮:=Button.new()
		按钮.text=方块名称
		按钮.position=Vector2(单元格坐标.x*128+128*(0.5*列-0.75),650)
		按钮.pressed.connect(方块检查器.加载方块.bind(方块名称,单元格坐标))
		按钮区.add_child(按钮)
		节点字典[单元格坐标]=按钮
	elif ["显示提示"].has(瓦片功能):
		var 提示=提示框.duplicate()
		提示.提示内容=建筑数据.get(单元格坐标,"")
		提示.提示名称=str(单元格坐标)
		提示.position=Vector2(单元格坐标.x*128+32,200)
		界面提示.add_child(提示)
		节点字典[单元格坐标]=提示
	print("瓦片功能",瓦片功能)
func 移除方块(方块坐标:Vector2i):
	var 方块名称:=获取方块名称(方块坐标)
	if not 方块名称=="":
		var 物品:物品方块=计划.获得物品语法糖(方块名称,1,"物品方块")
		var 节点:Control=节点字典.get(方块坐标,null)
		if 节点:
			节点.queue_free()
		节点字典.erase(方块坐标)
		建筑数据.erase(方块坐标)
		移除碰撞(方块坐标,Vector2i(物品.columns,物品.rows))
	家具层.erase_cell(方块坐标)
	保存地图数据(家具层)
	计划.地图.获取背包消息()
func 填充碰撞(单元格坐标:Vector2i,填充范围:Vector2i=Vector2i(1,1),地图:TileMapLayer=碰撞层,
	源ID:int=1,填充图块:Vector2i=Vector2i(0,1)):
	for X in 填充范围.x:
		for Y in 填充范围.y:
			var 填充:Vector2i=单元格坐标+Vector2i(X,-Y)
			地图.set_cell(填充,源ID,填充图块)
func 移除碰撞(单元格坐标:Vector2i,填充范围:Vector2i=Vector2i(1,1),地图:TileMapLayer=碰撞层):
	for X in 填充范围.x:
		for Y in 填充范围.y:
			var 填充:Vector2i=单元格坐标+Vector2i(X,-Y)
			地图.erase_cell(填充)
func 检查碰撞(单元格坐标:Vector2i,填充范围:Vector2i=Vector2i(1,1))->bool:
	for X in 填充范围.x:
		for Y in 填充范围.y:
			var 检查:Vector2i=单元格坐标+Vector2i(X,-Y)
			var 源ID := 碰撞层.get_cell_source_id(检查)
			if not 源ID==-1:
				return false
	return true
func 获取方块(玩家坐标:Vector2)->String:
	var 玩家局部 = 地图层.to_local(玩家坐标+Vector2(0,-100))
	var 方块坐标:Vector2i = 家具层.local_to_map(玩家局部)
	return 获取方块名称(方块坐标)
func 获取方块名称(方块坐标:Vector2i)->String:
	var 源ID := 家具层.get_cell_source_id(方块坐标)
	if not 源ID==-1:
		var 图集坐标 :Vector2i= 家具层.get_cell_atlas_coords(方块坐标)
		var 访问坐标:Vector3i=Vector3i(源ID,图集坐标.x,图集坐标.y)
		return 方块检索字典.get(访问坐标,"")
	return ""
func 延迟切换(窗口):
	计划.call_deferred("切换场景",null,窗口)
