extends TextureRect

# 自定义中文变量（仅这部分改中文，内置属性保留英文）
@export var 六边形外接圆半径: float = 64.0
@export var 网格颜色: Color = Color(0, 0, 0)
@export var 网格宽度: float = 2.0
@export var 纹理:Texture2D
# 预计算六边形顶点（点向上）
func _获取六边形顶点() -> PackedVector2Array:
	var 顶点数组 = PackedVector2Array()
	for i in 6:
		var 角度 = deg_to_rad(60 * i + 30)  # 30°偏移让第一个顶点在正上方
		var x = 六边形外接圆半径 * cos(角度)
		var y = 六边形外接圆半径 * sin(角度)
		顶点数组.append(Vector2(x, y))
	return 顶点数组

# 重写绘制逻辑：只绘制六边形内的纹理 + 绘制网格
func _draw() -> void:
	if not texture:  # 保留Godot内置属性名
		return
	
	# 1. 计算六边形顶点（以节点中心为原点）
	var 顶点数组 = _获取六边形顶点()
	var rect_size
	# 节点中心坐标（rect_size为内置属性，保留英文）
	var 节点中心 = Vector2(rect_size.x / 2, rect_size.y / 2)
	
	# 2. 绘制纹理（仅显示六边形内的区域）
	var 裁剪多边形 = ConvexPolygonShape2D.new()
	裁剪多边形.points = 顶点数组
	draw_set_transform(节点中心)
	#draw_texture_polygon(texture, 顶点数组, [], [], true)  # texture为内置属性
	
	# 3. 绘制六边形网格边框
	draw_set_transform(节点中心)
	draw_polyline(顶点数组 + [顶点数组[0]], 网格颜色, 网格宽度)

# 节点尺寸变化时重新绘制
func _notification(通知类型: int) -> void:
	if 通知类型 == NOTIFICATION_RESIZED:
		queue_redraw()  # 保留Godot内置方法名

# 初始化节点尺寸（匹配六边形大小）
func _ready() -> void:
	# 点向上六边形的宽高公式
	var 六边形宽度 = 2 * 六边形外接圆半径
	var 六边形高度 = sqrt(3) * 六边形外接圆半径
	size = Vector2(六边形宽度, 六边形高度)  # rect_size为内置属性
