extends CharacterBody2D
class_name 副本_战斗实体
var 攻击范围
var 血条
var 行动条
var 最大血量
#("基础属性")
var 血量:int=100
var 攻击:int=10
var 魔法:int=0
#("进阶属性")
var 回血:int=0
var 回蓝:int=0
var 闪避:int=0
var 暴击:int=0
var 减伤:float=0
var 攻速:float=2
var 攻击距离:int=50
# 状态变量
var 速度: float = 100.0  # X轴移动速度
var 当前目标 = null   # 当前追踪的玩家目标
var 攻击冷却: float = 0.0  # 下次攻击的时间
var 硬直: float = 0.0  # 硬直剩余时间
func _ready() -> void:
	最大血量=血量
	攻击范围 = $"攻击范围"
	血条=$"血条"
	血条.max_value=最大血量
	血条.value=血量
	行动条=$"行动条"
	行动条.max_value=攻速
	行动条.value=0
func _physics_process(帧时):
	if not is_on_floor():# 添加重力
		velocity += get_gravity() * 帧时
	if 0 < 硬直:# 检查是否处于硬直状态（高优先级）
		硬直-=帧时
		return true
	return false
func 受到攻击(伤害=1):
	血量-=max(int(max((1.0-减伤),0.05)*伤害),1)
	if 硬直<=0 and 伤害>=0.05*血量 and randf() <= 血量*1.0 / (最大血量*1.0):
		硬直=0.5*randf()
	更新血条()
	if 血量<=0:
		处理死亡()
func 更新血条():
	血条.value=血量
	血条.max_value=最大血量
func 处理死亡():
	# 可选：写默认逻辑，或抛错误提醒子类覆写
	push_error("子类必须覆写 '处理死亡' 方法！")
