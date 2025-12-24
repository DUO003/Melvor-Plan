extends Control
func _ready() -> void:
	$Label.text=计划.梅存档.get("挂机",{}).get("用户信息",{}).get("用户名","错误")
