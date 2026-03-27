extends 游历状态机_基类

# 两个安全标记
var 死亡过: bool = false
var 已生成掉落物: bool = false  # 新增：确保只掉一次

func _enter() -> void:
	if 死亡过:
		return
	死亡过 = true
	super()

	agent.velocity.x = 0
	await 动画.animation_finished

	# --------------------------
	# 移除这里的 生成掉落物(agent)
	# --------------------------

	# 关闭碰撞 + 向上跳跃
	agent.collision_layer = 0
	agent.collision_mask = 0
	agent.velocity.y = -500  # 向上跳

	# 玩家逻辑不变
	if agent is 游历实体_玩家:
		var 摄像机: Camera2D = agent.摄像机
		if 摄像机 and agent.get_parent():
			摄像机.global_position = 摄像机.global_position
			摄像机.global_rotation = 摄像机.global_rotation
			摄像机.reparent(agent.get_parent())

	# 1秒后销毁（不影响掉落物生成时机）
	await get_tree().create_timer(1.0).timeout
	agent.queue_free()


# ✅ 核心：每一帧检查是否到达最高点、开始下落
func _update(间隔: float) -> void:
	super(间隔)
	# 必须满足：是怪物 + 没死过 + 没掉落过 + 开始向下落（velocity.y > 0）
	if agent is 游历实体_怪物 and not 已生成掉落物 and agent.velocity.y > 0:
		已生成掉落物 = true  # 上锁，只执行一次
		生成掉落物(agent)     # 此时才生成！
func 生成掉落物(实体:游历实体_怪物):
	print("生成掉落物已执行 —— 跳跃最高点下落时")
	var 掉落物参数 := 实体.实体掉落
	var 掉落物品列表 = 掉落物参数.计算掉落结果()
	for 物品数据 in 掉落物品列表:
		print("掉落物%s*%d" % [物品数据["名称"], 物品数据["数量"]])
		var 随机偏移 = Vector2(
			randf_range(-32, 32),  # X 轴
			randf_range(-128, -32))   # Y 轴
		
		# ====================== 【配置完成】智能尺寸计算 ======================
		var 数量: int = 物品数据["数量"]
		var 最小尺寸:int = 48
		var 最大尺寸:int = 82
		var 尺寸值 = 最小尺寸 + (最大尺寸 - 最小尺寸) * (数量 / 64.0)
		尺寸值 = clamp(尺寸值, 最小尺寸, 最大尺寸)
		# 生成正方形尺寸
		var 尺寸 = Vector2(尺寸值, 尺寸值)

		计划.地图.创建掉落物(
			物品数据["名称"],
			物品数据["数量"],
			实体.global_position+随机偏移,
			物品数据["类型"],
			物品数据["参数"],
			尺寸)
