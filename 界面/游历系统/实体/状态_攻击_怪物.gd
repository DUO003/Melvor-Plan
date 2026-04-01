extends 游历状态机_基类

# 统一阈值常量，避免魔法值（修复细节）
const 恢复阈值:float = 0.1
var 打断动画恢复点:float = 0

func _enter() -> void:
	# 赋值顺序正确（先赋值，父类再赋值给speed_scale）
	动画速度 = 0.5
	super()
	if 打断动画恢复点 ==0:
		if 状态机 is 游历怪物状态机 and 状态机.追击目标:
			怪物.方向更新(状态机.追击目标)
		怪物.velocity.x = 0
		怪物.检查释放技能()
	else:
		动画.seek(打断动画恢复点, true)
	# 等待动画完成 + 状态校验（防止异步竞态）
	await 动画.animation_finished
	if not is_active():
		return

	# 原有逻辑不变
	if 状态机 is 游历怪物状态机 and 状态机.追击目标:
		var 距离 = abs(状态机.追击目标.global_position.x - 怪物.global_position.x)
		if 距离 <= 怪物.近战攻击距离:
			restart()
		else:
			状态机.dispatch("状态切换移动")
	else:
		print("找不到目标")
		状态机.dispatch("状态切换待机")
func _update(间隔: float) -> void:
	super(间隔)
	if 状态机 is 游历怪物状态机 and 状态机.追击目标:
		var 方向 = sign(状态机.追击目标.global_position.x - 怪物.global_position.x)
		var 距离 = abs(状态机.追击目标.global_position.x - 怪物.global_position.x)
		if 距离>怪物.近战攻击距离:
			怪物.velocity.x = move_toward(怪物.velocity.x, 怪物.速度 * 方向*0.5, 50)
		elif 距离<怪物.角色碰撞箱宽度:
			怪物.velocity.x = move_toward(怪物.velocity.x, 怪物.速度 * 方向*-0.25, 50)
		else :
			怪物.velocity.x = 0

func _exit() -> void:
	# ============== 核心修复2：正确计算动画剩余时长 ==============
	var 当前进度 = 动画.current_animation_position
	var 总时长 = 动画.current_animation_length
	# 【正确公式】：剩余时长 = 原始剩余帧 / 真实播放速度
	var 真实播放速度 = 动画.speed_scale
	var 剩余时长 = (总时长 - 当前进度) / 真实播放速度

	# 统一阈值，记录恢复点
	if 剩余时长 >= 恢复阈值:
		print("恢复点",当前进度)
		打断动画恢复点 = 当前进度
	else:
		打断动画恢复点 = 0.0
	super()
