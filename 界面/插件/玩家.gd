extends Control
class_name 玩家卡片
@onready var 玩家名称: Label = $玩家名称
@onready var 动画: AnimationPlayer = $动画
func _ready() -> void:
	玩家名称.text=计划.梅存档.get("挂机",{}).get("用户信息",{}).get("用户名","错误")
