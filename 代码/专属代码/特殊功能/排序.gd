@tool  # 启用编辑器内预览
extends Control
class_name 排序

# 半径大小（修改时自动更新）
@export var 半径: float = 25:
	set(值):
		半径 = 值
		queue_redraw()
@export var 高度: float = 50:
	set(值):
		高度 = 值
		queue_redraw()
# 颜色（同时用于圆形和矩形）
@export var 颜色: Color = Color(1.0, 0.0, 0.0, 1.0):
	set(值):
		颜色 = 值
		queue_redraw()
@export var 内容长度:int=100:
	set(值):
		内容长度 = 值
		queue_redraw()
@export var 内容数组: Array[Dictionary] = [{Color(1.0, 0.0, 0.0, 1.0):10}]:
	set(值):
		内容数组 = 值
		queue_redraw()
@export var 编辑器内显示:bool=true:
	set(值):
		编辑器内显示 = 值
		queue_redraw()
# 导出为滑块：范围0-1，步长0.05（精度）
@export_range(0, 1, 0.01) var 编辑器内预览: float = 1:
	set(值):
		编辑器内预览 = 值
		queue_redraw()  # 值变化时触发重绘
@export var 迷雾数量:int=0:
	set(值):
		迷雾数量 = 值
		queue_redraw()

var 椭圆区域:Rect2
@export var 偏移量:Vector2=Vector2.ZERO:
	set(值):
		偏移量 = 值
		queue_redraw()
func _draw():
	# 编辑器内预览逻辑（保持原样）
	椭圆区域 = Rect2(Vector2(0,-高度+半径*2), Vector2(半径 * 2,半径*2))
	椭圆区域.position += 偏移量  # 只移动位置
	if Engine.is_editor_hint():
		if 编辑器内显示:
			绘制水面(高度*编辑器内预览, 颜色)  # 编辑器默认预览
			#draw_rect(椭圆区域,Color(0.98, 0.0, 0.0, 0.384), true)
			return
	var 绘制参数列表 = []
	# 第一步：收集所有绘制参数
	var 累计高度: float = 0
	for 字典元素 in 内容数组:
		var 颜色列表 = 字典元素.keys()
		var 高度分量列表 = 字典元素.values()
		
		if 颜色列表.size() == 0 or 高度分量列表.size() == 0:
			continue
		
		var 当前颜色: Color = 颜色列表[0]
		var 当前高度分量: float = 高度分量列表[0]
		
		累计高度 += 当前高度分量
		var 当前绘制高度: float = 高度 * (累计高度 / 内容长度)
		
		# 将当前层的参数存入列表（高度和颜色）
		绘制参数列表.append({
			"高度": 当前绘制高度,
			"颜色": 当前颜色
		})
	# 第二步：反转列表，让最早的层最后绘制（避免被覆盖）
	绘制参数列表.reverse()
	# 第三步：按反转后的顺序绘制所有层
	for 参数 in 绘制参数列表:
		绘制水面(参数["高度"], 参数["颜色"])
	if 迷雾数量>0:
		绘制水面(高度 * (float(迷雾数量) / 内容长度), 颜色)

func 绘制水面(控制高度: float, 绘制颜色: Color):
	if 半径 <= 0:
		print("半径必须大于0")
		return
	
	var 处理后高度 = min(控制高度, 半径)
	var 弦中点x = 半径
	var 弦中点y = 半径
	var 距离 = 半径 - 处理后高度
	var 圆心x = 弦中点x
	var 圆心y = 弦中点y
	var 圆心角 = 2 * acos(距离 / 半径)
	var 起始角度 = PI - 圆心角/2 - PI/2
	var 结束角度 = PI + 圆心角/2 - PI/2
	var 点列表 = []
	var 点数量 = 32
	
	for i in range(点数量 + 1):
		var 角度 = 起始角度 + (结束角度 - 起始角度) * i / 点数量
		# 计算坐标时添加偏移量
		var x = 圆心x + 半径 * cos(角度) + 偏移量.x
		var y = 圆心y + 半径 * sin(角度) + 偏移量.y
		点列表.append(Vector2(x, y))
	
	# 闭合多边形时也添加偏移量
	点列表.append(Vector2(圆心x + 半径 * cos(结束角度) + 偏移量.x, 
						  圆心y + 半径 * sin(结束角度) + 偏移量.y))
	点列表.append(Vector2(圆心x + 半径 * cos(起始角度) + 偏移量.x, 
						  圆心y + 半径 * sin(起始角度) + 偏移量.y))
	
	draw_polygon(点列表, [绘制颜色])
	
	# 绘制上方矩形时添加偏移量
	var 矩形高度 = max(0, 控制高度 - 半径)
	if 矩形高度 > 0:
		var 矩形区域
		if 矩形高度 >= 高度 - 半径*3:
			@warning_ignore("narrowing_conversion")
			矩形高度 = 高度 - 半径*3
			# 正确的矩形偏移方式：只修改位置，不改变大小
			@warning_ignore("narrowing_conversion")
			绘制半个椭圆(椭圆区域, 控制高度 - 高度 + 半径*2, 绘制颜色)
		
		# 矩形区域计算时添加偏移量
		矩形区域 = Rect2(
			Vector2(0 + 偏移量.x, 半径 - 矩形高度 + 偏移量.y), 
			Vector2(半径 * 2, 矩形高度)
		)
		draw_rect(矩形区域, 绘制颜色, true)



func 绘制半个椭圆(矩形区域: Rect2, 显示高度: int, 绘制颜色: Color) -> void:
	# 基础校验：矩形必须有有效尺寸
	if 矩形区域.size.x <= 0 or 矩形区域.size.y <= 0:
		return
	
	# 有效高度处理：限制在0到矩形高度之间
	var 有效高度 = min(max(显示高度, 0), 矩形区域.size.y)
	if 有效高度 <= 0:
		return
	
	# 定义矩形边界（固定值，椭圆形状仅与此相关）
	var 左 = 矩形区域.position.x
	var 右 = 矩形区域.position.x + 矩形区域.size.x
	var 底 = 矩形区域.position.y + 矩形区域.size.y  # 底边y坐标
	var 矩形高度 = 矩形区域.size.y  # 矩形固定高度（椭圆完整短轴参考）
	
	# 椭圆核心参数（仅由矩形大小决定）
	var 长轴半径 = 矩形区域.size.x / 2.0  # 长轴半径由矩形宽度决定
	var 完整短轴半径 = 矩形高度  # 完整半椭圆的短轴半径（等于矩形高度）
	var 中心x = 左 + 长轴半径  # 椭圆中心x坐标
	var 步长单位 = 完整短轴半径 / 16.0  # 步长基于矩形高度（固定）
	
	# 收集左侧点（从底部到显示高度处）
	var 左侧点 = []
	var 步数 = 1
	var 最大步数 = 1000
	while 步数 <= 最大步数:
		# 基于矩形高度计算偏移（确保椭圆形状固定）
		var 基于矩形的y偏移 = 步数 * 步长单位
		# 转换为当前显示高度下的实际y坐标
		var 实际y = 底 - 基于矩形的y偏移
		
		# 超出当前显示高度则停止
		if 基于矩形的y偏移 > 有效高度:
			break
		
		# 椭圆方程计算（使用完整短轴半径确保形状固定）
		var 比例 = 1.0 - (基于矩形的y偏移 * 基于矩形的y偏移) / (完整短轴半径 * 完整短轴半径)
		比例 = max(比例, 0.0)
		var x = 中心x - 长轴半径 * sqrt(比例)
		左侧点.append(Vector2(x, 实际y))
		
		步数 += 1
	
	# 收集右侧点（从底部到显示高度处）
	var 右侧点 = []
	步数 = 1
	while 步数 <= 最大步数:
		var 基于矩形的y偏移 = 步数 * 步长单位
		var 实际y = 底 - 基于矩形的y偏移
		
		if 基于矩形的y偏移 > 有效高度:
			break
		
		var 比例 = 1.0 - (基于矩形的y偏移 * 基于矩形的y偏移) / (完整短轴半径 * 完整短轴半径)
		比例 = max(比例, 0.0)
		var x = 中心x + 长轴半径 * sqrt(比例)
		右侧点.append(Vector2(x, 实际y))
		
		步数 += 1
	
	# 反转右侧点，使其从上到下排列
	右侧点.reverse()
	
	# 构建点序列（确保顺时针闭合）
	var 点阵列 = PackedVector2Array()
	点阵列.append(Vector2(左, 底))  # 左下角
	
	# 添加左侧点（从下到当前显示高度）
	点阵列.append_array(左侧点)
	
	# 顶部处理：
	if 有效高度 >= 矩形高度:
		# 显示高度等于矩形高度时，顶部是椭圆顶端点（完整半椭圆）
		点阵列.append(Vector2(中心x, 底 - 矩形高度))
	else:
		# 显示高度不足时，顶部是水平线（连接两侧对应点）
		if 左侧点.size() > 0:
			点阵列.append(左侧点[-1])  # 左侧最高点
		if 右侧点.size() > 0:
			点阵列.append(右侧点[0])   # 右侧最高点
	
	# 添加右侧点（从上到下）
	点阵列.append_array(右侧点)
	
	# 添加右下角
	点阵列.append(Vector2(右, 底))
	
	# 去重处理（避免三角化失败）
	var 去重点阵列 = PackedVector2Array()
	for 点 in 点阵列:
		if 去重点阵列.find(点) == -1:
			去重点阵列.append(点)
	
	# 绘制多边形
	if 去重点阵列.size() >= 3:
		draw_polygon(去重点阵列, [绘制颜色])
	else:
		print("无法绘制多边形：点数量不足（至少需要3个点）")
