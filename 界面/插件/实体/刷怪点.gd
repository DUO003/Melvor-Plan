@tool
extends Resource
class_name 刷怪点信息包
@export_group("刷怪配置")
@export var 刷怪波次:int=1
##波次大于1时生效[br]
##计时:刷新条件计时器 或 所有怪物死亡[br]
##仅击杀:所有怪物死亡
@export_enum("计时","仅击杀") var 多波次逻辑:String="仅击杀"
##计时模式计时器用时
@export var 刷怪计时器:float=15
##随机刷怪数量范围
@export var 刷怪数量:Vector2i=Vector2i(3,3)
##影响怪物的各种数据,影响效果不一
@export var 基础强度:float=1
@export var 怪物权重:Dictionary[梅怪物配置,float]
##以下参数建议所有可视化配置
@export_group("自动化配置")
@export var 刷怪点位置:Vector2=Vector2i(0,0)
@export var 触发偏移:Vector2=Vector2i(0,-225)
@export var 触发范围:Vector2=Vector2i(100,600)
@export var 视角限制:Vector2=Vector2i(0,-100)
@export var 刷怪点偏移:Array[Vector2]=[Vector2(0,-50)]
