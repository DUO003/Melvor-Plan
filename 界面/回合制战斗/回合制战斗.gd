extends Control
class_name 梅回合管理器

@export var 回合制实体: PackedScene = preload("res://界面/回合制战斗/回合制实体.tscn")
@export var 友方位置: 梅定位_回合制
@export var 敌方位置: 梅定位_回合制
@export var 友方数据组: Array[梅实体数据_回合制]
@export var 敌方数据组: Array[梅实体数据_回合制]

@onready var 行动条显示区:梅行动条 = %行动条显示区
@onready var 动画特效: Node2D = %动画特效
@onready var 控制ui区: 梅控制区_回合制 = $控制UI区


var 实体数组:Array[梅回合制实体]=[]
var 选中实体:梅回合制实体=null:
	set(值):
		选中实体=值
		if not 控制ui区:
			return
		if 选中实体 and 选中实体 is 梅回合制实体:
			控制ui区.重载控制区(选中实体)
signal 确认选择技能()
@warning_ignore("unused_signal")
signal 回合开始(行动实体:梅回合制实体)
@warning_ignore("unused_signal")
signal 回合结束(行动实体:梅回合制实体)
func _ready() -> void:
	回合制初始化()
func _选择技能方法(选择技能:梅技能数据_回合制):
	if 选中实体:
		选中实体.手动选择技能=选择技能
		确认选择技能.emit()
func 回合制初始化():
	if not 友方位置 or not 敌方位置:
		print("错误,占位符节点不存在")
		return
	for 数据 in 友方数据组:
		创建实体(友方位置,数据)
	for 数据 in 敌方数据组:
		创建实体(敌方位置,数据)
	for 实体 in 实体数组:
		实体.global_position=实体.站位
func 创建实体(位置: 梅定位_回合制,数据:梅实体数据_回合制):
	var 实体:梅回合制实体=回合制实体.instantiate()
	var 分组名称: StringName=数据.分组名称
	if not 实体.is_in_group(分组名称):
		实体.add_to_group(分组名称)
	var 等级:int=0
	实体.最大血量=数据.血量+数据.血量成长*等级
	实体.攻击力=数据.攻击+数据.攻击成长*等级
	实体.速度=数据.速度
	实体.阵营=数据.分组名称
	实体.贴图=数据.贴图
	实体.技能列表=克隆技能数组(数据.技能列表)
	实体.回合管理器=self
	位置.插入实体(实体,数据.排号)
	位置.add_child(实体)
	实体数组.append(实体)
	实体.死亡信号.connect(移除实体.bind(实体))
	行动条显示区.创建目标(实体)
	if not 选中实体 and 分组名称=="友方":
		选中实体=实体
	if not ["敌方","友方"].has(str(分组名称)):
		print("警告,出现非法分组")
func 克隆技能数组(源数组: Array[梅技能数据_回合制]) -> Array[梅技能数据_回合制]:
	var 结果:Array[梅技能数据_回合制] = []
	for 技能 in 源数组:
		结果.append(技能.duplicate(true))
	return 结果
func 移除实体(实体:梅回合制实体):
	实体.queue_free()
	实体数组.erase(实体)
	行动条显示区.移除目标(实体)
	
