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
func 生成副本事件(种子:int) -> Dictionary:
	var 随机生成器: RandomNumberGenerator= RandomNumberGenerator.new()
	随机生成器.seed = 种子#默认种子为int类型=666
	var 结果字典 = {}
	var 已占用图块 = []  # 记录已分配事件的图块序号
	var 所有图块序号 = range(0, 图块数量)  # 0-99的数组
	var 深层地块 = range(图块数量 - 10, 图块数量)  # 最后10个地块：90-99
	var 可用图块 = 所有图块序号.duplicate()
	seed(随机生成器.randi())
	可用图块.shuffle()
	深层地块.shuffle()
	for 事件数据 in 通关事件池:# 1. 处理通关事件
		var 选中的地块序号
		if 事件数据["生成需求"]=="深层事件" and 深层地块.size() >= 1:
			选中的地块序号 = 深层地块.pop_back()
			可用图块.erase(选中的地块序号)  # 移除已选地块，避免重复
		else:
			print("通关事件生成错误,改为普通生成方式")
			选中的地块序号=可用图块.pop_back()
		结果字典[选中的地块序号] = 事件数据["事件内容"].duplicate()
		已占用图块.append(选中的地块序号)
	for _i in range(min(战斗事件数量,可用图块.size())):#生成战斗事件
		var 选中的地块序号 = 可用图块.pop_front()
		结果字典[选中的地块序号] = 生成战斗事件(随机生成器.randi())
	
	for _i in range(min(剧情事件数量,可用图块.size())):#生成剧情事件
		var 选中的地块序号 = 可用图块.pop_front()
		var 随机剧情模板 = 剧情事件池[随机生成器.randi_range(0, 剧情事件池.size() - 1)]
		结果字典[选中的地块序号] = 随机剧情模板.duplicate()
	# 5. 生成资源事件（随机资源+数量，每个事件占1个剩余图块）
	for _i in range(min(资源事件数量,可用图块.size())):
		var 选中的地块序号 = 可用图块.pop_front()
		结果字典[选中的地块序号] = 生成资源事件(随机生成器.randi())
	randomize()#刷新随机数避免其他程序受地图影响(然并软)
	return 结果字典
# 生成战斗事件：按概率1-5个僵尸，返回{探索度: 事件文本}
func 生成战斗事件(种子) -> Dictionary:
	var 事件随机生成器=RandomNumberGenerator.new()
	事件随机生成器.seed = 种子
	var 数量概率值 = 事件随机生成器.randf()  # 0-1的随机浮点数
	var 怪物数量: int
	if 数量概率值 < 0.1:# 概率分布：80%1个、10%2个、~3.3%3/4/5个
		怪物数量 = 2+ceil(数量概率值*30)
	elif 数量概率值 < 0.2:
		怪物数量 = 2
	else:
		怪物数量 = 1
	var 触发点=range(10, 地块满探索度+1,10)
	seed(事件随机生成器.randi())
	触发点.shuffle()
	var 事件字典={}
	for i in range(0, 怪物数量):
		var 事件序号=触发点[i]
		事件字典[事件序号]=["僵尸"]
	return 事件字典
# 生成资源事件：随机资源+数量，返回{探索度: 事件文本}
func 生成资源事件(种子) -> Dictionary:
	var 事件随机生成器=RandomNumberGenerator.new()
	事件随机生成器.seed = 种子
	var 随机资源类型 = 资源事件池[事件随机生成器.randi_range(0, 资源事件池.size() - 1)]
	var 随机资源数量 = 事件随机生成器.randi_range(1, 10)  # 1-10个资源
	var 触发点=range(10, 地块满探索度+1,10)
	seed(事件随机生成器.randi())
	触发点.shuffle()
	var 事件字典={触发点[0]:str(随机资源类型)+str(随机资源数量)}
	return 事件字典
	
	
	
func 处理动作(动作名称):
	if 动作名称=="探索更新":
		探索更新()
func 探索更新(序号=-1,探索进度=图块探索效率) -> void:
	if 序号 == -1:#按模式选择目标序号（若未指定序号）
		var 有效节点列表: Array[int] = []#收集所有有效可探索节点
		for i in range(探索状态数组.size()):
			if 探索状态数组[i]:  # 仅保留可探索的节点
				有效节点列表.append(i)
		# 若没有有效节点，直接返回
		if 有效节点列表.size()==0:
			print("没有可探索的有效节点")
			return
		var 探索模式=探索选项节点.text
		match 探索模式:
			"完全随机":# 从所有有效节点中随机选一个
				序号 = 有效节点列表[randi() % 有效节点列表.size()]
			"逐层推进":# 选择序号最小的有效节点（按顺序第一个可探索节点）
				序号 = 有效节点列表.min()  # min()取最小序号
			"优先深入":# 步骤1：计算所有有效节点的行号（行号越大越深）
				var 节点行号映射: Dictionary = {}  # 键：节点序号，值：行号
				var 所有行号: Array[int] = []
				for 节点序号 in 有效节点列表:
					@warning_ignore("integer_division")
					var 行号 = int(节点序号 / 10)  # 计算行号（兼容godot语法）
					节点行号映射[节点序号] = 行号
					所有行号.append(行号)
				var 最深行号 = 所有行号.max()# 步骤2：找到最深的行号（最大行号）
				var 候选节点: Array[int] = []# 步骤3：候选节点 = 最深行的有效节点 + 上一行的有效节点
				for 节点序号 in 有效节点列表:
					var 行号 = 节点行号映射[节点序号]
					if 行号 == 最深行号 or 行号 == 最深行号 - 1:
						候选节点.append(节点序号)
				序号 = 候选节点[randi() % 候选节点.size()]# 步骤4：从候选节点中随机选一个
	sles:
		if 探索状态数组[序号]:
			print("没有可探索的有效节点")
			return
	if 图块事件[序号]==50:
		%动作进度条.执行动作中=false
		#事件逻辑
		return
	var 当前探索=更新单个图块(序号, 探索进度)
	if 当前探索==100:
		更新探索状态()
		var 列 = 序号 % 10  # 列索引（0-9）
		@warning_ignore("integer_division")
		var 行 = int(序号 / 10)  # 行索引（整数除法）
		if 行 > 0:# 上邻居（行-1，需确保行>0）
			var 上邻居序号 = (行 - 1) * 10 + 列
			更新单个图块(上邻居序号)  # 不填探索进度，使用默认值
		@warning_ignore("integer_division")
		if 行 < int(图块事件.size() / 10) - 1:
			var 下邻居序号 = (行 + 1) * 10 + 列
			更新单个图块(下邻居序号)  # 不填探索进度，使用默认值
		if 列 > 0:# 左邻居（列-1，需确保列>0）
			var 左邻居序号 = 行 * 10 + (列 - 1)
			更新单个图块(左邻居序号)  # 不填探索进度，使用默认值
		if 列 < 9:# 右邻居（列+1，需确保列<9）
			var 右邻居序号 = 行 * 10 + (列 + 1)
			更新单个图块(右邻居序号)  # 不填探索进度，使用默认值
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
