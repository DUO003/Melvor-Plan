extends Resource
class_name 梅实体数据_回合制
var 有效分组:Array[StringName]=["友方","敌方"]
@export var 分组名称: StringName="敌方"
@export var 名称:String=""
@export var 贴图:Texture=preload("res://icon.svg")
@export var 血量:int=200
@export var 血量成长:int=25
@export var 攻击:int=10
@export var 攻击成长:int=3
##影响行动条
@export var 速度:int=10
##技能(不含普通攻击)
@export var 技能列表:Array[梅技能数据_回合制]
##阵容信息
@export var 排号:int=0
