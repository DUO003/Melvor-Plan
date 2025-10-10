extends 副本_战斗实体
class_name 副本玩家
var 副本
var 动画
func _ready() -> void:
	缓存玩家属性()
	super._ready()
	动画=$"动画"
	播放动画("奔跑",0.5)
func 缓存玩家属性():
	var 缓存=初始化.玩家单例
	缓存.更新属性()
	血量=缓存.血量
	攻击=缓存.攻击
	魔法=缓存.魔法
	#("进阶属性")
	回血=缓存.回血
	回蓝=缓存.回蓝
	闪避=缓存.闪避
	暴击=缓存.暴击
	减伤=缓存.减伤
	攻速=缓存.攻速
	攻击距离=缓存.攻击距离
func 播放动画(目标动画名: String, 播放速度: float = 1.0) -> void:
	if 动画.current_animation == 目标动画名:
		return  # 动画相同，直接退出方法
	动画.play(目标动画名, -1, 播放速度)#动画不同从头播放目标动画
func _physics_process(帧时):
	velocity.x=0.0
	if super._physics_process(帧时):
		播放动画("蹲下")
		move_and_slide()
		return
	move_and_slide()
	if 攻击范围.is_colliding():
		var 碰撞对象 = 攻击范围.get_collider()
		if 碰撞对象 != null and 碰撞对象 is 副本敌人:
			播放动画("持武器待机")
			if 攻击冷却<=攻速:
				攻击冷却+=帧时
			else :
				碰撞对象.受到攻击(攻击)
				攻击冷却=0
			行动条.value=攻击冷却
		return
	else :
		攻击冷却=0
		行动条.value=攻击冷却
		播放动画("奔跑",0.5)
	副本.地图更新(速度 * 帧时*-1)
func 处理死亡():
	初始化.切换场景(null,"战斗界面")
