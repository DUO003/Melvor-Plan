extends Control
@onready var 说明文本: Label = %说明文本
@export var 名单字典:Dictionary[String,String]={}
func _ready() -> void:
	计划.清除子节点(self)
	for 名称 in 名单字典:
		var 克隆标签: Label=说明文本.duplicate()
		克隆标签.text=名称
		var 渠道名称=名单字典[名称]
		克隆标签.mouse_entered.connect(func():克隆标签.text=名称+"_来自:"+渠道名称)
		克隆标签.mouse_exited.connect(func():克隆标签.text=名称)
		add_child(克隆标签)
