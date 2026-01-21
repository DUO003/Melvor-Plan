@tool  # 启用编辑器内预览
extends TextureRect
class_name 梅噪声地图

# ==================== 检查器可配置参数 ====================
# 地图基础配置
## 地图宽度（格子数）
@export var 地图宽度: int = 320:
	set(值):
		地图宽度 = 值
		if Engine.is_editor_hint():
			重新生成地图()
# 地图高度（格子数）
@export var 地图高度: int = 180 :
	set(值):
		地图高度 = 值
		if Engine.is_editor_hint():
			重新生成地图()
# 噪声缩放（越小地图越平滑）
@export var 噪声缩放: float = 1 :
	set(值):
		噪声缩放 = 值
		if Engine.is_editor_hint():
			重新生成地图()
# 新增：噪声配置字典（键=噪声配置资源，值=权重）
@export var 噪声配置字典: Dictionary[梅噪声, float]:
	set(值):
		噪声配置字典=值
		for 噪声资源包:梅噪声 in 噪声配置字典:
			if not 噪声资源包.内部资源更新.is_connected(重新生成地图):
				噪声资源包.内部资源更新.connect(重新生成地图)
# 新增：噪声采样偏移量（控制起始点）
@export var 噪声偏移X: float = 0.0:
	set(值):
		噪声偏移X = 值
		if Engine.is_editor_hint():
			重新生成地图()

@export var 噪声偏移Y: float = 0.0:
	set(值):
		噪声偏移Y = 值
		if Engine.is_editor_hint():
			重新生成地图()

# 颜色渐变配置（键：颜色，值：权重；会按权重比例分配0~1的噪声区间）
@export var 颜色渐变字典: Dictionary[Color,float] = {
	Color(0, 0.2, 0.8): 1.5,
	Color(0.2, 0.8, 0.2): 1.0,
	Color(0.6, 0.5, 0.3): 1.0,
	Color(0.9, 0.9, 0.9): 0.5}:
	set(值):
		#print("更新颜色",值)
		颜色渐变字典 = 值.duplicate(true)
		if Engine.is_editor_hint():
			重新生成地图()

var 缓存数组
@export var 颜色渐变字典数组:Array:
	get:
		缓存数组=颜色渐变字典.keys()
		return 缓存数组
	set(值):
		if 缓存数组 == 值:
			#print("值为空")
			return
		var 原数值缓存 = 颜色渐变字典
		var 新排序字典: Dictionary[Color,float] = {}
		for 单个颜色 in 值:
			新排序字典[单个颜色] = 原数值缓存.get(单个颜色, 1.0)
		#print("执行排序",新排序字典)
		颜色渐变字典 = 新排序字典

# ==================== 内部变量 ====================
var 噪声实例字典: Dictionary[FastNoiseLite, float] = {}  # 噪声实例: 权重
var 总噪声权重: float = 0.0  # 所有噪声权重总和
var 地图数据: Array[Array] = []  # 存储每个格子的归一化噪声值（0~1）
var 颜色区间列表: Array = []  # 预处理后的颜色区间（[起始值, 结束值, 颜色]）

func _ready():
	重新生成地图()

func 重新生成地图():
	# 初始化噪声实例（从配置字典创建）
	初始化噪声()
	# 预处理颜色渐变字典，生成区间映射
	预处理颜色区间()
	# 生成噪声地图数据（归一化到0~1）
	生成噪声地图数据()
	# 绘制地图到TextureRect
	绘制地图()
func 资源信号(资源:Resource,方法:Callable):
	if Engine.is_editor_hint():
		if 资源 != null and 资源.changed.is_connected(方法):
			资源.changed.disconnect(方法)
# 重构：初始化多个噪声实例（从配置字典读取）
func 初始化噪声():
	噪声实例字典.clear()
	总噪声权重 = 0.0

	# 遍历噪声配置字典，创建实例并计算总权重
	for 噪声配置: 梅噪声 in 噪声配置字典:
		if not 噪声配置:  # 过滤空引用
			continue
		var 权重 = float(噪声配置字典[噪声配置])
		if 权重 <= 0:  # 过滤无效权重
			continue
		# 从资源创建噪声实例
		var 噪声实例:FastNoiseLite = 噪声配置.创建噪声实例()
		噪声实例字典[噪声实例] = 权重
		总噪声权重 += 权重

# 预处理颜色渐变字典：计算总权重，生成0~1的颜色区间（保留原有逻辑）
func 预处理颜色区间():
	颜色区间列表.clear()
	
	# 1. 校验字典格式
	if 颜色渐变字典.is_empty():
		printerr("颜色渐变字典不能为空！使用默认颜色配置")
		颜色渐变字典 = {
			Color(0, 0.2, 0.8): 1.5,
			Color(0.2, 0.8, 0.2): 1.0,
			Color(0.6, 0.5, 0.3): 1.0,
			Color(0.9, 0.9, 0.9): 0.5
		}
	
	# 2. 计算总权重
	var 总权重: float = 0.0
	for 权重 in 颜色渐变字典.values():
		if typeof(权重) != TYPE_FLOAT and typeof(权重) != TYPE_INT:
			printerr("颜色权重必须是数字，忽略无效值")
			continue
		总权重 += float(权重)
	
	if 总权重 <= 0:
		printerr("颜色总权重不能小于等于0，使用默认值4.0")
		总权重 = 4.0
	
	# 3. 生成颜色区间（起始值, 结束值, 颜色）
	var 当前起始值: float = 0.0
	for 颜色 in 颜色渐变字典:
		if typeof(颜色) != TYPE_COLOR:
			printerr("颜色渐变字典的键必须是Color类型，忽略无效键")
			continue
		var 权重 = float(颜色渐变字典[颜色])
		var 区间长度 = 权重 / 总权重
		var 当前结束值 = 当前起始值 + 区间长度
		颜色区间列表.append([当前起始值, 当前结束值, 颜色])
		当前起始值 = 当前结束值

# 重构：生成叠加后的噪声地图数据
func 生成噪声地图数据():
	地图数据.clear()
	# 若噪声配置为空，直接生成全0数据（对应纯黑）
	if 噪声实例字典.is_empty() or 总噪声权重 <= 0:
		for y in range(地图高度):
			var 行数据: Array = []
			for x in range(地图宽度):
				行数据.append(0.0)  # 0对应纯黑
			地图数据.append(行数据)
		return
	# 遍历每个格子，叠加多个噪声值
	for y in range(地图高度):
		var 行数据: Array = []
		for x in range(地图宽度):
			var 叠加噪声值 = 0.0
			# 叠加每个噪声的贡献（噪声值 × 权重）
			for 噪声实例: FastNoiseLite in 噪声实例字典:
				var 权重 = 噪声实例字典[噪声实例]
				# 加入偏移量计算采样坐标
				var 采样X = (x + 噪声偏移X) * 噪声缩放*0.01
				var 采样Y = (y + 噪声偏移Y) * 噪声缩放*0.01
				var 原始噪声值 = 噪声实例.get_noise_2d(采样X, 采样Y)
				叠加噪声值 += 原始噪声值 * 权重
			# 归一化：先除以总权重（还原到-1~1），再映射到0~1
			var 归一化前 = 叠加噪声值 / 总噪声权重
			var 归一化噪声值 = (归一化前 + 1.0) / 2.0
			# 确保值在0~1范围内（防止噪声值超出理论范围）
			归一化噪声值 = clamp(归一化噪声值, 0.0, 1.0)
			行数据.append(归一化噪声值)
		地图数据.append(行数据)
func 绘制地图():
	var 图像宽度 = 地图宽度
	var 图像高度 = 地图高度
	var 图像 = Image.create_empty(图像宽度, 图像高度, false, Image.FORMAT_RGBA8)
	# 2. 遍历每个格子，填充对应颜色
	for y in range(地图高度):
		for x in range(地图宽度):
			var 归一化噪声值 = 地图数据[y][x]
			var 目标颜色 = Color(0.0, 0.0, 0.0)
			# 匹配颜色区间（非空噪声时生效）
			if 总噪声权重 > 0:
				for 区间 in 颜色区间列表:
					var 起始值 = 区间[0]
					var 结束值 = 区间[1]
					var 区间颜色 = 区间[2]
					if 归一化噪声值 >= 起始值 and 归一化噪声值 < 结束值:
						目标颜色 = 区间颜色
						break
			图像.set_pixel(x, y, 目标颜色)
	# 3. 更新纹理并显示
	var 图像纹理 = ImageTexture.create_from_image(图像)
	self.texture = 图像纹理
# 获取指定坐标点的原始噪声值（0～1范围，不带偏移）
func 获取指定坐标噪声(x: int, y: int) -> float:
	# 检查噪声配置是否有效
	if 噪声实例字典.is_empty() or 总噪声权重 <= 0:
		return 0.0
	var 噪声 = 0.0
	# 遍历所有噪声实例（不使用偏移，仅用坐标×缩放）
	for 噪声实例 in 噪声实例字典:
		var 权重 = 噪声实例字典[噪声实例]
		# 关键：直接使用坐标×缩放（无偏移！）
		var 采样坐标_x = x * 噪声缩放*0.01
		var 采样坐标_y = y * 噪声缩放*0.01
		var 噪声值 = 噪声实例.get_noise_2d(采样坐标_x, 采样坐标_y)
		噪声 += 噪声值 * 权重
	# 归一化到0～1（与地图生成逻辑完全一致）
	var 归一化值 = (噪声 / 总噪声权重 + 1.0) / 2.0
	return clamp(归一化值, 0.0, 1.0)
