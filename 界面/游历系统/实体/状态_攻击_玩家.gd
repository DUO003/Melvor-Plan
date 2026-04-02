extends 游历状态机_基类
#const 恢复阈值:float = 0.1
#var 打断动画恢复点:float=0
var 调试日志:Dictionary={"_enter":false}
func _enter() -> void:
	获取实体缓存()
	var 日志:bool=调试日志.get("_enter",false)#减少无关日志
	var 日志名称:String="[状态机_攻击]"
	var 缓存技能:梅技能配置=get_cargo() as 梅技能配置
	if 缓存技能:
		if 缓存技能.技能可用检查():
			var 动画时长:float=缓存技能.释放技能(玩家)
			await get_tree().create_timer(动画时长).timeout
			if is_active():
				if 玩家.预输入技能:
					if 日志:print("%s预输入启用"%[日志名称])
					玩家.call_deferred("技能释放检查",玩家.预输入技能,true)
				elif not Input.get_axis("移动_左","移动_右")==0:
					if 日志:print("%s切换移动"%[日志名称])
					状态机.dispatch("状态切换移动")
					return
			else :
				if 日志:print("%s状态机状态错误"%[日志名称])
		else :
			if 日志:print("%s技能不可以用"%[日志名称])
	else :
		print("错误%s未获取到攻击参数"%[日志名称])
	if 日志:print("%s攻击状态机结束"%[日志名称])
	状态机.dispatch(EVENT_FINISHED)
func _update(间隔: float) -> void:
	super(间隔)
	玩家移动(0.75,100)
#func _exit() -> void:
	#var 当前进度 = 动画.current_animation_position
	#var 总时长 = 动画.current_animation_length
	## 【正确公式】：剩余时长 = 原始剩余帧 / 真实播放速度
	#var 真实播放速度 = 动画.speed_scale
	#var 剩余时长 = (总时长 - 当前进度) / 真实播放速度
	## 统一阈值，记录恢复点
	#if 剩余时长 >= 恢复阈值:
		#打断动画恢复点 = 当前进度
	#else:
		#打断动画恢复点 = 0.0
	#super()
