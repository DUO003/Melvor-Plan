extends LimboState
class_name 游历状态机_基类
@onready var 状态机: LimboHSM = %状态机
@export var 动画名称: String="待机"
var 状态持续时间:float=0
var 动画: AnimationPlayer
var 动画速度:float=1.0
##
var 玩家:游历实体_玩家
##
var 怪物:游历实体_怪物
func _enter() -> void:
	#print("动画名称:",动画名称)
	状态持续时间=0
	var 动画节点:实体卡片=(agent as 游历实体).动画节点
	动画=动画节点.动画
	if not 动画名称=="":
		播放动画(动画名称,动画速度)
func 播放动画(名称:String,速度:float):
	动画.speed_scale=速度
	动画.play("RESET")
	动画.seek(0, true)
	动画.play(名称)
func 获取实体缓存():
	if not agent:return
	if agent is 游历实体_玩家:玩家=agent
	elif  agent is 游历实体_怪物:怪物=agent
func _update(间隔: float) -> void:
	状态持续时间+=间隔
func _exit() -> void:
	if 动画:动画.stop()
func 玩家移动(移速倍率:float=1.0,加速值:int=50,移动:float=0)->float:
	if 移动==0:减速(玩家,加速值*2)
	else :玩家.velocity.x=move_toward(玩家.velocity.x,玩家.速度*移动*移速倍率,加速值)
	玩家限制()
	return 移动
func 玩家限制():
	if 玩家 and 玩家.摄像机 and 玩家.碰撞范围:  # 空值判断，避免摄像机未初始化报错
		var 摄像机:=玩家.摄像机
		var 形状:Shape2D=玩家.碰撞范围.shape
		var 玩家半宽: float = 形状.radius / 2.0
		# 2. 计算玩家实际可移动的X边界（结合摄像机限制和自身尺寸）
		var 玩家左边界: float = 摄像机.limit_left + 玩家半宽
		var 玩家右边界: float = 摄像机.limit_right - 玩家半宽
		# 3. 限制玩家X坐标在边界内
		玩家.position.x = clamp(玩家.position.x, 玩家左边界, 玩家右边界)
	if 计划.地图.关卡战线<玩家.position.x:
		计划.地图.关卡战线=玩家.position.x
func 减速(实体:Node2D,减速值:int=100):
	实体.velocity.x=move_toward(实体.velocity.x,0,减速值)
