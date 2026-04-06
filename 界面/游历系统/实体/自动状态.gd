extends 游历状态机_基类
var 状态名称:String="默认"
var 队列间距:float=150
func _update(间隔: float) -> void:
	获取实体缓存()
	if not 玩家.AI启用状态:
		状态机.dispatch(EVENT_FINISHED)
		return
	super(间隔)
	var 控制队友:游历实体_玩家=计划.地图.控制队友
	if 控制队友:#随从逻辑
		var 跟随实体:Array[游历实体]=控制队友.跟随实体
		if not 跟随实体.has(玩家):
			跟随实体.append(玩家)
		var 跟随序号:int= 跟随实体.find(玩家)-1
		var 目标X坐标:float=0
		if 跟随序号>=跟随实体.size():
			print("错误,超出数组")
			breakpoint#断点
		if 跟随序号<0:
			目标X坐标=控制队友.global_position.x
		else :
			var 上个实体:游历实体=跟随实体[跟随序号]
			目标X坐标=上个实体.global_position.x
		var 方向:int = int(sign(目标X坐标 - 玩家.global_position.x))
		var 距离:float = abs(目标X坐标 - 玩家.global_position.x)
		var 速度:float=clampf(距离/200,0.1,1.05)#距离玩家越远速度越快,最快可以已1.05倍移动
		if 距离<队列间距*0.5:
			玩家移动(速度,50,-方向)
		elif 距离<队列间距:
			玩家.velocity.x=0
		else :
			玩家移动(速度,50,方向)
	else :
		玩家移动(1,50,0)
		#print("没有正在控制的玩家")
