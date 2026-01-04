extends Control
@export var 资源名称: String = "贴图错误"
@export var 资源标签: String = "贴图错误"
@export var 资源上限: int=5
@export var 资源数量: int=5


@onready var 贴图节点: TextureRect = $贴图
@onready var 进度: ProgressBar = $进度
@onready var 物品标签: Label = $物品标签
@onready var 刻度: Control = %刻度
@onready var 数量标签: Label = $进度/数量标签

var 屏幕尺寸:Vector2
func _ready() -> void:
	visible=false
	屏幕尺寸=计划.游戏分辨率
func 更新传入新值(资源字典,上限,坐标:Vector2):
	刻度.强制量级=10
	资源名称 = 资源字典["物品类型"]
	资源标签 = 资源字典["标签"]
	资源上限 = 上限
	资源数量 = 资源字典["数量"]
	更新状态()
	visible=true
	global_position = 坐标 + Vector2(size.x*-0.5, -size.y-10)
	限制屏幕范围()
func 限制屏幕范围():
	if global_position.x+size.x>屏幕尺寸.x:
		global_position.x=屏幕尺寸.x-size.x
	elif global_position.x<0:
		global_position.x=0
	if global_position.y+size.y>屏幕尺寸.y:
		global_position.y=屏幕尺寸.y-size.y
	elif global_position.y<0:
		global_position.y=0
func 更新状态():
	var 属性=计划.表格.获取属性(资源名称,null)
	var 美味度:float=0.0
	var 工序倍率:float=100
	var 阶级=int(计划.表格.蓝图数据(资源名称,"阶级"))
	if 属性 is Dictionary and 属性.has("美味度"):
		var 倍率=计划.手工.烹饪工序查询(资源标签,"倍率")
		美味度=属性["美味度"]*倍率*(0.5+阶级*0.5)
		工序倍率*=倍率
	物品标签.text="美味度:%.1f(*%.0f%%)\n%s(%s) %s"%[美味度,工序倍率,资源名称,计划.罗马数字(阶级),资源标签]
	if not Engine.is_editor_hint():
		贴图节点.texture = 计划.表格.道具贴图(资源名称)
	进度.max_value=资源上限
	if 资源数量>资源上限:
		资源数量=资源上限
	进度.value=资源数量
	刻度.更新进度条参数(进度.max_value)
	数量标签.text="%d/%d"%[资源数量,资源上限]
