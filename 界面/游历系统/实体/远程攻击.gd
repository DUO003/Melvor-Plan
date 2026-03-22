extends 游历子弹
class_name 游历子弹_远程攻击
##子弹创建后立即播放动画
func _ready() -> void:
	if not 初始化参数检查():
		return
	var 所有动画名称: PackedStringArray = 动画.get_animation_list()
	if 武器名称 not in 所有动画名称:
		print("警告：动画「%s」不存在，已重置为默认动画" % 武器名称)
		武器名称 = "标准剑"
	动画.play(武器名称)
	动画.advance(0)
	动画.stop()
	攻击范围.body_entered.connect(击中事件)
	print("攻击武器:%s"%武器名称)
@export var 子弹方向: Vector2= Vector2(-1,0)
@export var 子弹速度: float=1000
@export var 最大飞行距离: float=500
func _physics_process(间隔: float) -> void:
	position+=子弹方向*子弹速度*间隔
	最大飞行距离-=abs(子弹速度*间隔)
	if 最大飞行距离<=0:
		攻击结束()
func 击中事件(实体:Node2D):
	if 实体 is 游历实体:
		造成伤害()
		攻击结束()
