@tool
extends 实体卡片
class_name 玩家卡片
func _ready() -> void:
	if Engine.is_editor_hint():
		super._ready()
		return
	实体名称=计划.梅存档.get("挂机",{}).get("用户信息",{}).get("用户名","错误")
	super._ready()
