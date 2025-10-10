extends CharacterBody2D
# AI核心开关
var AI开关 = false
# 玩家阵营对象数组（外部传入）
var 玩家阵营 = []
# 配置参数（可根据需求调整）
var 检测范围: float = 300.0  # 检测玩家的范围半径
var 攻击距离: float = 60.0   # 触发攻击的距离
var 移动速度: float = 250.0  # X轴移动速度
var 攻击冷却: float = 1.5    # 攻击间隔时间（秒）
var 硬直时间: float = 1    # 被攻击后的硬直时间（秒）
# 状态变量
var 当前目标: Node2D = null   # 当前追踪的玩家目标
var 上次攻击时间: float = 0.0  # 上次攻击的时间戳
var 硬直结束时间: float = 0.0  # 硬直状态结束的时间戳
var 重力=2000
var 速度=Vector2(0,0)
func 启用AI():
###启用AI逻辑###
	AI开关 = true
	# 初始化状态
	当前目标 = null
	上次攻击时间 = 0.0
	硬直结束时间 = 0.0
func 敌人标识():
	return true
func 受到攻击():
###受到攻击时触发（最高优先级）###
	print("被攻击，打断当前行动")
	# 进入硬直状态，打断所有行动
	硬直结束时间 = 硬直时间
	# 清空当前目标（受击后暂时丢失目标）
	当前目标 = null
func _physics_process(帧时):
	if not AI开关:###每帧更新AI逻辑
		return  # AI未启用则不执行
	if 0 < 硬直结束时间:# 检查是否处于硬直状态（高优先级）
		硬直结束时间-=帧时
		print("处于硬直状态，无法行动")
		return
	if 当前目标==null:
		检测玩家目标()# 检测范围内的玩家目标
	if 当前目标:
		# 有目标时处理移动和攻击
		处理追踪与攻击(帧时)
	else:
		# 无目标时待机
		print("播放待机动画")


func 检测玩家目标():
###检测范围内最近的玩家目标###
	当前目标 = null
	var 最近距离 = 检测范围 + 1  # 初始值设为超过检测范围
	
	for 玩家 in 玩家阵营:
		# 过滤无效对象（已销毁或未就绪）
		if not is_instance_valid(玩家) or not 玩家.is_inside_tree():
			continue
		# 计算与玩家的直线距离
		var 距离 = global_position.distance_to(玩家.global_position)
		# 筛选范围内最近的玩家
		if 距离 <= 检测范围 and 距离 < 最近距离:
			最近距离 = 距离
			当前目标 = 玩家


func 处理追踪与攻击(帧时):
###处理向目标移动和攻击逻辑###
	var 自身位置 = global_position
	var 目标位置 = 当前目标.global_position
	var 水平距离 = abs(目标位置.x - 自身位置.x)  # X轴距离
	var 方向 = 1 if 目标位置.x > 自身位置.x else -1  # 移动方向（右为1，左为-1）
	if 水平距离 > 攻击距离:# 检查是否在攻击范围内
		# 不在攻击范围，移动靠近（仅X轴）
		position.x += 方向 * 移动速度 * 帧时
		print("播放移动动画")
	else:
		# 在攻击范围，尝试攻击
		if 上次攻击时间 <=0 :
			执行攻击()
			上次攻击时间 = 攻击冷却
		else:
			上次攻击时间 -= 帧时
			print("攻击冷却中，等待攻击")
func 执行攻击():
###执行攻击逻辑###
	print("播放攻击动画")
	# 伤害逻辑预留
	pass
