extends Panel
@onready var 技能: HBoxContainer = $技能
@export var 绑定实体:游历实体=null
func 注册技能():
	var 技能卡数组:Array[Node]=技能.get_children()
	for 技能按钮 in 技能卡数组:
		if 技能按钮 is 梅游历技能按钮:
			技能按钮.绑定实体=绑定实体
