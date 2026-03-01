@tool  # 启用编辑器内预览
extends Control

@export var 绘制范围: Rect2i = Rect2i(-5, -5, 10, 10):
	set(值):
		绘制范围=值
		if Engine.is_editor_hint():queue_redraw()
# 绘制偏移: 整个绘制内容的相对偏移
@export var 绘制偏移: Vector2 = Vector2(0, 0):
	set(值):
		绘制偏移=值
		if Engine.is_editor_hint():queue_redraw()
# 六边形外接圆半径
@export var 半径: int = 64:
	set(值):
		半径=值
		if Engine.is_editor_hint():queue_redraw()
@export var 填充颜色: Color = Color(0.8, 0.9, 1.0, 0.7)  # 填充色（浅蓝半透明）
# 配置参数：长按判定阈值（秒）
@export var 长按判定时间:float = 0.1
@export var 当前地区:String="新手村"
@export var 玩家坐标:Vector2i=Vector2i(0,0)
@onready var 地图显示: TileMapLayer = %地图显示
@onready var 地图数据: 梅悬浮提示 = %地图数据
@onready var 冒险管理器: 冒险地图 = %冒险管理器

func _ready():
	if not Engine.is_editor_hint():
		加载数据()
	拖动函数()
func 加载数据():
	var 游历:=计划.游历
	var 地区数据:=游历.地区数据
	地图显示.clear()
	if 地区数据.has(当前地区) and 地区数据[当前地区].has_all(["范围","地区"]):
		var 当前数据:Dictionary=地区数据[当前地区]
		绘制范围=当前数据.范围 as Rect2i
		var 地区:Dictionary=当前数据.地区 as Dictionary
		var 地块数据:=游历.地块数据
		var 方块:物品方块=物品方块.new(-1)
		var 地图信息:地图信息包
		for 列索引 in range(绘制范围.position.x, 绘制范围.position.x + 绘制范围.size.x):
			for 行索引 in range(绘制范围.position.y, 绘制范围.position.y + 绘制范围.size.y):
				var 当前坐标:Vector2i=Vector2i(列索引, 行索引)
				var 方块名称:String=地区.get(当前坐标,"空")
				if not 地块数据.has(方块名称):
					方块名称="空"
				var 当前地块:Dictionary=地块数据[方块名称]
				var 方块数据:Dictionary=方块.查询方块数据(当前地块.地块)
				if 玩家坐标==当前坐标:
					地图信息=load(当前地块.图块)
				地图显示.set_cell(当前坐标,方块数据.瓦片集,Vector2i(方块数据.瓦片列,方块数据.瓦片排))
		if not 地图信息:
			地图信息=地块数据.新手村.图块
		call_deferred("延迟加载地图",地图信息)
	else :
		print("报错:找不到地区")
func 延迟加载地图(地图信息:地图信息包):
	冒险管理器.加载地图(地图信息)
# 状态变量
var 是否按下鼠标左键 = false  # 标记鼠标左键是否按下
var 按下开始时间 = 0.0        # 记录鼠标按下的时间戳
var 是否判定为拖动 = false    # 标记是否已进入拖动状态
var 按下时的鼠标位置 = Vector2.ZERO  # 记录按下时的鼠标位置


func _gui_input(事件: InputEvent):
	if 事件 is InputEventMouseButton:
		if not 事件.button_index == MOUSE_BUTTON_LEFT:# 只处理鼠标左键事件
			return
		if 事件.pressed:# 鼠标按下
			是否按下鼠标左键 = true
			按下开始时间 = Time.get_unix_time_from_system()  # 记录按下时间
			按下时的鼠标位置 = 事件.position  # 记录按下位置
			是否判定为拖动 = false  # 初始化为非拖动状态
			拖动偏移量 = 事件.position - 绘制偏移
		else:# 鼠标弹起
			# 弹起时如果未判定为拖动，视为点击
			if not 是否判定为拖动:
				点击函数(事件.global_position)
			# 重置所有状态
			是否按下鼠标左键 = false
			是否判定为拖动 = false
	elif 事件 is InputEventMouseMotion:# 处理鼠标移动事件（用于拖动判定）
		if not 是否按下鼠标左键:
			return
		var 按下时长 = Time.get_unix_time_from_system() - 按下开始时间
		if 按下时长 > 长按判定时间:# 按下时长超过阈值，判定为拖动
			是否判定为拖动 = true
			拖动函数(事件.position)
# 鼠标点击位置与节点原点的偏移量
var 拖动偏移量: Vector2 = Vector2.ZERO
func 点击函数(鼠标全局: Vector2):
	var 鼠标局部 = 地图显示.to_local(鼠标全局)
	var 地图格子:Vector2i=地图显示.local_to_map(鼠标局部)
	var 提示数据:=梅提示数据.new()
	提示数据.提示数组.clear()
	提示数据.提示数组.append({"文本": "[center][font_size=%d]%s[/font_size][/center]" % [30,str(地图格子)]})
	地图数据.数据包更新(提示数据)
func 拖动函数(鼠标位置: Vector2=绘制偏移 + 拖动偏移量):
	绘制偏移 = 鼠标位置 - 拖动偏移量
	地图显示.position=绘制偏移+Vector2(-64, -64)
	queue_redraw()
func _draw():
	if 地图提示:
		地图提示.清空打印日志()
	for 列索引 in range(绘制范围.position.x, 绘制范围.position.x + 绘制范围.size.x):
		for 行索引 in range(绘制范围.position.y, 绘制范围.position.y + 绘制范围.size.y):
			生成六边形(列索引, 行索引)
	if 地图提示:
		地图提示.queue_redraw()
##宽度
var 宽度:float=2#3 ** 0.5
## 计算指定行列的六边形中心点坐标
@onready var 地图提示: Control = $地图提示
func 计算六边形中心点(列索引: int, 行索引: int) -> Vector2:
	var 中心x: float
	var 中心y: float = 行索引 * 半径*1.5
	if 行索引 % 2 != 0:# 奇数行需要横向偏移半个间距，保证六边形拼接正确
		中心x = (列索引+0.5) * 半径*宽度
	else:中心x = 列索引 * 半径*宽度
	# 应用整体绘制偏移
	return Vector2(中心x, 中心y) + 绘制偏移
# 根据中心点生成六边形的6个顶点
func 生成六边形(列索引: int, 行索引: int):
	var 中心点: Vector2 = 计算六边形中心点(列索引, 行索引)
	var 顶点列表: PackedVector2Array = PackedVector2Array()
	# 六边形每个顶点间隔60度，从正上方开始计算
	for 角度索引 in range(6):
		var 弧度: float = deg_to_rad(60 * 角度索引 + 90)  # +90让第一个顶点在正上方
		var x: float = 中心点.x + 半径 * cos(弧度)*1.18
		var y: float = 中心点.y - 半径 * sin(弧度)  # Godot Y轴向下，取反
		顶点列表.append(Vector2(x, y))
	# 闭合多边形（添加第一个顶点到末尾）
	顶点列表.append(顶点列表[0])
	if 地图提示:
		地图提示.打印("%d,%d"%[列索引,行索引],中心点,顶点列表,{Vector2i(0,0):true}.has(Vector2i(列索引, 行索引)))
	var 填充颜色数组: PackedColorArray = PackedColorArray()
	for i in 顶点列表:  # 遍历顶点列表，为每个顶点添加相同的填充颜色
		填充颜色数组.append(填充颜色)
	draw_polygon(顶点列表, 填充颜色数组)
	return
