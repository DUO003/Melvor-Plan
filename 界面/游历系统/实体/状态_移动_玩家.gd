extends 游历状态机_基类
var 退出移动延迟:float=0.5
var 已累计移动延迟:float=0
func _update(间隔: float) -> void:
	super(间隔)
	var 移动:=玩家移动()
	if 移动==0:
		已累计移动延迟+=间隔
		if 已累计移动延迟>=退出移动延迟:
			状态机.dispatch(EVENT_FINISHED)
	else :
		玩家.方向更新_指定(1 if 移动>0 else -1)
		已累计移动延迟=0
