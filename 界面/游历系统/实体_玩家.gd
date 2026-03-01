@tool
extends 游历实体
class_name 游历实体_玩家
func _ready():
	super._ready()
	if Engine.is_editor_hint():
		return
	计划.地图.玩家导航.connect(设置导航)
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

var 启用自动前进:bool=false
var 自动前进目标:float=0
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
