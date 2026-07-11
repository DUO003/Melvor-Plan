extends VBoxContainer

# 鼠标悬浮视觉偏移像素
@export var 悬浮偏移量: Vector2 = Vector2(0, -4)
# 动画过渡时长
@export var 动画时长: float = 0.12
# 字典：缓存每个按钮正在播放的补间动画，防止动画重叠抖动
var 按钮补间缓存: Dictionary = {}

func _ready() -> void:
	# 遍历容器所有直接子节点
	for 子节点 in get_children():
		# 判断子节点是否为按钮
		if 子节点 is Button:
			初始化按钮悬浮动画(子节点)

# 为单个按钮绑定悬浮进入、离开信号并初始化偏移参数
func 初始化按钮悬浮动画(按钮: Button) -> void:
	# 开启偏移变换，offset系列属性才会生效
	
	按钮.offset_transform_enabled = true
	# 初始视觉偏移归零
	按钮.offset_transform_position = Vector2.ZERO
	# 当前按钮动画缓存初始化为空
	按钮补间缓存[按钮] = null
	# 绑定鼠标进入信号，传入自身按钮对象
	按钮.mouse_entered.connect(鼠标移入按钮.bind(按钮))
	# 绑定鼠标离开信号，传入自身按钮对象
	按钮.mouse_exited.connect(鼠标移出按钮.bind(按钮))

# 鼠标移入按钮：播放偏移上浮动画
func 鼠标移入按钮(目标按钮: Button) -> void:
	# 终止该按钮上还未播放完的旧动画，避免动画叠加错乱
	if 按钮补间缓存[目标按钮]:
		按钮补间缓存[目标按钮].kill()
	# 创建新补间动画
	var 补间动画 = create_tween()
	补间动画.set_ease(Tween.EASE_OUT)
	# 平滑修改视觉偏移属性至悬浮偏移值
	补间动画.tween_property(目标按钮, "offset_transform_position", 悬浮偏移量, 动画时长)
	# 将当前动画存入缓存
	按钮补间缓存[目标按钮] = 补间动画

# 鼠标移出按钮：偏移回归原始位置
func 鼠标移出按钮(目标按钮: Button) -> void:
	if 按钮补间缓存[目标按钮]:
		按钮补间缓存[目标按钮].kill()
	var 补间动画 = create_tween()
	补间动画.set_ease(Tween.EASE_OUT)
	补间动画.tween_property(目标按钮, "offset_transform_position", Vector2.ZERO, 动画时长)
	按钮补间缓存[目标按钮] = 补间动画
