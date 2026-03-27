extends 游历状态机_基类
class_name 游历状态机_移动_怪物
##自由移动最多进行多少秒
var 目标移动时间:float=1
##
var 移动方向:float=0
##切换到移动状态机时执行
func _enter() -> void:
	super()
	目标移动时间=2*randf()+1
	var 方向: int = 1 if randi() % 2 == 0 else -1#随机生成方向
	var 随机速度百分比: float = randf_range(0.25, 0.5)
	移动方向=随机速度百分比*方向
##移动状态机每帧执行
func _update(间隔: float) -> void:
	super(间隔)
	if not 状态机 is 游历怪物状态机:
		return
	怪物 = agent
	if 状态机 is 游历怪物状态机 and 状态机.追击目标:
		var 方向 = sign(状态机.追击目标.global_position.x - 怪物.global_position.x)
		var 距离 = abs(状态机.追击目标.global_position.x - 怪物.global_position.x)
		怪物.方向更新(状态机.追击目标)
		if 距离<=怪物.近战攻击距离:
			状态机.dispatch("状态切换攻击")
		elif 距离>怪物.最大攻击距离:
			移动方向=方向 * randf_range(0.25, 0.5)
			状态持续时间=0
			状态机.追击目标=null
		else :
			怪物.velocity.x = move_toward(怪物.velocity.x, 怪物.速度 * 方向, 50)
	else :##随机游走
		怪物.velocity.x = move_toward(怪物.velocity.x, 怪物.速度 * 移动方向, 50)
		if 状态持续时间>=目标移动时间:
			状态机.dispatch(EVENT_FINISHED)#当前状态结束信号,有状态机控制切换
