@tool
extends 游历实体
class_name 游历实体_玩家
var 玩家跳跃高度:float=-870
var 摄像机: Camera2D
@onready var 拾取检查: Area2D = %拾取检查
@onready var 拾取范围: CollisionShape2D = %拾取范围
@onready var 指令状态机: LimboHSM = %指令状态机
func _ready():
	super._ready()
	if Engine.is_editor_hint():
		return
var AI启用状态:bool=false
func _physics_process(间隔: float) -> void:
	super(间隔)
	if AI启用状态 and 控制检查():
		指令状态机.set_active(false)
	elif not AI启用状态 and not 控制检查():
		指令状态机.set_active(true)
	#计划.地图.玩家导航.connect(设置导航)
#var 二段跳:bool
#var 松开跳跃:bool
#var 启用自动前进:bool=false
#var 自动前进目标:float=0
#var 攻击计时器:float=0
#var 攻击冷却:float=2
var 多段跳上限:int=2
func 加载实体数据():
	var 属性管理器:=计划.装备
	最大生命=属性管理器.血量
	生命值=计划.数据状态("生命值",int(最大生命))
	最大护盾=0
	护盾值=0
	最大魔法=属性管理器.魔法+100
	魔法值=计划.数据状态("魔法值",int(最大魔法))
	攻击力=属性管理器.攻击
	防具承伤比例=属性管理器.减伤
	暴击力=属性管理器.暴击
	暴击抗性=属性管理器.抗性
	击退力=Vector2(-属性管理器.击退力,-属性管理器.击退力)
	每秒回血=属性管理器.回血
	每秒回蓝=属性管理器.回蓝
	每秒回盾=0
	攻击间隔=属性管理器.攻速
	最大攻击距离=属性管理器.攻击距离*10
	近战攻击距离=属性管理器.攻击距离
	速度=计划.地图.地图默认速度*属性管理器.移速倍率
	跳跃高度=计划.地图.地图默认弹跳*属性管理器.跳跃倍率
	多段跳上限=属性管理器.跳跃上限
	var 普通攻击:梅技能配置=梅技能配置.new("近战攻击",1)
	技能配置.append(普通攻击)
	var 火球技能:梅技能配置=梅技能配置.new("火球术",1)
	技能配置.append(火球技能)
	var 手部装备:物品装备=属性管理器.语法糖获取装备物品("主手")
	if 手部装备:武器名称=手部装备.item_name
	else :武器名称="抓痕"
	#武器名称="火球"
	其他属性=属性管理器.计算其他属性()
	状态机配置=属性管理器.计算状态机配置()
func 切换摄像机():
	if 摄像机 and 摄像机.get_parent():
		摄像机.get_parent().remove_child(摄像机)
		self.add_child(摄像机)
func 状态跳转条件():
	状态机.add_transition(移动状态,待机状态,移动状态.EVENT_FINISHED,死亡检查.bind(false))
	状态机.add_transition(攻击状态,待机状态,攻击状态.EVENT_FINISHED,死亡检查.bind(false))
	状态机.add_transition(状态机.ANYSTATE,移动状态,"状态切换移动",死亡检查.bind(false))
	状态机.add_transition(状态机.ANYSTATE,受击状态,"状态切换受击",死亡检查.bind(false))
	状态机.add_transition(状态机.ANYSTATE,攻击状态,"状态切换攻击",死亡检查.bind(false))
	状态机.add_transition(状态机.ANYSTATE,死亡状态,"状态切换死亡")
var 多段跳:int=0
func 加载动画与碰撞范围():
	super()
	拾取范围.shape=碰撞范围.shape
var 键位攻击映射: Dictionary = {
	"攻击": 0,
	"技能1": 1,
	"技能2": 2,
	"技能3": 3
}
func 控制检查()->bool:
	if 计划.地图.控制队友 and 计划.地图.控制队友==self:
		return true
	return false
func _unhandled_input(按键: InputEvent) -> void:
	if not 控制检查():
		return
	if 按键.is_action_pressed("移动_跳"):
		多段条逻辑()
	elif 按键.is_action_pressed("移动_下"):
		平台向下()
	elif 按键.is_action_pressed("攻击"):
		输入攻击指令(0)
	elif 按键.is_action_pressed("技能1"):
		输入攻击指令(1)
	elif 按键.is_action_pressed("技能2"):
		输入攻击指令(2)
	elif 按键.is_action_pressed("技能3"):
		输入攻击指令(3)
	elif 按键.is_action_pressed("交互"):
		执行拾取()
	elif 按键.is_action_pressed("移动_上"):
		执行拾取(false)
	elif 按键.is_action_pressed("移动_左") or 按键.is_action_pressed("移动_右"):
		状态机.dispatch("状态切换移动")
func 多段条逻辑():
	if is_on_floor():
		velocity.y=玩家跳跃高度
		多段跳=多段跳上限+-1
	else :
		if 多段跳>=1:
			velocity.y=玩家跳跃高度
			多段跳+=-1
	
var 平台向下触发:bool=false
func 平台向下():
	if not 平台向下触发:
		平台向下触发=true
		position.y += 2
		await get_tree().create_timer(0.1).timeout
		平台向下触发=false
		
# 核心：拾取最近的掉落物
func 执行拾取(全部拾取:bool=true):
	# 获取当前所有在拾取范围内的物理物体
	var 重叠物体数组 = 拾取检查.get_overlapping_bodies()
	
	# 存储有效掉落物
	var 有效掉落物列表: Array[掉落物实例] = []
	
	# 筛选出【掉落物】且未被拾取的对象
	for 物体 in 重叠物体数组:
		if 物体 is 掉落物实例:
			if not 物体.已拾取:
				有效掉落物列表.append(物体)
	
	# 没有可拾取物品 → 退出
	if 有效掉落物列表.is_empty():
		return
	if 全部拾取:
		for 掉落物 in 有效掉落物列表:
			掉落物.尝试拾取()
	else :
		# 寻找【最近】的掉落物
		var 最近掉落物: 掉落物实例 = null
		var 最小距离:float = INF
		
		for 物品 in 有效掉落物列表:
			var 距离 = global_position.distance_to(物品.global_position)
			if 距离 < 最小距离:
				最小距离 = 距离
				最近掉落物 = 物品
		
		# 找到 → 调用掉落物自身的拾取方法
		if 最近掉落物:
			最近掉落物.尝试拾取()
var 预输入技能:梅技能配置=null
func 输入攻击指令(技能编号:int):
	if 技能配置.size()>技能编号:
		预输入技能=技能配置[技能编号]
		技能释放检查(技能配置[技能编号],true)
var 输入有效期:float=2
var 调试日志:Dictionary={"技能释放检查":true}
var 操作ID:int=0
func 技能释放检查(缓存技能:梅技能配置,延迟检查:bool=false):
	var 日志:bool=调试日志.get("技能释放检查",false)#减少无关日志
	if 缓存技能:
		操作ID+=1
		var 缓存ID:int=操作ID
		var 缓存日志名称:String="<%d>%s技能"%[缓存ID,缓存技能.技能名称]
		预输入技能=null
		if 日志:print("[调试]%s开始检查"%缓存日志名称)
		var 技能状态值:String=缓存技能.技能不可用原因(self)
		if not 技能状态值=="可用":
			if not 延迟检查:#取消延迟检查
				if 日志:print("[调试-退出]%s：未开启延迟检查"%缓存日志名称)
				return
			match 技能状态值:
				"冷却":
					var 技能冷却:float=缓存技能.剩余冷却时间()
					if 技能冷却>0 and 技能冷却<输入有效期:
						if 日志:print("[调试]%s：技能进入等待冷却 %.2f" % [缓存日志名称,技能冷却])
						await get_tree().create_timer(技能冷却).timeout
					else :
						if 日志:print("[调试-退出]%s：技能冷却时间超出输入有效期"%缓存日志名称)
						return
				"魔法":
					if 日志:print("[调试-退出]%s：技能法力不足"%缓存日志名称)
					return
				_:
					print("[错误]%s：未定义错误<%s>"%[缓存日志名称,str(技能状态值)])
					return
		if not 缓存ID==操作ID:
			if 日志:print("[调试-退出]%s：操作被覆盖"%缓存日志名称)
			return
		var 状态机当前:LimboState=状态机.get_active_state()
		if 状态机当前==攻击状态 or 状态机当前==受击状态:
			if 日志:print("[调试-退出]%s：当前处于攻击/受击状态，无法释放"%缓存日志名称)
			return
		if 日志:print("[调试]%s：释放检查通过，准备切换攻击状态"%缓存日志名称)
		状态机.dispatch("状态切换攻击",缓存技能)#第二次技能冷却检查
	else:
		if 日志:print("[调试-退出]缓存技能为空")
#func 移动更新(间隔: float) -> void:
	#var 控制按钮组: Array = ["移动_左", "移动_右", "移动_跳"]
	#var 移动:float
	#if 任意被按下(控制按钮组):
		#启用自动前进=false
		#移动=Input.get_axis("移动_左","移动_右")
	#else :
		#移动=导航()
	#velocity.x=move_toward(velocity.x,速度*移动,50)
	#velocity.y+=间隔*重力加速度
	#if 摄像机 and 碰撞范围:  # 空值判断，避免摄像机未初始化报错
		#var 形状:RectangleShape2D=碰撞范围.shape
		#var 碰撞盒尺寸: Vector2 = 形状.size
		#var 玩家半宽: float = 碰撞盒尺寸.x / 2.0
		## 2. 计算玩家实际可移动的X边界（结合摄像机限制和自身尺寸）
		#var 玩家左边界: float = 摄像机.limit_left + 玩家半宽
		#var 玩家右边界: float = 摄像机.limit_right - 玩家半宽
		## 3. 限制玩家X坐标在边界内
		#position.x = clamp(position.x, 玩家左边界, 玩家右边界)
	#if 计划.地图.关卡战线<position.x:
		#计划.地图.关卡战线=position.x
	#攻击检查.force_raycast_update()
	#if 攻击检查.is_colliding():
		#攻击计时器+=间隔
		#if 攻击计时器>=攻击冷却:
			#攻击计时器=0
			#var 目标=攻击检查.get_collider()
			#var 距离:float=abs(position.x-目标.position.x)
			#if 目标 and 距离<最大攻击距离:
				##print("距离%d/%d"%[距离,近战攻击距离])
				#if 距离<近战攻击距离:
					#生成攻击("近战攻击","标准剑")
				#else :
					#生成攻击("远程攻击","标准剑")
	#elif 攻击计时器>间隔 :
		#攻击计时器-=间隔
	#else :
		#攻击计时器=0
	#if is_on_floor():
		#if Input.is_action_just_pressed("移动_跳"):
			#velocity.y=玩家跳跃高度
			#二段跳=true
			#松开跳跃=false
		#if 动画节点.动画:
			#if 移动==0.0:动画节点.动画.play("待机")
			#else :动画节点.动画.play("移动")
	#else :
		#if Input.is_action_just_pressed("移动_跳"):
			#if 松开跳跃 and 二段跳:
				#velocity.y=玩家跳跃高度
				#二段跳=false
		#else :
			#松开跳跃=true
#func 设置导航(目标:float):
	#启用自动前进=true
	#自动前进目标=目标
#func 导航():
	#if 启用自动前进:
		#var 位置全局:float = global_position.x
		#if abs(位置全局-自动前进目标)<=10:
			#启用自动前进=false
			#return 0
		#if 自动前进目标>位置全局:return 1
		#else :return -1
	#return 0
