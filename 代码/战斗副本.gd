extends Control

# 配置参数
@export var 地图集合路径: String = "res://界面/地图集合.tscn"  # 地图模板场景路径
@export var 滚动阈值: float = -1792  # 地图块向左超出此值则移除
@export var 地图节点名: String = "地图"  # 地图容器唯一名
@export var 玩家节点名: String = "玩家"  # 玩家唯一名
var 移动的距离=0
var 最右侧

# 内部变量
var 地图模板列表: Array = []  # 存储所有地图块模板（来自地图集合）
var 当前地图块: Array = []  # 当前加载的地图块（最多2个）
var 地图集合实例: TabContainer = null  # 地图集合场景实例

var 探索标准块
var 探索度: int = 0  # 总探索度
var 图块事件: Array = []  # 每个图块的探索度数组
var 图块数量: int = 100  # 图块总数
var 副本名称: String = "秋日森林"  # 当前副本名称
var 克隆图块数组: Array = []  # 存储所有克隆的图块节点（用于高效访问）
func _ready() -> void:
	移动的距离=0
	%"玩家".副本=self
	加载_地图模板()#加载地图集合场景，获取所有地图块模板
	%"内容区域".clip_contents = true  # 关键：超出内容区域的部分隐藏
	初始化.节点["副本敌人节点"]=%"敌人节点"
	初始化.节点["战斗副本节点"]=self
	if not 地图模板列表.size()==0:# 3. 初始加载2个地图块（覆盖初始视野）
		加载新地图块(0)  # 第一个地图块位置：x=0
		加载新地图块(-滚动阈值)  # 第二个地图块位置：x=1800（右侧衔接）
	探索标准块=%"探索标准块"
	探索标准块.visible=false
	加载探索节点()
	读取并初始化存档()
	初始化小地图()
#func _process(_delta: float) -> void:
	## 每帧随机选择一个图块（0-99索引），增加值为1
	#var 随机序号 = randi() % 图块数量  # 生成0到99的随机数
	#更新单个图块(随机序号, 1)
func 加载探索节点() -> void:
	for 子节点 in %"小地图网格".get_children():
		if 子节点 != 探索标准块:
			子节点.queue_free()
	克隆图块数组.clear()
	for i in range(1, 101):
		var 图块=探索标准块.duplicate()
		图块.visible=true
		%"小地图网格".add_child(图块)
		克隆图块数组.append(图块)
func 读取并初始化存档() -> void:
	# 读取全局存档中的数据，确保层级结构存在
	var 游历数据 = 初始化.梅存档["游历"]
	if 副本名称 not in 游历数据:
		游历数据[副本名称] = {}# 如果没有默认数据设为空字典
	var 副本数据 = 游历数据[副本名称]
	# 读取图块事件数组，默认100个0
	图块事件 = 副本数据.get("图块事件", [-1])
	if 图块事件==[-1]:#一个不可能的简单值,用于判断存档是否存在
		图块事件=[]
		for i in range(0, 图块数量):
			图块事件.append(0)
	# 确保数组长度正确（防止存档数据异常）
	if 图块事件.size() != 图块数量:
		#这里设计一个存档修复逻辑,如果数量少于图块数量补充到图块数量,多的话不会被读取
		for i in range(0, max(0,图块数量-图块事件.size())):
			图块事件.append(0)
	# 保存回存档（确保默认数据被写入）
	副本数据["图块事件"] = 图块事件
	游历数据[副本名称] = 副本数据
	初始化.梅存档["游历"] = 游历数据
	初始化.保存存档()#这个方法确实有
func 初始化小地图() -> void:
	for i in range(图块数量):
		更新单个图块(i)# 给每个克隆图块设置初始文本（使用克隆图块数值）
# 更新单个图块的探索度（限制最大100），返回更新后的值
func 更新单个图块(图块序号: int, 增加值: int=0) -> int:
	# 边界检查：确保图块序号有效
	if 图块序号 < 0 or 图块序号 >= 图块数量:
		return -1  # 无效序号返回-1
	var 值 = clamp(图块事件[图块序号] + 增加值, 0, 100)  # 限制在0-100之间
	图块事件[图块序号] = 值
	# 获取对应的图块和文本节点
	var 图块 = 克隆图块数组[图块序号]
	var 文本节点 = 图块.get_node("文本")
	文本节点.text = str(值)# 更新文本
	# 更新颜色（应用统一逻辑）
	var 起点: Color = Color(0.654, 0.654, 0.654, 1.0)
	var 中点: Color = Color(0.947, 0.863, 0.0, 1.0)
	var 终点: Color = Color(0.5, 0.9, 0.3)
	if 值 <= 50:
		var 比例= 值 / 50.0
		图块.color = 起点.lerp(中点, 比例)
	else:
		var 比例= (值-50) / 50.0
		图块.color = 中点.lerp(终点, 比例)
	return 值  # 返回更新后的值
func 总探索度更新() -> void:
	# 计算总探索度（数组元素求和）
	探索度 = 图块事件.reduce(func(累加值, 当前值):
		return 累加值 + 当前值, 0)  # 初始值0
	# 打印到控制台
	print("当前副本[", 副本名称, "]总探索度: ", 探索度)
func 加载_地图模板() -> void:# 加载地图集合中的所有地图块模板
	var 地图集合场景 = load(地图集合路径) as PackedScene
	地图集合实例 = 地图集合场景.instantiate()
	# 获取TabContainer的所有子节点（即“1”、“2”等Control地图块）
	var tab_container = 地图集合实例  # 地图集合根节点是TabContainer
	for i in range(tab_container.get_tab_count()):
		var 地图块模板 = tab_container.get_child(i)  # 每个Control子节点
		if 地图块模板.has_node("地图"):  # 确保包含TileMapLayer
			地图模板列表.append(地图块模板)
			地图块模板.visible = false  # 隐藏模板（用克隆体显示）
# 加载新地图块到指定x位置
func 加载新地图块(目标x: float) -> void:
	if 地图模板列表.size()==0:
		return
	# 随机选一个模板克隆（若需顺序循环，可改用索引递增）
	var 随机索引 = randi() % 地图模板列表.size()
	var 模板 = 地图模板列表[随机索引]
	var 新地图块 = 模板.duplicate()  # 克隆地图块（包含TileMapLayer）
	# 设置新地图块属性
	新地图块.visible = true  # 显示克隆体
	新地图块.position = Vector2(目标x, 0)  # Y坐标根据实际调整
	%地图.add_child(新地图块)  # 加入“地图”节点
	当前地图块.append(新地图块)  # 加入管理列表
	最右侧=新地图块

# 玩家调用：传入向左滚动的距离（负数，如-5表示左移5单位）
func 地图更新(移动距离: float) -> void:
	移动的距离+=移动距离
func _physics_process(_帧时: float) -> void:
	if not 移动的距离<0:
		return
	var 移动距离=移动的距离
	var 待移除 = null
	# 1. 移动所有当前地图块
	for 块 in 当前地图块:
		块.position.x += 移动距离  # 移动距离为负，x减小（左移）
		if 块.position.x <= 滚动阈值:
			待移除 = 块
	# 2. 同步怪物位置（随地图左移，保持相对位置）
	for 怪物 in %"敌人节点".get_children():
		if 怪物 is Node2D:
			怪物.position.x += 移动距离
	# 3. 移除超出左侧阈值的地图块，并加载新的
	if not 待移除==null:
		var 最右侧x = 最右侧.position.x
		当前地图块.erase(待移除)
		待移除.queue_free()  # 销毁旧地图块
		# 计算新地图块位置：当前最右侧地图块的x + -滚动阈值
		加载新地图块(最右侧x - 滚动阈值)  # 右侧无缝衔接
	移动的距离=0


# 生成怪物（位置在当前可见地图块范围内）
func 生成敌人() -> void:
	var 怪物模板 = preload("res://界面/敌人模板.tscn").instantiate()
	var 克隆怪物 = 怪物模板.duplicate()
	克隆怪物.visible = true
	# 初始x设在右侧可见区域（例如1500，在第一个地图块右侧）
	克隆怪物.position.x = 1500
	克隆怪物.启用AI()
	%"敌人节点".add_child(克隆怪物)
