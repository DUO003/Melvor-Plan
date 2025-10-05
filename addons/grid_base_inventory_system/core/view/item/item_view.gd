extends Control
## 物品视图，控制物品的绘制
class_name ItemView

## 堆叠数字的字体
var stack_num_font: Font
## 堆叠数字的字体大小
var stack_num_font_size: int
## 堆叠数字的边距
var stack_num_margin: int = 4
## 堆叠数字的颜色
var stack_num_color: Color = Color.WHITE

## 物品数据
var data: ItemData
## 绘制基础大小（格子大小）
var base_size: int:
	set(value):
		base_size = value
		call_deferred("recalculate_size")
## 是否正在移动
var _is_moving: bool = false
## 移动偏移量（坐标）
var _moving_offset: Vector2i = Vector2i.ZERO


# 记录原始尺寸（初始状态的尺寸）
var 矩形原尺寸: Rect2
# 记录动画中尺寸（更新后的尺寸）
var 矩形新尺寸: Rect2
# 动画是否正在执行（防止重复触发）真为动画触发中
var 动画执行: bool = false
# 动画时长（秒）
const 动画时长: float = 0.1

## 构造函数
@warning_ignore("shadowed_variable")
func _init(data: ItemData, base_size: int, stack_num_font: Font = null, stack_num_font_size: int = 16, stack_num_margin: int = 2, stack_num_color: Color = Color.WHEAT) -> void:
	self.data = data
	self.base_size = base_size
	self.stack_num_font = stack_num_font if stack_num_font else get_theme_font("font")
	self.stack_num_font_size = stack_num_font_size
	self.stack_num_margin = stack_num_margin
	self.stack_num_color = stack_num_color
	recalculate_size()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# 如果 material 不为空，则加上 material
	if data.material:
		material = data.material.duplicate()
	elif GBIS.item_material:
		material = GBIS.item_material.duplicate()
	data.sig_refresh.connect(queue_redraw)

## 重写计算大小
func recalculate_size() -> void:
	#size = Vector2(data.columns * base_size, data.rows * base_size)
	计算矩形尺寸()#覆写了尺寸计算额外保存两个矩形尺寸用于动画 原方法保留
	#print("重新计算")
	queue_redraw()

func 计算矩形尺寸():
	# 计算原始大小
	size = Vector2(data.columns * base_size, data.rows * base_size)
	if 矩形新尺寸==Rect2():
		矩形新尺寸 = Rect2(Vector2.ZERO, size)# 初始化新矩形为原始矩形
	# 获取原贴图的原始尺寸（纹理本身的像素尺寸）
	if data.icon and 矩形原尺寸==Rect2():#
		矩形新尺寸 = Rect2(Vector2.ZERO, size)# 初始化新矩形为原始矩形
		var texture_size = data.icon.get_size()
		# 计算原贴图的宽高比
		var texture_ratio = texture_size.x / texture_size.y
		# 计算当前绘制区域的宽高比
		var draw_area_ratio = size.x / size.y
		# 根据比例差异调整绘制尺寸，确保贴图不变形
		if texture_ratio > draw_area_ratio:
			# 贴图更宽：以宽度为基准缩放，高度按比例缩小，垂直居中
			var scaled_height = size.x / texture_ratio
			矩形新尺寸.size.y = scaled_height
			矩形新尺寸.position.y = (size.y - scaled_height) / 2  # 垂直居中
		else:
			# 贴图更高：以高度为基准缩放，宽度按比例缩小，水平居中
			var scaled_width = size.y * texture_ratio
			矩形新尺寸.size.x = scaled_width
			矩形新尺寸.position.x = (size.x - scaled_width) / 2  # 水平居中
		矩形原尺寸 = 矩形新尺寸
		

## 移动
func move(offset: Vector2i = Vector2i.ZERO) -> void:
	_is_moving = true
	_moving_offset = offset
	调整尺寸动画(Rect2(Vector2.ZERO, size))

## 绘制物品
func _draw() -> void:
	# 如果物品数据中存在图标纹理，则绘制图标（维持宽高比）
	if data.icon:
		# 设置纹理过滤模式为最近邻，解决纹理放大时的模糊问题
		texture_filter = TEXTURE_FILTER_NEAREST
		# 绘制纹理矩形（使用计算后的位置和尺寸，保持宽高比）
		draw_texture_rect(data.icon, 矩形新尺寸, false)
	
	# 如果物品数据是可堆叠类型（StackableData），则绘制堆叠数量文本
	if data is StackableData:
		# 计算堆叠数量文本的尺寸：使用指定字体和字号，文本右对齐，不限制最大宽度
		var text_size = stack_num_font.get_string_size(str(data.current_amount), HORIZONTAL_ALIGNMENT_RIGHT, -1, stack_num_font_size)
		# 计算文本绘制位置：
		# X坐标：节点宽度减去文本宽度再减去边缘间距（靠右对齐并留边距）
		# Y坐标：节点高度减去字体 descent（字体基线到最低点的距离）再减去边缘间距（靠下对齐并留边距）
		var pos = Vector2(
			size.x - text_size.x - stack_num_margin,
			size.y - stack_num_font.get_descent(stack_num_font_size) - stack_num_margin
		)
		# 绘制堆叠数量文本：使用指定字体、位置、文本内容、右对齐、不限制宽度、指定字号和颜色
		draw_string(stack_num_font, pos, str(data.current_amount), HORIZONTAL_ALIGNMENT_RIGHT, -1, stack_num_font_size, stack_num_color)
	
	# 如果存在材质（通常是ShaderMaterial），则更新材质的着色器参数
	if material:
		# 遍历物品数据中存储的所有着色器参数，逐一设置到材质上
		for param_name in data.shader_params.keys():
			(material as ShaderMaterial).set_shader_parameter(param_name, data.shader_params[param_name])
var 测试
## 跟随鼠标
func _process(_delta: float) -> void:
	#var 目标尺寸: Rect2
	#if _is_moving:
		#目标尺寸 = Rect2(Vector2.ZERO, size)
	#else:
		#目标尺寸 = 矩形原尺寸
	#if not 目标尺寸 == 矩形新尺寸:
		#调整尺寸动画(目标尺寸)
	if _is_moving:
		@warning_ignore("integer_division")
		global_position = get_global_mouse_position() - Vector2(base_size * _moving_offset) - Vector2(base_size / 2, base_size / 2)
		queue_redraw()


### 补充功能
func 调整尺寸动画(目标尺寸: Rect2) -> void:
	if 动画执行:
		return
	动画执行 = true
	# 创建 Tween 并设置动画参数
	var tween = create_tween()
	# 注意：Tween 没有 set_duration，时长在 tween_property 中指定
	tween.tween_property(
		self,               # 目标节点（当前节点）
		"矩形新尺寸",       # 要动画的 Rect2 属性
		目标尺寸,           # 目标值（Rect2 类型）
		动画时长            # 持续时间（例如 0.5 秒，需定义该变量）
	)
	# 动画结束后重置状态
	tween.finished.connect(func(): 
		动画执行 = false
		queue_redraw())
	#print("缩放动画",测试,"/r",目标尺寸)
