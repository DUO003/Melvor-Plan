extends Control
class_name 梅拖动自己
@export var 拖动目标节点: Control
@export var 基类窗口名称:String=""
@export var 保存名称:String=""
# 拖动状态变量
var 是否正在拖动: bool = false
# 鼠标点击位置与节点原点的偏移量（避免拖动时节点瞬移）
var 拖动偏移量: Vector2 = Vector2.ZERO
func _ready():
	# 节点就绪时绑定信号（防止检查器未配置时出错）
	if 拖动目标节点:
		拖动目标节点.gui_input.connect(_处理GUI输入事件)
		print("绑定成功",拖动目标节点)
	else :
		print("错误,找不到拖动目标节点",拖动目标节点)
# 处理GUI输入事件的核心逻辑
func _处理GUI输入事件(事件: InputEvent) -> void:
	print("成功")
	if 事件 is InputEventMouseButton:
		if 事件.button_index == MOUSE_BUTTON_LEFT and 事件.pressed:# 左键按下：开启拖动
			是否正在拖动 = true
			拖动偏移量 = 事件.global_position - global_position
		elif 事件.button_index == MOUSE_BUTTON_LEFT and not 事件.pressed:
			是否正在拖动 = false
			if not(基类窗口名称=="" or 保存名称==""):
				计划.窗口状态管理(基类窗口名称,保存名称,null,position)
	elif 事件 is InputEventMouseMotion and 是否正在拖动:
		global_position = 事件.global_position - 拖动偏移量

func _exit_tree():
	# 1. 先判断拖动目标节点是否有效
	if 拖动目标节点:
		var 目标回调: Callable = _处理GUI输入事件
		if 拖动目标节点.is_connected("gui_input", 目标回调):
			拖动目标节点.gui_input.disconnect(目标回调)
