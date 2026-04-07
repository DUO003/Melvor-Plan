extends ScrollContainer
@onready var 队伍容器: HBoxContainer = %队伍容器
func _ready():
	计划.清除子节点(队伍容器)
	计划.地图.注册实体.connect(实体卡注册)
var 实体卡场景 = preload("res://界面/游历系统/冒险界面/实体卡.tscn")
func 实体卡注册(实体:游历实体,注册状态:bool):
	if 注册状态 and 实体 is 游历实体_玩家:
		var 克隆实体卡:梅游历实体卡=实体卡场景.instantiate().duplicate()
		克隆实体卡.绑定实体=实体
		队伍容器.add_child(克隆实体卡)
