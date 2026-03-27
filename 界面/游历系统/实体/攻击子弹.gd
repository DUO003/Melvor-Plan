extends Node2D
class_name 游历子弹
##子弹创建后立即播放动画
@export var 伤害值: float = 1
@export var 碰撞目标层:int=0
@export var 武器名称:String="标准剑"
@onready var 攻击范围: Area2D = %攻击范围
@onready var 动画: AnimationPlayer = %动画
@onready var 贴图: TextureRect = %贴图
@onready var 蒙版: Panel = %蒙版
func 初始化参数检查()->bool:
	if 碰撞目标层>=1:
		攻击范围.collision_layer=0
		攻击范围.collision_mask=0
		攻击范围.set_collision_mask_value(碰撞目标层, true)
		return true
	else :
		攻击结束()
		return false
##由动画调用函数
func 造成伤害():
	var 范围内的实体列表 = 攻击范围.get_overlapping_bodies()
	for 实体 in 范围内的实体列表:
		if 实体 is 游历实体:
			实体.受伤害(伤害值)
			if self is 游历子弹_近战攻击:
				var 子弹:游历子弹_近战攻击=self
				实体.velocity+=子弹.击退力
	#print("实体列表",范围内的实体列表,"\r碰撞层",攻击范围.collision_layer)
func 动画结束(_动画名称:String):
	攻击结束()
func 攻击结束():
	queue_free()
