extends 游历状态机_基类
func _enter() -> void:
	super()
	if 玩家:
		玩家.攻击预输入 = false
	agent.velocity.x=0
	await 动画.animation_finished
	if 状态机 is 游历标准状态机:
		状态机.受击间隔=0
	agent.velocity.y=-300
	#状态机.dispatch(EVENT_FINISHED)
	var 上一个状态:=状态机.get_previous_active_state()
	状态机.change_active_state(上一个状态)
