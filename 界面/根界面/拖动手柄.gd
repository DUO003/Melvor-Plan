# 拖动手柄的脚本（挂载到「拖动手柄」节点）
extends Control

# 鼠标按下标记：是否按住了拖动手柄
var 鼠标按下 := false
# 初始偏移：鼠标按下时，鼠标位置相对于父节点（测试按钮）的坐标偏移
var 初始偏移: Vector2
# 父节点：测试按钮（提前缓存，避免重复获取）
var 测试按钮: Button

func _ready():
	# 获取父节点（测试按钮）
	测试按钮 = get_parent() as Button
	读取位置()
	if not 测试按钮:
		push_error("拖动手柄的父节点不是Button类型！")
		return
	gui_input.connect(_on_gui_input)
	
func 读取位置():
	测试按钮.global_position=计划.窗口状态_限制("测试","测试的位置",测试按钮.global_position,
	计划.游戏分辨率-(size+Vector2(测试按钮.size.x,40)),Vector2(320,0))
	
# 监听鼠标事件（核心）
func _on_gui_input(event: InputEvent) -> void:
	# 1. 鼠标左键按下：记录状态和初始偏移
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		鼠标按下 = true
		# 计算偏移：鼠标全局位置 - 父节点（测试按钮）的全局位置
		初始偏移 = get_global_mouse_position() - 测试按钮.global_position
	# 2. 鼠标左键松开：重置状态
	elif event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		鼠标按下 = false
		读取位置()
	# 3. 鼠标移动：如果按下，更新父节点位置
	elif event is InputEventMouseMotion and 鼠标按下:
		# 获取当前鼠标全局位置
		var 当前鼠标全局位置 = get_global_mouse_position()
		# 计算父节点新位置：鼠标位置 - 初始偏移（抵消手柄在按钮上的偏移）
		var 新位置 = 当前鼠标全局位置 - 初始偏移
		# 赋值给父节点（测试按钮）的全局坐标（适配CanvasLayer的屏幕空间）
		测试按钮.global_position = 新位置
		计划.窗口状态管理("测试","测试的位置",null,测试按钮.global_position)
