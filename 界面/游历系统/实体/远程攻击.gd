extends 游历子弹
class_name 游历子弹_远程攻击
##子弹创建后立即播放动画
@onready var 子弹粒子: GPUParticles2D = $子弹粒子
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
var 攻击已失效:bool=false
func _physics_process(间隔: float) -> void:
	if 攻击已失效:
		return
	position+=子弹方向*子弹速度*间隔
	最大飞行距离-=abs(子弹速度*间隔)
	if 最大飞行距离<=0:
		攻击结束()
func 击中事件(实体:Node2D):
	if 攻击已失效:
		return
	if 实体 is 游历实体:
		造成伤害()
		攻击结束()
func 攻击结束():
	if 攻击已失效:
		return
	攻击已失效=true
	if 子弹粒子.emitting:
		print("移除事件")
		动画节点.visible=false
		子弹粒子.emitting=false
		攻击范围.monitoring=false
		await get_tree().create_timer(子弹粒子.lifetime).timeout
	super()
func 播放音效(音频名称:String):
	计划.声音.播放音效(音频名称)
	
