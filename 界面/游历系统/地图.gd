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
@export var 颜色字典: Dictionary[int,Color] = {2:Color(0.376, 0.825, 0.0, 1.0)}
# 配置参数：长按判定阈值（秒）
@export var 长按判定时间:float = 0.1
@export var 当前地区:String="新手村"
@export var 当前地区解锁:Dictionary={Vector2i(0,0):true}
@export var 战争迷雾:Dictionary={Vector2i(0,0):1}
@export var 玩家坐标:Vector2i=Vector2i(0,0)
@onready var 地图显示: TileMapLayer = %地图显示
@onready var 地图数据: 梅悬浮提示 = %地图数据
@onready var 冒险管理器: 冒险地图 = %冒险管理器
@onready var 前往: Button = %前往
var 载入当前地区:Dictionary
func _ready():
	if not Engine.is_editor_hint():
		加载数据()
		更新战争迷雾()
		call_deferred("更新提示信息",玩家坐标)
		前往.pressed.connect(前往按钮方法)
	拖动函数()
func 加载数据():
	var 游历:=计划.游历
	var 地区数据:=游历.地区数据
	地图显示.clear()
	if 地区数据.has(当前地区) and 地区数据[当前地区].has_all(["范围","地区"]):
		var 当前数据:Dictionary=地区数据[当前地区]
		绘制范围=当前数据.范围 as Rect2i
		载入当前地区=当前数据.地区 as Dictionary
		var 地块数据:=游历.地块数据
		var 方块:物品方块=物品方块.new(-1)
		var 地图信息:地图信息包
		for 列索引 in range(绘制范围.position.x, 绘制范围.position.x + 绘制范围.size.x):
			for 行索引 in range(绘制范围.position.y, 绘制范围.position.y + 绘制范围.size.y):
				var 当前坐标:Vector2i=Vector2i(列索引, 行索引)
				var 方块名称:String=载入当前地区.get(当前坐标,"空")
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
	更新提示信息(地图格子)
	
func 更新提示信息(当前坐标:Vector2i):
	var 地块数据:=计划.游历.地块数据
	var 方块名称:String=载入当前地区.get(当前坐标,"空")
	if not 地块数据.has(方块名称):
		方块名称="空"
	var 当前地块:Dictionary=地块数据[方块名称]
	var 提示数据:=梅提示数据.new()
	提示数据.默认字体=30
	提示数据.提示数组.clear()
	提示数据.提示数组.append({"文本": "[center][font_size=%d]地块名称:%s[/font_size][/center]" % [40,方块名称]})
	提示数据.提示数组.append({"文本": "类型:%s" % [当前地块.get("地块","未知")]})
	地图数据.数据包更新(提示数据)
	if 玩家坐标==当前坐标:
		前往.text="当前"
	else :
		前往.text="前往"
func 前往按钮方法():
	pass
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
	var 迷雾:int=获取迷雾(Vector2i(列索引, 行索引))
	if 地图提示:
		地图提示.打印("%d,%d"%[列索引,行索引],中心点,顶点列表,迷雾)
	if 颜色字典.has(迷雾) and not Engine.is_editor_hint():
		var 填充颜色数组: PackedColorArray = PackedColorArray()
		for i in 顶点列表:  # 遍历顶点列表，为每个顶点添加相同的填充颜色
			填充颜色数组.append(颜色字典[迷雾])
		draw_polygon(顶点列表, 填充颜色数组)
	return
# 获取六边形相邻有效格子坐标（输入改为Vector2i类型的目标坐标）
func 获取六边形相邻格子(目标坐标: Vector2i) -> Array[Vector2i]:
	# 从Vector2i中提取列索引（x）和行索引（y）
	var 目标列索引 = 目标坐标.x
	var 目标行索引 = 目标坐标.y
	
	# 存储最终有效的相邻格子坐标
	var 有效相邻格子: Array[Vector2i] = []
	
	# 定义六边形网格的偏移规则：改用Vector2i存储偏移（列偏移=x，行偏移=y）
	var 偏移列表: Array[Vector2i]
	if 目标行索引 % 2 == 0:
		# 偶数行（行索引为0、2、4...）的6个相邻偏移
		偏移列表 = [
			Vector2i(-1, -1), Vector2i(0, -1),  # 左上、上
			Vector2i(-1, 0),  Vector2i(1, 0),   # 左、右
			Vector2i(-1, 1),  Vector2i(0, 1)    # 左下、下
		]
	else:
		# 奇数行（行索引为1、3、5...）的6个相邻偏移
		偏移列表 = [
			Vector2i(0, -1),  Vector2i(1, -1),  # 上、右上
			Vector2i(-1, 0),  Vector2i(1, 0),   # 左、右
			Vector2i(0, 1),   Vector2i(1, 1)    # 下、右下
		]
	
	# 遍历所有偏移，计算相邻格子并校验边界有效性
	for 偏移 in 偏移列表:
		# 计算相邻格子的行列索引（x对应列，y对应行）
		var 新列索引 = 目标列索引 + 偏移.x
		var 新行索引 = 目标行索引 + 偏移.y
		
		# 校验是否在绘制范围的矩形边界内（适配range左闭右开的生成逻辑）
		var 列有效 = 新列索引 >= 绘制范围.position.x and 新列索引 < 绘制范围.position.x + 绘制范围.size.x
		var 行有效 = 新行索引 >= 绘制范围.position.y and 新行索引 < 绘制范围.position.y + 绘制范围.size.y
		
		# 仅保留边界内的有效坐标
		if 列有效 and 行有效:
			有效相邻格子.append(Vector2i(新列索引, 新行索引))
	
	return 有效相邻格子
# 核心方法：根据已解锁格子更新战争迷雾字典
func 更新战争迷雾():
	# 1. 清空旧的战争迷雾数据，避免残留干扰
	战争迷雾.clear()
	
	# 2. 先收集所有需要处理的格子：占领格子 + 其周围格子
	var 占领格子列表: Array[Vector2i] = []
	# 遍历当前地区解锁字典，筛选出已占领的格子（value为true）
	for 格子坐标 in 当前地区解锁:
		if 当前地区解锁[格子坐标] is bool and 当前地区解锁[格子坐标]:
			占领格子列表.append(格子坐标)
	
	# 3. 处理占领格子：设为1
	for 占领坐标 in 占领格子列表:
		战争迷雾[占领坐标] = 1
	
	# 4. 处理占领格子的周围格子：设为0（注意：不覆盖已设为1的占领格子）
	for 占领坐标 in 占领格子列表:
		# 获取该占领格子的所有相邻有效格子
		var 周围格子列表 = 获取六边形相邻格子(占领坐标)
		for 周围坐标 in 周围格子列表:
			# 仅当该格子不未写入才设为0（避免覆盖1）
			if not 战争迷雾.has(周围坐标):
				战争迷雾[周围坐标] = 0

# 可选：获取指定格子的战争迷雾值（处理默认值-1）
func 获取迷雾(格子坐标: Vector2i) -> int:
	if Engine.is_editor_hint():
		return 1
	if 玩家坐标==格子坐标:
		return 2
	return 战争迷雾.get(格子坐标, -1)
