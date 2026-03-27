extends 游历标准状态机
class_name 游历怪物状态机
var 追击目标:游历实体=null

@onready var 攻击检查: Area2D = %攻击检查

func _update(间隔: float) -> void:
	super(间隔)
func _ready() -> void:
	攻击检查.body_entered.connect(进入范围.bind("攻击",true))
	攻击检查.body_exited.connect(进入范围.bind("攻击",false))
func 进入范围(实体:Node2D,类型:String,进入:bool):
	if not 实体 or not 实体 is 游历实体:
		return
	if 类型=="攻击" and 进入 and not 追击目标:
			追击目标=实体
			dispatch("状态切换移动")
