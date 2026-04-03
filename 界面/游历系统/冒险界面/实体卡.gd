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
@onready var 控制: Button = %控制
@onready var 属性: Button = %属性
func _ready() -> void:
	if 绑定实体:
		计划.地图.注册实体.connect(实体移除检查)
		注册技能()
		名称.text=绑定实体.实体名称
		绑定实体.属性值更新.connect(更新进度条)
		更新进度条()
		控制.pressed.connect(切换控制实体)
		属性.mouse_entered.connect(属性弹窗.bind(true))
		属性.mouse_exited.connect(属性弹窗.bind(false))
	else :
		print("实体错误")
		queue_free()
func 属性弹窗(启用:bool=true):
	if 绑定实体:
		绑定实体.属性弹窗(启用)
	#var 通知数据:梅提示数据=梅提示数据.new()
	#通知数据.节点=self
	#if 启用:
		#通知数据.通用解析(绑定实体)
	#计划.数据包提示.emit(通知数据)
func 切换控制实体():
	if 计划.地图.控制队友==绑定实体:
		计划.地图.控制队友=null
	else :
		计划.地图.控制队友=绑定实体
		if 绑定实体 is 游历实体_玩家:
			绑定实体.切换摄像机()
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
