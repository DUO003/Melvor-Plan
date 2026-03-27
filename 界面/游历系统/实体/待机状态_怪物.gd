extends 游历状态机_基类
func _enter() -> void:
	super()
	if 状态持续时间>=1:
		状态持续时间=0
		状态机.dispatch("状态切换移动")
func _update(间隔: float) -> void:
	super(间隔)
	减速(agent)
