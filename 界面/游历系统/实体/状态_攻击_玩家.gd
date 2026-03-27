extends 游历状态机_基类
const 恢复阈值:float = 0.1
var 打断动画恢复点:float=0
func _enter() -> void:
	动画速度=1
	super()#播放动画的逻辑
	if 打断动画恢复点>恢复阈值:
		动画.seek(打断动画恢复点, true)
	else :
		玩家.攻击预输入 = false
		玩家.生成攻击("近战攻击","标准剑")#近战攻击实现逻辑与子弹一致,都是召唤出来的
	#print("攻击触发完成")
	await 动画.animation_finished
	if is_active():
		if 玩家.攻击预输入:
			restart()
		elif not Input.get_axis("移动_左","移动_右")==0:
			状态机.dispatch("状态切换移动")
		else :
			状态机.dispatch(EVENT_FINISHED)
func _update(间隔: float) -> void:
	super(间隔)
	玩家移动(0.75,100)
func _exit() -> void:
	var 当前进度 = 动画.current_animation_position
	var 总时长 = 动画.current_animation_length
	# 【正确公式】：剩余时长 = 原始剩余帧 / 真实播放速度
	var 真实播放速度 = 动画.speed_scale
	var 剩余时长 = (总时长 - 当前进度) / 真实播放速度
	# 统一阈值，记录恢复点
	if 剩余时长 >= 恢复阈值:
		打断动画恢复点 = 当前进度
	else:
		打断动画恢复点 = 0.0
	super()
