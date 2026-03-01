extends Control
@export var 提示数据:梅提示数据=null
@export_multiline var 提示:String=""
@onready var 碰撞范围: Control = $碰撞范围
func _ready() -> void:
	碰撞范围.mouse_entered.connect(显示提示)
	碰撞范围.mouse_exited.connect(隐藏提示)
func 显示提示():
	if 提示数据:
		提示数据.节点=self
		计划.数据包提示.emit(提示数据)
	else :
		计划.全局悬浮提示.emit(提示,self,30)
func 隐藏提示():
	计划.全局悬浮提示.emit("",self)
