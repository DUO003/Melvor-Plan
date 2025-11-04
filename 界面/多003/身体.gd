#@tool
extends Control

# 检查器变量
@export var 图片偏移: Vector2 = Vector2.ZERO:
	set(值):
		图片偏移 = 值
		queue_redraw()
@export var 图片缩放: Vector2 = Vector2.ONE:
	set(值):
		图片缩放 = 值
		queue_redraw()
@export var 边框厚度=10:
	set(值):
		边框厚度 = 值
		queue_redraw()

var 图片纹理: Texture2D = preload("res://素材/豆包AI素材/绘制简笔画小人.png")
var 矩形数组: Array[Rect2] = []
var 蒙版图像
var 处理后的图片
var 测试
var 图像对象
func _ready():
	处理图像()
	queue_redraw()
func 获取矩形数组():
	矩形数组 = []
	var 偏移值 = %"颜色框组".position
	
	for 子节点 in %"颜色框组".get_children():
		if 子节点 is Control:
			var 位置 = 子节点.position + 偏移值
			var 大小 = 子节点.size
			var 矩形 = Rect2(位置.x, 位置.y, 大小.x, 大小.y)
			矩形数组.append(矩形)

func 生成蒙版图像(原图尺寸: Vector2) -> Image:
	# 创建与原始图像相同尺寸的蒙版图像
	@warning_ignore("shadowed_variable", "narrowing_conversion")
	var 蒙版图像 = Image.create_empty(原图尺寸.x, 原图尺寸.y, false, Image.FORMAT_RGBA8)
	# 初始化蒙版为全透明（黑色）
	蒙版图像.fill(Color(0, 0, 0, 0))
	# 将矩形区域绘制为不透明（白色）
	var 蒙版数组=矩形数组.duplicate()
	#蒙版数组.reverse()
	for 矩形 in 蒙版数组:
		# 将矩形转换为图像坐标系（不受偏移和缩放影响）
		var 图像矩形 = 矩形到图像坐标系(矩形, 原图尺寸,false)
		if 图像矩形 != Rect2i(0, 0, 0, 0):# 只处理在图像范围内的矩形
			蒙版图像.fill_rect(图像矩形, Color(0, 0, 0, 0))# 填充矩形区域为（黑色）
		var 图像矩形2 = 矩形到图像坐标系(矩形, 原图尺寸)
		if 图像矩形2 != Rect2i(0, 0, 0, 0):# 只处理在图像范围内的矩形
			蒙版图像.fill_rect(图像矩形2, Color(1, 1, 1, 1))# 填充矩形区域为白色（alpha=1）
	
	return 蒙版图像

func 矩形到图像坐标系(场景矩形: Rect2, 图像尺寸: Vector2,边框=true) -> Rect2i:
	var 图像显示区域 = 计算图像显示区域(图像尺寸,边框厚度 if 边框 else 0)# 计算图像在场景中的实际显示区域
	var 交集矩形 = 场景矩形.intersection(图像显示区域)# 计算场景矩形与图像显示区域的交集
	if 交集矩形.size.x <= 0 or 交集矩形.size.y <= 0:# 如果没有交集，返回null
		return Rect2i(0, 0, 0, 0)  # 返回空矩形
	var 相对位置 = 交集矩形.position - 图像显示区域.position# 将交集矩形从场景坐标系转换到图像坐标系
	var 图像内位置 = Vector2i(
		int(相对位置.x / 图片缩放.x),
		int(相对位置.y / 图片缩放.y)
	)
	var 图像内尺寸 = Vector2i(
		int(交集矩形.size.x / 图片缩放.x),
		int(交集矩形.size.y / 图片缩放.y)
	)
	# 确保不超出图像边界
	图像内位置.x = clamp(图像内位置.x, 0, 图像尺寸.x)
	图像内位置.y = clamp(图像内位置.y, 0, 图像尺寸.y)
	图像内尺寸.x = min(图像内尺寸.x, 图像尺寸.x - 图像内位置.x)
	图像内尺寸.y = min(图像内尺寸.y, 图像尺寸.y - 图像内位置.y)
	return Rect2i(图像内位置, 图像内尺寸)

func 计算图像显示区域(图像尺寸: Vector2,边框=0) -> Rect2:
	#计算应用了偏移和缩放后，图像在场景中的实际显示区域
	var 缩放后尺寸 = Vector2(图像尺寸.x-边框,图像尺寸.y-边框) * 图片缩放
	var 显示位置 = Vector2(图片偏移.x-边框,图片偏移.y+边框)
	return Rect2(显示位置, 缩放后尺寸)

func 处理图像():
	图像对象 = 图片纹理.get_image()
	if 图像对象 == null:
		print("图像对象 == null")
		return
	# 获取矩形数组
	获取矩形数组()
	# 生成蒙版图像（与原始图像相同尺寸）
	蒙版图像 = 生成蒙版图像(图像对象.get_size())
	# 创建目标图像（与原始图像相同格式和尺寸）
	var 目标图像 = Image.create_empty(
		图像对象.get_width(), 
		图像对象.get_height(), 
		false, 
		图像对象.get_format()
	)
	目标图像.blend_rect_mask(
		图像对象,      # 源图像
		蒙版图像,      # 蒙版图像（决定哪些像素被复制）
		Rect2i(0, 0, 图像对象.get_width(), 图像对象.get_height()),  # 复制整个源图像
		Vector2i.ZERO  # 复制到目标图像的(0,0)位置
	)
	处理后的图片=ImageTexture.create_from_image(目标图像)
func _process(_delta):
	queue_redraw()
func _draw():
	# 在场景中可视化显示效果
	处理图像()
	if 处理后的图片 != null and not 矩形数组.is_empty():
		var 图像尺寸 = 处理后的图片.get_size()
		var 显示区域 = 计算图像显示区域(图像尺寸)
		# 绘制原始图像（带偏移和缩放）
		draw_texture_rect(
			处理后的图片,
			显示区域,
			false
		)
		#draw_rect(显示区域, Color(0,0,0), false, 2.0)
		# 绘制蒙版区域轮廓（红色边框）
		#for 矩形 in 矩形数组:
			#draw_rect(矩形, Color.RED, false, 2.0)
