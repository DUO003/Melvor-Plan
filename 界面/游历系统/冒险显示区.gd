@tool
extends SubViewportContainer
class_name 冒险地图
@onready var 地图: TileMapLayer = $冒险窗口/地图
@onready var 建筑: TileMapLayer = $冒险窗口/建筑
@onready var 实体: Node2D = %实体
@export var 地图名称:String=""
@export var 启用保存:bool=false:
	set(值):
		if 值:
			启用保存 = false
			保存地图()
@export var 启用读取:bool=false:
	set(值):
		if 值:
			启用读取 = false
			if 地图信息:加载地图(地图信息)
@export var 地图信息:地图信息包=null
var 玩家:游历实体
var 玩家摄像机: Camera2D
func 检查玩家移动():
	if 玩家:
		玩家.启用自动前进=true
		玩家.自动前进目标=get_global_mouse_position().x
func 保存地图():
	if Engine.is_editor_hint():#只在编辑器工作
		地图.保存地图()#先各自保存自身的图块数据
		建筑.保存地图()
		#初始化地图信息包
		地图信息 = 地图信息包.new()
		# 3. 填充地图信息包的数据
		地图信息.地图名称 = 地图名称
		地图信息.地图_地图 = 地图.地图资源
		地图信息.起点_地图 = 地图.图案起点坐标
		地图信息.地图_建筑 = 建筑.地图资源
		地图信息.起点_建筑 = 建筑.图案起点坐标
		地图信息.实体 = 保存游历实体数据()
func 保存游历实体数据()->Dictionary:
	# 1. 先判断实体节点是否存在，避免空引用
	if not 实体:
		print("错误：未找到'实体'根节点！")
		return {}
	# 2. 循环遍历根节点的所有子节点
	var 字典:Dictionary={}
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
var 实体场景字典:Dictionary[String,游历实体] = {
	"基础":preload("res://界面/游历系统/游历实体.tscn").instantiate(),
	"玩家":preload("res://界面/游历系统/实体_玩家.tscn").instantiate(),}
# 核心加载方法：传入地图信息包，加载实体数据
func 加载地图(传入的地图信息包: 地图信息包):
	清除子节点(实体)
	var 实体数据字典:Dictionary = 传入的地图信息包.实体 if 传入的地图信息包 else {}
	if  not 传入的地图信息包 or not 实体 or 实体数据字典.is_empty():# 安全校验
		if not 传入的地图信息包:print("错误：传入的地图信息包为空！")
		if not 实体:print("错误：无法获取实体根节点")
		if 实体数据字典.is_empty():print("提示：地图信息包中无实体数据，无需生成实体")
		return
	# 遍历实体字典，逐个生成新实体
	for 节点唯一标识:String in 实体数据字典:
		var 实体数据:Dictionary=实体数据字典[节点唯一标识]
		if not 实体数据.has_all(["实体名称","实体类型","位置"]):
			print("警告：实体数据缺失必要字段，跳过生成：", 节点唯一标识)
			continue
		var 实体类型:String=实体数据["实体类型"]#配置实体参数
		var 新实体:游历实体 = 实体场景字典.get(实体类型,"基础").duplicate()
		新实体.实体名称 = 实体数据["实体名称"]
		新实体.实体类型 = 实体类型
		新实体.position = 实体数据["位置"]  # 设置位置
		if 新实体.实体类型=="玩家":
			新实体.add_child(创建玩家摄像机())
		if Engine.is_editor_hint():
			新实体.name=节点唯一标识
		实体.add_child(新实体)
		if  Engine.is_editor_hint():
			新实体.owner=self
	if  玩家摄像机 and Engine.is_editor_hint():#解决摄像机报错
		玩家摄像机.owner=self
	地图名称 = 地图信息.地图名称
	加载图块(地图信息.地图_地图,地图信息.起点_地图,地图,true)
	加载图块(地图信息.地图_建筑,地图信息.起点_建筑,建筑)
func 加载图块(地图图块: TileMapPattern,起点: Vector2i,节点:TileMapLayer,限制:bool=false):
	节点.set_pattern(起点, 地图图块)
	if 限制:
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
		var 半格高度: int = int(图块大小.y / 2.0)  # 计算半格的像素值
		# 2. 计算地图实际像素边界（基于加载起点）
		# 左侧边界：起点的x坐标 × 单个图块宽度（避免负数，取最大值0）
		var 地图左边界像素: int = max(起点.x * 图块大小.x, 0)
		# 右侧边界：(起点x + 图块图案列数) × 单个图块宽度
		var 地图右边界像素: int = (起点.x + 图块图案尺寸.x) * 图块大小.x
		# 底部边界：(起点y + 图块图案行数) × 单个图块高度
		var 地图下边界像素: int = (起点.y + 图块图案尺寸.y) * 图块大小.y - 半格高度
		
		# 3. 设置摄像机限制（取消顶部限制，只限制左、右、下）
		玩家摄像机.limit_left = 地图左边界像素    # 左侧基于加载起点计算
		玩家摄像机.limit_right = 地图右边界像素   # 右侧基于图块图案尺寸计算
		玩家摄像机.limit_bottom = 地图下边界像素  # 底部基于图块图案尺寸计算
		
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
	玩家摄像机.name = "摄像机"
	return 玩家摄像机
