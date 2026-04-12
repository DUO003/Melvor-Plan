@tool
extends Node2D
class_name 冒险地图
@onready var 地图: 可保存瓦片地图 = $"地图"
@onready var 建筑: 可保存瓦片地图 = $"建筑"
@onready var 触发管理器: Node2D = %触发管理器
@onready var 实体: Node2D = %实体
@export var 地图名称:String=""
#@export var 测试:bool=false:
	#set(值):
		#if 值:
			#测试 = false
			#仿真测试()
@export var 地图信息:地图信息包=null
var 玩家:游历实体
var 玩家摄像机: Camera2D
@onready var 子弹管理器: Node2D = %子弹管理器
@onready var 掉落物管理器: Node2D = %掉落物管理器
@onready var 提示管理器: Control = $伤害跳字
func _ready() -> void:
	if not Engine.is_editor_hint():
		横版单例.子弹管理器=子弹管理器
		横版单例.掉落物管理器=掉落物管理器
		横版单例.关卡战线=0
#func _draw():
	#if Engine.is_editor_hint():
		#return
	#draw_rect(横版单例.传送点位置,Color(0.285, 0.285, 0.285, 1.0), true)
#func _physics_process(_间隔: float) -> void:
	#if Engine.is_editor_hint():
		#return
	#var 鼠标全局:Vector2 = 地图.get_global_mouse_position()
	#var 鼠标局部 = 地图.to_local(鼠标全局)
	#var 方块坐标:Vector2i = 地图.local_to_map(鼠标局部)
	#var 点击屏幕:bool=Input.is_action_just_pressed("点击屏幕")
	#if 点击屏幕:
		#if 方块坐标.y>=5:
			##print("鼠标全局位置",鼠标全局,"鼠标局部",鼠标局部)
			##print("点击位置",方块坐标,"方块ID",地图.get_cell_source_id(方块坐标))
			#横版单例.玩家导航.emit(地图.get_global_mouse_position().x)
		#else :
			#var 图块源:int=建筑.get_cell_source_id(方块坐标)
			#var 图块坐标:Vector2i=建筑.get_cell_atlas_coords(方块坐标)
			#var 方块名称:String=计划.表格.方块读取(图块源,图块坐标)
			#print(方块名称)
func 保存游历实体数据()->Dictionary[String,Dictionary]:
	# 1. 先判断实体节点是否存在，避免空引用
	if not 实体:
		print("错误：未找到'实体'根节点！")
		return {}
	# 2. 循环遍历根节点的所有子节点
	var 字典:Dictionary[String,Dictionary]={}
	var 所有子节点 = 实体.get_children()
	for 子节点 in 所有子节点:
		if 子节点 is 游历实体:
			var 实体数据: Dictionary = {
				"实体名称": 子节点.实体名称,
				"实体类型": 子节点.实体类型,
				"位置":子节点.position}
			var 节点唯一标识 = 子节点.name
			字典[节点唯一标识] = 实体数据
	# 打印结果，方便你验证数据（可删除）
	print("筛选后的游历实体数据：", 字典)
	# 后续你可自行处理这个字典（保存到文件/配置等）
	return 字典
var 实体场景字典:Dictionary[String,PackedScene] = {
	"基础":preload("res://界面/游历系统/实体/游历实体.tscn"),
	"玩家":preload("res://界面/游历系统/实体/实体_玩家.tscn"),
	"怪物":preload("res://界面/游历系统/实体/实体_怪物.tscn"),}
func 保存地图(保存:bool):
	if Engine.is_editor_hint():#只在编辑器工作
		if not 地图信息 or not 保存:
			地图信息 = 地图信息包.new()
		地图.保存地图()#先各自保存自身的图块数据
		建筑.保存地图()
		#初始化地图信息包
		for 节点 in 触发管理器.get_children():
			if 节点 is 梅刷怪点场景:
				节点.保存刷怪点()
				地图信息.刷怪点配置.append(节点.刷怪数据)
		# 3. 填充地图信息包的数据
		地图信息.地图名称 = 地图名称
		地图信息.缩放 = 地图.scale
		地图信息.地图_地图 = 地图.地图资源
		地图信息.起点_地图 = 地图.图案起点坐标
		地图信息.地图_建筑 = 建筑.地图资源
		地图信息.起点_建筑 = 建筑.图案起点坐标
		地图信息.实体 = 保存游历实体数据()
func 加载队友实体(传入的地图信息包: 地图信息包)->Dictionary:
	var 实体数据字典:Dictionary = 传入的地图信息包.实体 if 传入的地图信息包 else {}
	return 实体数据字典
	
# 核心加载方法：传入地图信息包，加载实体数据
func 加载地图(传入的地图信息包: 地图信息包):
	清除子节点(实体)
	清除子节点(子弹管理器)
	清除子节点(掉落物管理器)
	var 实体数据字典:Dictionary = 加载队友实体(传入的地图信息包)
	if  not 传入的地图信息包 or not 实体 or 实体数据字典.is_empty():# 安全校验
		if not 传入的地图信息包:print("错误：传入的地图信息包为空！")
		if not 实体:print("错误：无法获取实体根节点")
		if 实体数据字典.is_empty():print("提示：地图信息包中无实体数据，无需生成实体")
		return
	var 首个玩家:bool=true
	# 遍历实体字典，逐个生成新实体
	for 节点唯一标识:String in 实体数据字典:
		var 实体数据:Dictionary=实体数据字典[节点唯一标识]
		if not 实体数据.has_all(["实体名称","实体类型","位置"]):
			print("警告：实体数据缺失必要字段，跳过生成：", 节点唯一标识)
			continue
		var 实体类型:String=实体数据["实体类型"]#配置实体参数
		print(实体类型,节点唯一标识)
		var 实体场景=实体场景字典.get(实体类型,实体场景字典.基础).instantiate()
		var 新实体:游历实体 = 实体场景.duplicate()
		新实体.实体名称 = 实体数据["实体名称"]
		if 新实体.实体名称=="玩家" and not Engine.is_editor_hint():
			新实体.实体名称=计划.梅存档.get("挂机",{}).get("用户信息",{}).get("用户名","错误")
		新实体.实体类型 = 实体类型
		新实体.position = 实体数据["位置"]  # 设置位置
		if 新实体.实体类型=="玩家" and 首个玩家:
			首个玩家=false
			加载控制玩家(新实体)
		if Engine.is_editor_hint():
			新实体.name=节点唯一标识
		实体.add_child(新实体)
		新实体.注册实体()
		if Engine.is_editor_hint():
			新实体.owner=self
	if  玩家摄像机 and Engine.is_editor_hint():#解决摄像机报错
		玩家摄像机.owner=self
	地图名称 = 传入的地图信息包.地图名称
	地图.clear()
	地图.set_pattern(传入的地图信息包.起点_地图, 传入的地图信息包.地图_地图)
	地图.scale=传入的地图信息包.缩放
	更新限制(传入的地图信息包.起点_地图, 传入的地图信息包.地图_地图,地图)
	建筑.clear()
	建筑.set_pattern(传入的地图信息包.起点_建筑, 传入的地图信息包.地图_建筑)
	建筑.scale=传入的地图信息包.缩放
	计划.清除子节点(触发管理器)
	生成刷新点(传入的地图信息包)
	if not Engine.is_editor_hint():
		更新传送门()
func 加载控制玩家(新实体:游历实体_玩家):
	var 摄像机: Camera2D=创建玩家摄像机()
	if 摄像机.get_parent():
		摄像机.get_parent().remove_child(摄像机)
	新实体.add_child(摄像机)
	新实体.摄像机=摄像机
	if not Engine.is_editor_hint():
		横版单例.控制队友=新实体
##刷怪点场景,拥有编辑刷怪点或检查玩家进入
var 刷怪点场景 = preload("res://界面/游历系统/冒险根场景/刷怪点.tscn").instantiate()
# ========== 怪物生成核心函数 ==========
func 生成刷新点(信息包: 地图信息包):
	# 安全校验：根节点/刷怪数据为空则返回
	if not 触发管理器 or not 实体:
		print("错误：无法获取管理器根节点，跳过刷怪点生成")
		return
	var 刷怪点数组:Array[刷怪点信息包]=信息包.刷怪点配置
	var 随机数生成器: RandomNumberGenerator = RandomNumberGenerator.new()
	if 信息包.刷怪种子 == -1:
		随机数生成器.randomize() # 无指定种子则随机初始化
		print("提示：使用随机种子生成怪物")
	else:
		随机数生成器.seed = 信息包.刷怪种子
	for 刷怪数据:刷怪点信息包 in 刷怪点数组:
		var 刷怪点:梅刷怪点场景=刷怪点场景.duplicate()
		刷怪点.刷怪数据=刷怪数据
		刷怪点.实体=实体
		触发管理器.add_child(刷怪点)
		刷怪点.加载数据()
		if Engine.is_editor_hint():
			刷怪点.owner=self
	#var 图块大小: Vector2 = 获取图块大小(建筑)
	#if 图块大小.x <= 0 or 图块大小.y <= 0:
		#print("警告：获取图块大小失败，使用默认值64")
		#图块大小 = Vector2(64, 64) # 兜底默认值
	#var 刷新点坐标数组:Array[Vector2] = 搜索刷怪点("")
	## 遍历所有刷怪点生成怪物
	#for 刷新点标识:String in 怪物数据字典:
		#var 怪物数据:Dictionary = 怪物数据字典[刷新点标识]
		## 校验怪物必备字段
		#if not 怪物数据.has_all(["怪物","强度","数量"]):
			#print("警告：刷怪点[",刷新点标识,"]数据缺失必要字段，跳过生成")
			#continue
		## 1. 获取并校验刷新点坐标数组
		#var 刷新点坐标数组:Array[Vector2] = 搜索刷怪点(刷新点标识)
		#if 刷新点坐标数组.is_empty():
			#print("错误：刷怪点[",刷新点标识,"]未找到有效刷新坐标，跳过生成")
			#continue
		## 2. 随机生成本次刷怪数量（Vector2i范围取整）
		#var 数量范围:Vector2i = 怪物数据["数量"]
		## 3.2 随机生成怪物强度（Vector2范围取浮点）
		#var 强度范围:Vector2 = 怪物数据["强度"]
		#var 生成数量:int = 随机数生成器.randi_range(数量范围.x, 数量范围.y)
		#if 生成数量 <= 0:
			#print("提示：刷怪点[",刷新点标识,"]生成数量为0，跳过生成")
			#continue
		## 3. 循环生成指定数量的怪物
		#for 生成索引 in 生成数量:
			## 3.1 随机获取刷新中心点 + X轴偏移(-64~64)
			#var 偏移系数: int = 随机数生成器.randi_range(-5, 5)
			#var x偏移: float = 偏移系数 * 0.2 * 图块大小.x
			#var 中心点:Vector2 = 刷新点坐标数组[随机数生成器.randi() % 刷新点坐标数组.size()]
			#var 最终坐标:Vector2 = Vector2(中心点.x + x偏移, 中心点.y)
			#var 随机强度:float = 随机数生成器.randf_range(强度范围.x, 强度范围.y)
			## 3.3 实例化怪物节点
			#if not 实体场景字典.has("怪物"):
				#print("错误：实体场景字典中未配置怪物场景，跳过生成")
				#break
			#var 新怪物: 游历实体_怪物 = 实体场景字典.怪物.instantiate().duplicate()
			##设置怪物属性
			#新怪物.实体名称 = 怪物数据["怪物"]
			#新怪物.实体类型 = "怪物"
			#新怪物.强度 = 随机强度 # 赋值怪物强度属性
			#新怪物.position = 最终坐标 # 设置生成坐标
			#实体.add_child(新怪物)
func 单个生成怪物(_怪物: 游历实体_怪物):
	pass
	
func 搜索刷怪点(刷怪点名:String)->Array[Vector2]:
	var 方块字典:Dictionary=计划.表格.方块字典
	if not 方块字典.has(刷怪点名) or not 方块字典.传送门.has_all(["瓦片集","瓦片列","瓦片排"]):
		push_warning("错误,找不到<%s>刷怪点数据"%刷怪点名)
		return []
	var 目标源:int=方块字典[刷怪点名].瓦片集
	var 目标坐标:Vector2i=Vector2i(方块字典[刷怪点名].瓦片列,方块字典[刷怪点名].瓦片排)
	var 搜索结果:Array[Vector2i]=横版单例.搜索图块(建筑,目标源,目标坐标)
	var 坐标数组:Array[Vector2]=[]
	if 搜索结果.size()>=1:
		var 图块大小: Vector2i = 获取图块大小(建筑)
		for 坐标:Vector2i in 搜索结果:
			坐标数组.append(Vector2(坐标.x * 图块大小.x,坐标.y * 图块大小.y))
	return 坐标数组
func 更新传送门():
	var 方块字典:Dictionary=计划.表格.方块字典
	if not 方块字典.has("传送门") or not 方块字典.传送门.has_all(["瓦片集","瓦片列","瓦片排"]):
		push_warning("错误,找不到传送门数据")
		return
	var 目标源:int=方块字典.传送门.瓦片集
	var 目标坐标:Vector2i=Vector2i(方块字典.传送门.瓦片列,方块字典.传送门.瓦片排)
	var 搜索结果:Array[Vector2i]=横版单例.搜索图块(建筑,目标源,目标坐标)
	if 搜索结果.is_empty():
		横版单例.传送点有效=false
	else :
		横版单例.传送点有效=true
		var 图块大小: Vector2 = 获取图块大小(建筑)
		for 传送门坐标:Vector2i in 搜索结果:
			var 传送门原点:Vector2 = Vector2((传送门坐标.x+0.505) * 图块大小.x,(传送门坐标.y-0.5) * 图块大小.y)
			var 传送门尺寸:Vector2 = Vector2(120, 200)*建筑.scale
			var 区域:Area2D=Area2D.new()
			var 传送碰撞箱:CollisionShape2D=CollisionShape2D.new()
			var 碰撞体:=RectangleShape2D.new()
			区域.collision_layer=0
			区域.collision_mask=0
			区域.set_collision_mask_value(3, true)  # 遮罩
			实体.add_child(区域)
			区域.add_child(传送碰撞箱)
			区域.position=传送门原点
			碰撞体.size=传送门尺寸
			传送碰撞箱.shape=碰撞体
			区域.body_entered.connect(接收区域进出信号.bind(true))
			区域.body_exited.connect(接收区域进出信号.bind(false))
	print("[调试]传送门源%d(%d,%d)搜索结果:"%[目标源,目标坐标.x,目标坐标.y],搜索结果)
func 接收区域进出信号(碰撞实体:Node2D,进入:bool):
	if 碰撞实体 and 碰撞实体 is 游历实体_玩家:
		碰撞实体.位于传送门内=进入
		if 横版单例.控制队友 and 碰撞实体==横版单例.控制队友:
			横版单例.更新传送带状态(进入)
func 获取图块大小(节点:TileMapLayer)->Vector2:
	var 地图集: TileSet = 节点.tile_set
	if not 地图集:
		push_warning("TileMapLayer未关联TileSet")
		地图集=TileSet.new()
		地图集.tile_size=Vector2i(64,64)
	var 图块大小: Vector2 = Vector2(地图集.tile_size)*建筑.scale
	return 图块大小
func 更新限制(起点: Vector2i,地图图块: TileMapPattern,节点:TileMapLayer):
	if not 玩家摄像机:
		玩家摄像机 = Camera2D.new()
	# 1. 获取核心尺寸信息
	var 地图集: TileSet = 节点.tile_set
	if not 地图集:
		push_warning("TileMapLayer未关联TileSet")
		地图集=TileSet.new()
		地图集.tile_size=Vector2i(64,64)
	var 图块大小: Vector2i = 地图集.tile_size
	var 图块图案尺寸: Vector2i = 地图图块.get_size() # 加载的图块图案本身的尺寸（行列数）
	# 2. 计算地图实际像素边界（基于加载起点）
	# 左侧边界：起点的x坐标 × 单个图块宽度（避免负数，取最大值0）
	var 地图左边界像素: int = max(起点.x * 图块大小.x, 0)
	# 右侧边界：(起点x + 图块图案列数) × 单个图块宽度
	var 地图右边界像素: int = (起点.x + 图块图案尺寸.x) * 图块大小.x
	# 底部边界：(起点y + 图块图案行数) × 单个图块高度
	var 地图下边界像素: int = int((起点.y + 图块图案尺寸.y-2) * 图块大小.y)+64
	var 缩放:float=节点.scale.x
	# 3. 设置摄像机限制（取消顶部限制，只限制左、右、下）
	玩家摄像机.limit_left = int(地图左边界像素*缩放)    # 左侧基于加载起点计算
	玩家摄像机.limit_right = int(地图右边界像素*缩放)   # 右侧基于图块图案尺寸计算
	玩家摄像机.limit_bottom = int(地图下边界像素*缩放)  # 底部基于图块图案尺寸计算
		
func 清除子节点(节点容器:Node,保留节点=null):
	for 节点名 in 节点容器.get_children():
		if 保留节点==null or 节点名!=保留节点:
			节点容器.remove_child(节点名)
			节点名.queue_free()
func 创建玩家摄像机() -> Camera2D:
	if not 玩家摄像机:
		玩家摄像机 = Camera2D.new()
		#配置摄像机核心属性
		玩家摄像机.enabled = true          # 启用摄像机
		玩家摄像机.limit_enabled = true    # 启用位置限制
		玩家摄像机.limit_smoothed = true  # 启用限制平滑
		# 给摄像机命名，方便你后续查找/操作
		# 3.5 编辑器模式下的节点配置
		if Engine.is_editor_hint():
			玩家摄像机.name = "摄像机"
	return 玩家摄像机
func 仿真测试() -> void:
	# 初始化变量
	var 策略:int=1
	var 总抽取次数 = 1000000
	var 初始奖池 = 820
	var 初始抽取次数 = 5
	var 初始平均值:float = float(初始奖池) / 初始抽取次数
	var 奖池: int = 初始奖池
	var 剩余抽取次数: int = 初始抽取次数
	var 已抽取次数: int = 0
	var 抽取累计: int = 0
	# 执行1000次抽取循环
	for 当前抽取序号 in 总抽取次数:
		# 步骤2：计算当前轮平均值（若剩余次数为0则先重置）
		if 剩余抽取次数 <= 0:
			奖池 = 初始奖池
			剩余抽取次数= 初始抽取次数
		var 随机抽取金额: int =0
		match 策略:
			1:#微信红包算法
				var 平均金额 = float(奖池) / 剩余抽取次数
				var 最大金额 = int(平均金额 * 2)
				随机抽取金额=randi_range(1, min(最大金额,奖池 - 剩余抽取次数 + 1))
			_:#纯随机
				随机抽取金额=randi_range(1, 奖池 - 剩余抽取次数 + 1)
		# 步骤4：更新状态变量
		已抽取次数 += 1
		抽取累计 += 随机抽取金额
		剩余抽取次数 -= 1
		奖池 -= 随机抽取金额
		# 步骤5：检查重置条件（平均值小于初始平均值 或 剩余次数为0）
		var 当前平均值: float = float(奖池) / 剩余抽取次数
		if 当前平均值 <= 初始平均值:
			奖池 = 初始奖池
			剩余抽取次数= 初始抽取次数
	# 打印最终结果
	print("\n===== 仿真测试结束 =====")
	print("总抽取次数: %d 次" % 已抽取次数)
	print("抽取累计金额: %d 元" % 抽取累计)
	print("平均每次抽取金额: %.4f 元" % (float(抽取累计)/总抽取次数))
	print("初始理论期望值: %.2f 元" % 初始平均值)
