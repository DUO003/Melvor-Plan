@tool  # 启用编辑器内预览
extends Control
class_name 圆形进度条
var 配方序号# 合成窗口使用
var 进度条显示 = true  # 控制进度条是否显示的变量
# 半径大小（修改时自动更新圆心和最小尺寸）
@export var 半径: float = 40:
	set(值):
		# 限制半径为正数
		var 新半径 = max(值, 线条宽度)  # 最小 线条宽度 像素避免显示异常
		半径 = 新半径
		queue_redraw()

# 开始角度（修改时自动重绘）
@export var 起始角: float = 0:  # 顶部开始
	set(值):
		# 限制值在0-360度范围
		起始角 = clamp(值, 0, 360)
		# 转换为弧度并计算对应的开始角度（0度=正上方）
		开始角度 = deg_to_rad(起始角 - 90)  # 关键转换：0度对应正上方
		queue_redraw()
var 开始角度: float = PI * 1.5


# 结束角度（修改时自动重绘）
var 结束角度

# 进度值（修改时自动重绘）
@export var 进度: float = 0.1:  # 0-1
	set(值):
		进度 = clamp(值, 0.0, 1.0)  # 限制在0-1范围
		queue_redraw()

# 线条颜色（修改时自动重绘）
@export var 线条颜色: Color = Color(0, 0.8, 1):
	set(值):
		线条颜色 = 值
		queue_redraw()

# 线条宽度（修改时自动重绘）
@export var 线条宽度: float = 10.0:
	set(值):
		线条宽度 = 值
		queue_redraw()

# 背景颜色（修改时自动重绘）
@export var 背景颜色: Color = Color(0.2, 0.2, 0.2):
	set(值):
		背景颜色 = 值
		queue_redraw()

func _draw():
	if not 进度条显示:
		return
	结束角度 = 开始角度 + PI * 2
	# 根据半径自动计算point_count
	# 公式：基础值(32) + 半径/缩放因子(10)，确保在32-256之间
	var 弧段 = clamp(32 + int(半径 / 10), 32, 256)
	var 尺寸 = 半径 * 2 + 线条宽度+10
	var 圆心 = Vector2(尺寸/2, 尺寸/2)
	custom_minimum_size = Vector2(尺寸, 尺寸)
	# 绘制背景圆弧
	draw_arc(圆心, 半径, 开始角度, 结束角度, 弧段, 背景颜色, 线条宽度 - 1, true)
	# 绘制进度圆弧
	var 当前角度 = 开始角度 + (结束角度 - 开始角度) * 进度
	draw_arc(圆心, 半径, 开始角度, 当前角度, 弧段, 线条颜色, 线条宽度, true)

func 更新进度(新进度: float):
	if 新进度 == -1:
		进度条显示 = false
	else :
		进度条显示 = true
	进度 = clamp(新进度, 0.0, 1.0)  # 调用进度的setter，自动触发重绘
