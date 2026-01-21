@tool
extends TextureRect

# 导出可配置参数
@export var 星星密度: float = 0.01:
	set(值):
		星星密度=值
		生成纹理()
@export var 星星大小: float = 1.5:
	set(值):
		星星大小=值
		生成纹理()
@export var 背景色: Color = Color(0,0,0,1):
	set(值):
		背景色=值
		生成纹理()
@export var 噪声资源:梅噪声:
	set(值):
		噪声资源=值
		if not 噪声资源.内部资源更新.is_connected(生成纹理):
			噪声资源.内部资源更新.connect(生成纹理)
# 内部噪声相关变量
var 噪声: FastNoiseLite
var 星空纹理: ImageTexture
var 背景尺寸: Vector2i = Vector2i(1024, 1024)  # 生成的纹理像素尺寸
func _ready():
	生成纹理()
func 生成纹理():
	初始化噪声参数()
	生成星空纹理()
	texture = 星空纹理

func 初始化噪声参数():
	if not 噪声资源:
		噪声资源=梅噪声.new()
	噪声=噪声资源.创建噪声实例()

func 生成星空纹理():
	# 1. 创建空图片对象，设置尺寸和格式（RGBA8，支持透明）
	背景尺寸=size
	var 星空图片: Image = Image.create(背景尺寸.x, 背景尺寸.y, false, Image.FORMAT_RGBA8)
	# 2. 填充背景为纯黑（星空背景）
	星空图片.fill(背景色)
	
	# 3. 遍历像素生成星星（优化：按密度跳过部分像素，提升性能）
	var 步长: int = max(1, int(1 / sqrt(星星密度)))  # 根据密度计算遍历步长
	for y in range(0, 背景尺寸.y, 步长):
		for x in range(0, 背景尺寸.x, 步长):
			# 获取当前位置的噪声值（范围-1~1）
			var 噪声值: float = 噪声.get_noise_2d(x, y)
			# 将噪声值映射到0~1范围
			var 归一化噪声值: float = (噪声值 + 1) / 2.0
			
			# 4. 根据密度判断是否生成星星（噪声值越高，生成星星概率越大）
			if 归一化噪声值 > (1.0 - 星星密度 * 10):
				# 5. 绘制星星（支持多像素大小）
				绘制星星(星空图片, Vector2i(x, y), 星星大小)
	
	# 6. 将Image转换为ImageTexture
	星空纹理 = ImageTexture.create_from_image(星空图片)

func 绘制星星(图片: Image, 中心坐标: Vector2i, 大小: float):
	# 计算星星的绘制范围（取整避免浮点误差）
	var 半尺寸: int = int(大小 / 2)
	var 起始x: int = max(0, 中心坐标.x - 半尺寸)
	var 结束x: int = min(图片.get_width() - 1, 中心坐标.x + 半尺寸)
	var 起始y: int = max(0, 中心坐标.y - 半尺寸)
	var 结束y: int = min(图片.get_height() - 1, 中心坐标.y + 半尺寸)
	
	# 遍历绘制星星的像素（模拟星星的亮度渐变，中心亮边缘暗）
	for y in range(起始y, 结束y + 1):
		for x in range(起始x, 结束x + 1):
			# 计算当前像素到中心的距离，用于亮度渐变
			var 距离: float = Vector2i(x, y).distance_to(中心坐标) / 半尺寸
			if 距离 > 1.0:
				continue  # 超出星星范围跳过
			
			# 星星颜色（白色，透明度随距离降低，模拟真实星星的光晕）
			var 亮度: float = 1.0 - (距离 * 0.5)
			var 星星颜色: Color = Color(1, 1, 1, 亮度)
			# 设置像素颜色
			图片.set_pixel(x, y, 星星颜色)

# 可选：参数修改后实时更新星空
func _on_parameters_changed():
	生成星空纹理()
	texture = 星空纹理
