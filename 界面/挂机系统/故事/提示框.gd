extends Panel
class_name 提示框场景
@export var 提示名称:String="默认提示"
@export var 提示内容:String="默认提示"
@onready var 关闭: Button = $关闭
@onready var 文本: Label = $文本
func _ready() -> void:
	文本.text=提示内容
	visible=计划.窗口状态管理("提示信息",提示名称,true)
	关闭.pressed.connect(切换提示状态.bind(false))
	position.x+=size.x*-0.5+32
func 切换提示状态(新状态:bool=false):
	visible=新状态
	计划.窗口状态管理("提示信息",提示名称,null,新状态)
func 传入新文本(新文本:String):
	提示内容=新文本
	文本.text=提示内容
