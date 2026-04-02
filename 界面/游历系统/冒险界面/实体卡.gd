extends Panel
class_name 梅游历实体卡
@onready var 技能: HBoxContainer = $技能
@export var 绑定实体:游历实体=null
@onready var 名称: Label = %名称
@onready var 生命: ProgressBar = %生命
@onready var 魔法: ProgressBar = %魔法
@onready var 经验: ProgressBar = %经验
@onready var 生命值: Label = %生命值
@onready var 魔法值: Label = %魔法值
@onready var 经验值: Label = %经验值
func _ready() -> void:
	if 绑定实体:
		计划.地图.注册实体.connect(实体移除检查)
		注册技能()
		名称.text=绑定实体.实体名称
		绑定实体.属性值更新.connect(更新进度条)
		更新进度条()
	else :
		print("实体错误")
		queue_free()
func 更新进度条():
	if 绑定实体:
		生命.max_value=绑定实体.最大生命
		生命.value=绑定实体.生命值
		生命值.text="%d/%d"%[绑定实体.生命值,绑定实体.最大生命]
		魔法.max_value=绑定实体.最大魔法
		魔法.value=绑定实体.魔法值
		魔法值.text="%d/%d"%[绑定实体.魔法值,绑定实体.最大魔法]
func 实体移除检查(实体:游历实体,注册状态:bool):
	if not 绑定实体:
		print("找不到实体")
		queue_free()
		return
	if 实体 and 实体==绑定实体 and not 注册状态:
		queue_free()
func 注册技能():
	var 技能卡数组:Array[Node]=技能.get_children()
	var 序号:int=0
	for 技能按钮 in 技能卡数组:
		if 技能按钮 is 梅游历技能按钮:
			技能按钮.绑定事件(绑定实体,序号)
			序号+=1
