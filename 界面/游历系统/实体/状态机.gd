extends LimboHSM
class_name 游历标准状态机
var 受击保护:float=1.0
var 受击间隔:float=0
func 受击检查():
	if 受击间隔>=受击保护:
		dispatch("状态切换受击")
func _update(间隔: float) -> void:
	受击间隔+=间隔
