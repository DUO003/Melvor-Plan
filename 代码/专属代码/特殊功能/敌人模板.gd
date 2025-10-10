extends 副本_战斗实体
class_name 副本敌人
var 场景位置="res://界面/敌人模板.tscn"#用于跳转到场景
# 配置参数（可根据需求调整）
var 攻击检测
var 警戒检测
func _ready():
	怪物属性赋值()
	攻击检测 = get_node("攻击范围")
	警戒检测 = get_node("警戒范围")
	警戒检测.body_entered.connect(玩家进入)
	super._ready()
	更新血条()
	播放动画("待机")
	
func 怪物属性赋值():
	血量=100
	攻击=10
	魔法=0
	#("进阶属性")
	回血=0
	回蓝=0
	闪避=0
	暴击=0
	减伤=0
	攻速=2.5
	攻击距离=100
	速度=120
func 启用AI():
	# 初始化状态
	当前目标 = null
	攻击冷却 = 0.0
	硬直 = 0.0
func _physics_process(帧时: float) -> void:
	if super._physics_process(帧时):
		播放动画("受伤",1.0)
		move_and_slide()
		return
	AI逻辑(帧时)
	move_and_slide()
func AI逻辑(帧时):
	if 当前目标 == null:
		return
	var 警戒内物体列表 = 警戒检测.get_overlapping_bodies()
	if not is_instance_valid(当前目标) or 当前目标 not in 警戒内物体列表:
		当前目标 = null  # 目标已离开警戒范围，重置
		var 有效目标候选 = []
		for 物体 in 警戒内物体列表:
			if is_instance_valid(物体) and 物体 is 副本玩家:
				有效目标候选.append(物体)# 检查节点是否有效（未被销毁）且是副本玩家
		# 如果当前目标为空，从有效候选中取第一个作为新目标
		if 有效目标候选.size() > 0:
			当前目标 = 有效目标候选[0]
			print("切换新目标：", 当前目标)
		elif 当前目标 == null:
			播放动画("待机")
			return # 到这里如果仍无目标，返回并切换待机动画
	var 攻击内物体列表 = 攻击检测.get_overlapping_bodies()
	if 当前目标 in 攻击内物体列表:# 检查目标是否在攻击范围内
		播放动画("挥砍",攻速)
		if 攻击冷却<=攻速:
			攻击冷却+=帧时
		else :
			当前目标.受到攻击(攻击)
			攻击冷却=0
		行动条.value=攻击冷却
		velocity.x = 0
	else:
		攻击冷却=0
		行动条.value=攻击冷却
		播放动画("行走")
		var 方向 := 0.0#向目标移动
		if 当前目标.global_position.x > global_position.x:
			方向 = 1.0  # 向右
		else :
			方向 = -1.0  # 向左
		velocity.x = move_toward(velocity.x, 方向 * 速度, 5)
		velocity.y = -1
func 玩家进入(玩家):
	if 玩家 is 副本玩家 and 当前目标==null:
		当前目标=玩家
		#print(name,"发现目标：", 当前目标)
func 播放动画(目标动画名: String, 播放时长: float = 0.0):
	var 图片节点 = %"图片"
	if 图片节点.animation == 目标动画名:
		if not 图片节点.is_playing():
			图片节点.play()  # 启动播放当前动画
		return 图片节点 # 动画相同，直接退出方法
	var 速度缩放=1.0
	if 播放时长 != 0:
		var sprite_frames = 图片节点.sprite_frames  # 获取动画帧资源（SpriteFrames）
		if not sprite_frames.has_animation(目标动画名):
			print("警告：动画「", 目标动画名, "」不存在！")
			return 图片节点# 检查动画是否存在
		var 帧数 = sprite_frames.get_frame_count(目标动画名)
		if 帧数 <= 0:
			print("警告：动画「", 目标动画名, "」帧数为0，无法播放！")
			return 图片节点# 获取动画的帧数
		var 原始帧率 = sprite_frames.get_animation_speed(目标动画名)
		if 原始帧率 <= 0:
			print("警告：动画「", 目标动画名, "」帧率无效！")
			return 图片节点# 获取动画的原始帧率
		var 原始总时长 = 帧数 / 原始帧率
		速度缩放 = 原始总时长 / 播放时长  # 核心：按目标时长调整速度
	图片节点.animation = 目标动画名
	图片节点.speed_scale = 速度缩放
	图片节点.play()  # 确保动画启动
	return 图片节点


func 处理死亡():
	self.collision_layer = 1
	self.collision_mask = 0
	$"攻击范围/区域".disabled= true
	$"警戒范围/区域".disabled= true
	当前目标 = null
	var 图片节点=播放动画("死亡")
	图片节点.animation_finished.connect(func():
		await get_tree().create_timer(1.0).timeout  # 等待1秒
		queue_free())  # 1秒后删除怪物  # 确保信号只触发一次
