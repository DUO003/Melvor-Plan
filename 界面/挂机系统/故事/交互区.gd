extends Area2D
class_name 通用交互区域
@export var 强制:bool=false
var 上个碰撞目标:Node
@onready var 根节点: 交互功能区 = $".."
func _ready() -> void:
	collision_layer=0
	collision_mask=1
	set_collision_layer_value(4,true)
	set_collision_mask_value(4,true)
	body_entered.connect(处理进入)
	body_exited.connect(处理离开)
#增加:bool,内容:String,节点:Node
func 处理进入(节点):
	#print("玩家进入碰撞区")
	if 根节点.检查 and not 强制 or 根节点.强制 and 强制:
		横版单例.更新_交互.emit(true,根节点.交互代码,根节点,强制)
		上个碰撞目标=节点
func 处理离开(节点):
	if 上个碰撞目标==节点:
		横版单例.更新_交互.emit(false,根节点.交互代码,根节点,强制)
		上个碰撞目标=null
