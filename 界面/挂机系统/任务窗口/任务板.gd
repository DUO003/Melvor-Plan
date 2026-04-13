@tool  # 标记为工具脚本，支持在编辑器中运行
extends Panel
class_name 梅任务面板  # 中文类名
@onready var 成就任务文本: RichTextLabel = %成就任务文本
var text:String="测试文本":
	set(值):
		text=值
		成就任务文本.text=text
func _ready() -> void:
	成就任务文本.text=text
