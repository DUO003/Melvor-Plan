extends Control
@export var 资源名称: String = "贴图错误"
@export var 资源上限: int=5
@export var 资源数量: int=5


@onready var 贴图节点: TextureRect = $贴图
@onready var 进度: ProgressBar = $进度
@onready var 物品标签: Label = $物品标签
var 屏幕尺寸:Vector2
func _ready() -> void:
	屏幕尺寸=计划.游戏分辨率
func 更新传入新值(资源,上限,数量,坐标:Vector2):
	资源名称 = 资源
	资源上限 = 上限
	资源数量 = 数量
	更新状态()
	visible=true
	global_position = 坐标 + Vector2(size.x*-0.5, -80)
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
	物品标签.text=资源名称
	if not Engine.is_editor_hint():
		贴图节点.texture = 计划.表格.道具贴图(资源名称)
	进度.max_value=资源上限
	进度.value=资源数量
