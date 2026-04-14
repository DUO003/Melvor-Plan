extends Control
class_name 梅帮助提示文本
@export var 提示数据:梅提示数据=null
@export var 提示偏移:Vector2=Vector2(30, 70)
@export_multiline var 提示:String=""
@onready var 碰撞范围: Control = $碰撞范围
# 增加变量跟踪触发状态
var 鼠标进入中: bool = false
var 焦点获得中: bool = false

func _ready() -> void:
	# 连接鼠标事件
	碰撞范围.mouse_entered.connect(_当鼠标进入)
	碰撞范围.mouse_exited.connect(_当鼠标退出)
	
	# 连接焦点事件
	focus_entered.connect(_当获得焦点)
	focus_exited.connect(_当失去焦点)

func _当鼠标进入() -> void:
	鼠标进入中 = true
	_检查并显示提示()

func _当鼠标退出() -> void:
	鼠标进入中 = false
	_检查并隐藏提示()

func _当获得焦点() -> void:
	焦点获得中 = true
	_检查并显示提示()

func _当失去焦点() -> void:
	焦点获得中 = false
	_检查并隐藏提示()

# 检查条件并显示提示（任意条件满足时触发）
func _检查并显示提示() -> void:
	# 如果已经有提示显示（通过任一条件），避免重复触发
	if 鼠标进入中 or 焦点获得中:
		显示提示()

# 检查条件并隐藏提示（所有条件都不满足时触发）
func _检查并隐藏提示() -> void:
	# 只有当鼠标不在范围内且没有焦点时才隐藏提示
	if not 鼠标进入中 and not 焦点获得中:
		隐藏提示()

func 显示提示():
	if 提示数据:
		提示数据.节点=self
		计划.数据包提示.emit(提示数据)
	else:
		计划.全局悬浮提示.emit(提示,self,30)

func 隐藏提示():
	计划.全局悬浮提示.emit("",self)
