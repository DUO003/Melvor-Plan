extends Control
var 面板文本
var 面板

# 定义变量，默认值为0
var 配方序号 = 0
# 需要在脚本中添加这个变量定义
var 鼠标停留时间 = 0.0
var 上一帧鼠标位置 = Vector2()
# 标记是否已显示悬浮窗口
var 悬浮窗口已显示 = false

func _ready():
	面板文本 = $"悬浮面板背景/面板文本"
	面板 = $"悬浮面板背景"


# 每帧执行的方法
func _process(delta):
	# 检查配方序号是否非0（有选中的配方）
	if 配方序号 != 0:
		# 检查鼠标是否移动（简单检测：比较位置是否变化）
		var 当前鼠标位置 = get_global_mouse_position()
		# 如果鼠标位置有变化，重置停留时间
		if 当前鼠标位置 != 上一帧鼠标位置:
			鼠标停留时间 = 0.0  # 重置计时器
			悬浮窗口已显示 = false  # 鼠标移动时隐藏窗口
		else:
			# 使用delta累加停留时间
			鼠标停留时间 += delta
			
			# 如果停留超过1秒且悬浮窗口未显示
			if 鼠标停留时间 >= 1.0 and not 悬浮窗口已显示:
				# 调用更新文本方法
				更新文本(配方序号)
				# 显示悬浮窗口并设置位置跟随鼠标
				面板.position = 当前鼠标位置 + Vector2(10, 10)  # 偏移一点避免遮挡鼠标
				悬浮窗口已显示 = true
		
		上一帧鼠标位置 = 当前鼠标位置
	else:
		鼠标停留时间 = 0.0  # 重置计时器
		悬浮窗口已显示 = false
	if 悬浮窗口已显示 != 面板.visible:
		面板.visible = 悬浮窗口已显示


func 更新文本(配方编号):
	面板文本.text = 初始化.预生成文本(配方编号,true)
	面板文本.update_minimum_size()# 更新尺寸
	面板文本.set_size(面板文本.get_combined_minimum_size())
	面板.size = 面板文本.size + Vector2(16, 16)
