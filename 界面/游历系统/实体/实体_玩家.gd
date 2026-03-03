@tool
extends 游历实体
class_name 游历实体_玩家
var 玩家跳跃高度:float=-870
func _ready():
	super._ready()
	if Engine.is_editor_hint():
		return
	计划.地图.玩家导航.connect(设置导航)
	更新位置状态()
var 二段跳:bool
var 松开跳跃:bool
var 启用自动前进:bool=false
var 自动前进目标:float=0
var 摄像机: Camera2D
func 移动更新(间隔: float) -> void:
	var 控制按钮组: Array = ["移动_左", "移动_右", "移动_跳"]
	var 移动:float
	if 任意被按下(控制按钮组):
		启用自动前进=false
		移动=Input.get_axis("移动_左","移动_右")
	else :
		移动=导航()
	velocity.x=move_toward(velocity.x,速度*移动,50)
	velocity.y+=间隔*重力加速度
	if 摄像机 and 碰撞范围:  # 空值判断，避免摄像机未初始化报错
		var 形状:RectangleShape2D=碰撞范围.shape
		var 碰撞盒尺寸: Vector2 = 形状.size
		var 玩家半宽: float = 碰撞盒尺寸.x / 2.0
		# 2. 计算玩家实际可移动的X边界（结合摄像机限制和自身尺寸）
		var 玩家左边界: float = 摄像机.limit_left + 玩家半宽
		var 玩家右边界: float = 摄像机.limit_right - 玩家半宽
		# 3. 限制玩家X坐标在边界内
		position.x = clamp(position.x, 玩家左边界, 玩家右边界)
	if is_on_floor():
		if Input.is_action_just_pressed("移动_跳"):
			velocity.y=玩家跳跃高度
			二段跳=true
			松开跳跃=false
		if 动画节点.动画:
			if 移动==0.0:动画节点.动画.play("待机")
			else :动画节点.动画.play("移动")
	else :
		if Input.is_action_just_pressed("移动_跳"):
			if 松开跳跃 and 二段跳:
				velocity.y=玩家跳跃高度
				二段跳=false
		else :
			松开跳跃=true
##当前帧发生移动时调用
func 更新位置状态():
	if 计划.地图.传送点有效:
		var 传送点位置:Rect2=计划.地图.传送点位置
		var 之前接触状态:bool = 计划.地图.接触传送点
		计划.地图.接触传送点=传送点位置.has_point(position)
		if 计划.地图.接触传送点 != 之前接触状态:
			计划.地图.传送门更新.emit(计划.地图.接触传送点)
	else :#找不到传送门,设置为默认接触
		计划.地图.接触传送点=true
func 设置导航(目标:float):
	启用自动前进=true
	自动前进目标=目标
func 导航():
	if 启用自动前进:
		var 位置全局:float = global_position.x
		if abs(位置全局-自动前进目标)<=10:
			启用自动前进=false
			return 0
		if 自动前进目标>位置全局:return 1
		else :return -1
	return 0
