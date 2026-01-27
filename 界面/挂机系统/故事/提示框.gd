extends Panel
@export var 提示名称:String="默认提示"
@onready var 关闭: Button = $关闭
func _ready() -> void:
	visible=计划.窗口状态管理("提示信息",提示名称,true)
	关闭.pressed.connect(关闭提示)
func 关闭提示():
	visible=false
	计划.窗口状态管理("提示信息",提示名称,null,false)
