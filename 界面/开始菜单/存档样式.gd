extends Panel
@onready var 文本节点: RichTextLabel = $文本节点
var 文本信息:=""
func _ready() -> void:
	更新文本()
func 更新文本():
	文本节点.text=文本信息
