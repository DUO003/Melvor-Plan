@tool
extends CharacterBody2D
class_name 游历实体
var 卡片素材:Dictionary={
	"玩家":{
		"场景":preload("res://界面/插件/实体/玩家.tscn"),
		"范围":Vector2(35,140),
		"偏移":Vector2(0,-75),
		"血条偏移":Vector2(-70,-186),
		"代码":游历实体_玩家},
	"村民":{
		"场景":preload("res://界面/插件/实体/实体卡片.tscn"),
		"范围":Vector2(35,140),
		"偏移":Vector2(0,-75),
		"血条偏移":Vector2(-70,-186)},
	"怪物":{
		"场景":preload("res://界面/插件/实体/实体卡片.tscn"),
		"范围":Vector2(35,140),
		"偏移":Vector2(0,-75),
		"血条偏移":Vector2(-70,-186),
		"代码":游历实体_怪物},}
var 子弹字典:Dictionary={
	"近战攻击":{
		"场景":preload("res://界面/游历系统/实体/近战攻击.tscn")},
	"远程攻击":{
		"场景":preload("res://界面/游历系统/实体/远程攻击.tscn")},}
@export var 实体名称: String="玩家"
@export_enum("玩家","队友","怪物","村民") var 实体类型: String="玩家"
## 生命值：修改时仅更新血量进度条
var 生命值: float = 100:
	set(值):
		生命值 = clamp(值, 0, 最大生命)  # 限制数值范围
		# 仅更新血量进度条（最小化更新）
		if is_inside_tree() and 血量 and 血量.is_inside_tree():
			血量.value = 生命值
## 最大生命值：修改时仅更新血量进度条的最大值+同步当前生命值
var 最大生命: float = 100:
	set(值):
		最大生命 = max(值, 1)  # 确保最大值不为负
		生命值 = clamp(生命值, 0, 最大生命)  # 修正当前生命值不超限
		# 仅更新血量进度条的最大值和当前值
		if is_inside_tree() and 血量 and 血量.is_inside_tree():
			血量.max_value = 最大生命
			血量.value = 生命值
## 护盾值：修改时仅更新护盾进度条
var 护盾值: float = 0:
	set(值):
		护盾值 = clamp(值, 0, 最大护盾)
		if is_inside_tree() and 护盾 and 护盾.is_inside_tree():
			护盾.value = 护盾值
## 最大护盾：修改时仅更新护盾进度条的最大值+同步当前护盾值
var 最大护盾: float = 0:
	set(值):
		最大护盾 = max(值, 0)
		护盾值 = clamp(护盾值, 0, 最大护盾)
		if is_inside_tree() and 护盾 and 护盾.is_inside_tree():
			护盾.max_value = 最大护盾
			护盾.value = 护盾值
## 魔法值：修改时仅更新魔法进度条
var 魔法值: float = 0:
	set(值):
		魔法值 = clamp(值, 0, 最大魔法)
		if is_inside_tree() and 魔法 and 魔法.is_inside_tree():
			魔法.value = 魔法值
## 最大魔法：修改时仅更新魔法进度条的最大值+同步当前魔法值
var 最大魔法: float = 0:
	set(值):
		最大魔法 = max(值, 0)
		魔法值 = clamp(魔法值, 0, 最大魔法)
		if is_inside_tree() and 魔法 and 魔法.is_inside_tree():
			魔法.max_value = 最大魔法
			魔法.value = 魔法值
##不为0时显示血条
var 血条显示: float = 0:
	set(值):
		血条显示 = 值
		更新血条显示状态()
var 攻击力:float=15
var 重力加速度:float=ProjectSettings.get("physics/2d/default_gravity") as float
var 最大攻击距离: float = 500
var 近战攻击距离: float = 135
var 速度:float=500.0
var 跳跃高度:float=-870
var 地图外判断:int=1100#Y大于这个值视为掉出地图
var 出生点:Vector2
@onready var 血量: ProgressBar = %血量
@onready var 护盾: ProgressBar = %护盾
@onready var 魔法: ProgressBar = %魔法
@onready var 碰撞范围: CollisionShape2D = %碰撞范围
@onready var 动画节点: 实体卡片 = $动画
@onready var 攻击检查: Area2D = %攻击检查
@onready var 近战攻击容器: Node2D = %近战攻击容器
##状态机
@onready var 状态机: 游历标准状态机 = $状态机
##状态
@onready var 待机状态: 游历状态机_基类 = %待机状态
@onready var 受击状态: 游历状态机_基类 = %受击状态
@onready var 死亡状态: 游历状态机_基类 = %死亡状态
@onready var 移动状态: 游历状态机_基类 = %移动状态
@onready var 攻击状态: 游历状态机_基类 = %攻击状态
func _ready():
	var 编辑器名: Label = %编辑器名
	if Engine.is_editor_hint():
		编辑器名.text=实体名称
		动画节点.offset_bottom=0
		return
	else :
		编辑器名.queue_free()
	初始化实体()
	更新进度条()
	更新位置状态()
	加载实体数据()
func 加载实体数据():
	最大生命=100
	生命值=100
	每秒回血=0
	最大魔法=0
	魔法值=0
	每秒回蓝=0
	最大护盾=0
	护盾值=0
	每秒回盾=-1
	攻击力=15
##变量更新时自动调用,但保留手动
func 更新进度条() -> void:
	if 血量 and 血量.is_inside_tree():
		血量.max_value = 最大生命
		血量.value = 生命值
	if 护盾 and 护盾.is_inside_tree():
		护盾.max_value = 最大护盾
		护盾.value = 护盾值
	if 魔法 and 魔法.is_inside_tree():
		魔法.max_value = 最大魔法
		魔法.value = 魔法值
	#print("进度条已更新：生命=%s/%s，护盾=%s/%s，魔法=%s/%s" % 
		  #[生命值, 最大生命, 护盾值, 最大护盾, 魔法值, 最大魔法])
func 更新血条显示状态():
	if is_inside_tree() and 血量 and 血量.is_inside_tree():
		血量.visible=not(血条显示==0)
		魔法.visible=最大魔法>0
		护盾.visible=最大护盾>0
func 初始化实体() -> void:
	# 1. 安全校验：确保碰撞范围节点已正确获取
	if not 碰撞范围:
		print("错误：碰撞范围节点（CollisionShape2D）未找到，请检查节点路径或名称")
		return
	# 2. 校验角色名称是否存在于卡片素材字典中
	if not 卡片素材.has(实体类型):
		print("错误：卡片素材字典中未找到【%s】类型的配置" % 实体类型)
		return
	加载动画与碰撞范围()
	设置碰撞层和遮罩()
	初始化状态机()
	出生点=position
	血条显示=0
func 初始化状态机():
	状态跳转条件()
	状态机.initialize(self)
	状态机.set_active(true)
func 状态跳转条件():
	pass
	#状态机.add_transition()
func 加载动画与碰撞范围():
	#获取该角色对应的配置数据
	var 角色配置: Dictionary = 卡片素材[实体类型]
	#新建RectangleShape2D并设置尺寸
	#var 判定范围区: RectangleShape2D = RectangleShape2D.new()
	#判定范围区.size = 角色配置.get("范围",Vector2(65,140))  # 从字典读取尺寸
	var 判定范围区:=CapsuleShape2D.new()
	var 范围配置:Vector2=角色配置.get("范围",Vector2(42,150))
	判定范围区.radius = 范围配置.x
	判定范围区.height = 范围配置.y
	碰撞范围.shape = 判定范围区# 设置新的Shape
	碰撞范围.position = 角色配置.get("偏移",Vector2(0,-75))  # 设置位置偏移
	if 动画节点 and is_instance_valid(动画节点):
		动画节点.queue_free()
		动画节点 = null
	var 加载场景: PackedScene = 角色配置.get("场景",null)
	if 加载场景:# 实例化动画场景
		动画节点 = 加载场景.instantiate()
		动画节点.scale=Vector2(0.5,0.5)
		动画节点.position=Vector2(-130,-360)
		动画节点.gui_input.connect(点击检查)
		if 实体类型=="村民":
			动画节点.传入数据(实体名称,计划.表格.道具贴图(实体名称),实体类型)
		if 实体类型=="怪物":
			动画节点.传入数据(实体名称,计划.表格.道具贴图(实体名称),实体类型)
		add_child(动画节点,false,INTERNAL_MODE_FRONT)
	else :print("错误：无法加载【%s】的动画场景：%s" % [实体名称, 角色配置["场景"]])
	if 血量:
		血量.position=角色配置.get("血条偏移",Vector2(-70,-186))
	
# 核心：设置碰撞层和遮罩的内部方法（无需传参，使用内置的「实体类型」变量）
func 设置碰撞层和遮罩():
	collision_layer=0
	collision_mask=0
	match 实体类型:
		"玩家":# 玩家同时属于「玩家层」和「队友层」
			set_collision_layer_value(3, true)  # Layer 3 玩家
			set_collision_layer_value(5, true)  # Layer 5 队友（友方标记）
		"队友":
			set_collision_layer_value(5, true)  # Layer 5 队友
		"怪物":
			set_collision_layer_value(2, true)  # Layer 2 敌人
			#set_collision_mask_value(2, true)  # Layer 2 敌人
		"村民":
			set_collision_layer_value(4, true)  # Layer 4 交互（村民是可交互对象）
	# 第三步：统一遮罩只检测地图层（Layer 1）
	set_collision_mask_value(1, true)  # 遮罩只勾选地图层
func _physics_process(间隔: float) -> void:
	if Engine.is_editor_hint():
		return
	if 血条显示>0:
		血条显示-=间隔
		if 血条显示<0:血条显示=0
	移动更新(间隔)
	检查回复更新(间隔)
	move_and_slide()
	if position.y > 地图外判断+1000:
		回到出生点()
	#if not velocity.is_zero_approx():
		#更新位置状态()
var 每秒回血: float = 0
var 回血值=0
var 每秒回蓝: float = 0
var 回蓝值=0
var 每秒回盾: float = -1
var 回盾值=0
func 检查回复更新(间隔: float):
	回血值+=间隔*每秒回血
	if 回血值>=1:
		修改属性值("生命",回血值)
		回血值=0
	回蓝值+=间隔*每秒回蓝
	if 回蓝值>=1:
		修改属性值("魔法",回蓝值)
		回蓝值=0
	回盾值+=间隔*每秒回盾
	if 回盾值>=1:
		修改属性值("护盾",回盾值)
		回盾值=0
##当前帧发生移动时调用
func 更新位置状态():
	pass
func 移动更新(间隔: float) -> void:
	velocity.y+=间隔*重力加速度
	
func 任意被按下(按键数组: Array) -> bool:
	for 按键名 in 按键数组:
		if Input.is_action_pressed(按键名):
			return true
	return false
func 回到出生点() -> void:
	if 实体名称=="玩家":
		position = 出生点#重置玩家位置到出生点
		velocity = Vector2.ZERO#重置速度
	else :
		queue_free()
##Control的gui_input
func 点击检查(事件: InputEvent) -> void:
	if 事件 is InputEventMouseButton:# 检查左键按下
		if 事件.button_index == MOUSE_BUTTON_LEFT and 事件.pressed:
			if 血条显示>=0:# 如果血条非长期显示设为3秒
				血条显示 = 3.0  # 点击后血条显示3秒
				print("点击非玩家实体，血条显示时长设为3秒")
			else:
				print("点击玩家实体，血条始终显示（无需修改）")
@onready var 受伤粒子效果: GPUParticles2D = %"受伤粒子"
# 补充：受伤害时显示血条
func 受伤害(伤害值: float):
	if 伤害值<=0:return
	if 血条显示>=0:血条显示=3#显示3秒血条
	# 扣血逻辑（省略）
	生命值 -= 伤害值
	计划.地图.伤害跳字.emit(-伤害值,血量.global_position+Vector2(0,-30),"生命")
	if 受伤粒子效果:
		var 特效克隆:GPUParticles2D=受伤粒子效果.duplicate()
		add_child(特效克隆)
		特效克隆.amount=攻击力转粒子数量(伤害值)
		特效克隆.emitting=true
		特效克隆.finished.connect(特效克隆.queue_free)
	if 死亡检查():
		状态机.dispatch("状态切换死亡")
	else :
		状态机.受击检查()#如果不再受击保护器内则进入受击状态
func 攻击力转粒子数量(受到攻击力: float) -> int:
	# 最低粒子数
	var 最小粒子 = 5
	# 最大粒子数
	var 最大粒子 = 100
	# 基准攻击力（10攻击力对应5粒子）
	var 基准攻击 = 10.0
	if 受到攻击力 <= 基准攻击:
		return 最小粒子
	# 核心：用 根号2 计算指数，实现翻倍+10
	var 指数 = log(受到攻击力 / 基准攻击) / log(sqrt(2))
	var 粒子数 = 最小粒子 + 指数 * 1
	# 限制范围 5 ~ 100
	return clamp(round(粒子数), 最小粒子, 最大粒子)
func 死亡检查(死亡返回真:bool=true)->bool:
	var 返回结果:bool=生命值<=0
	if not 死亡返回真:
		返回结果=not 返回结果
	return 返回结果
##修改属性值可以处理不需要考虑增益的情况会更新血条显示
func 修改属性值(属性类型:String,调整量:float):
	if 调整量==0:
		return
	match 属性类型:
		"生命":
			if 生命值<最大生命 or (调整量<0 and 生命值>0):
				if 血条显示>=0:血条显示=1
				生命值+=调整量
			else :return
		"魔法":
			if 魔法值<最大魔法 or (调整量<0 and 魔法值>0):
				if 血条显示>=0:血条显示=1
				魔法值+=调整量
			else :return
		"护盾":
			if 护盾值<最大护盾 or (调整量<0 and 护盾值>0):
				if 血条显示>=0:血条显示=1
				护盾值+=调整量
			else :return
	计划.地图.伤害跳字.emit(调整量,血量.global_position+血量.size*Vector2(0.5,-1),属性类型)

func 生成攻击(子弹类型="近战攻击",武器类型="抓痕"):
	var 子弹数据:Dictionary=子弹字典.get(子弹类型,{})
	if 子弹数据.has("场景"):
		var 子弹场景:游历子弹=子弹数据.场景.instantiate()
		if 实体类型=="怪物":
			子弹场景.碰撞目标层=5
		elif 实体类型=="玩家":
			子弹场景.碰撞目标层=2
		子弹场景.伤害值=攻击力
		子弹场景.武器名称=武器类型
		if 子弹类型=="近战攻击":
			if 子弹场景 is 游历子弹_近战攻击:
				子弹场景.击退力=Vector2(-50,-50)*近战攻击容器.scale
			近战攻击容器.add_child(子弹场景)
		elif 子弹类型=="远程攻击":
			if not 计划.地图.子弹管理器:
				return
			if 子弹场景 is 游历子弹_远程攻击:
				子弹场景.global_position=近战攻击容器.global_position
				子弹场景.最大飞行距离=最大攻击距离
				子弹场景.子弹速度=1000
				子弹场景.子弹方向=Vector2(1,0)#碰撞范围.scale
				计划.地图.子弹管理器.add_child(子弹场景)
func 方向更新(实体:Node2D):
	var 方向:int=sign(实体.position.x-position.x)
	方向更新_指定(方向)
func 方向更新_指定(方向:int=1):
	近战攻击容器.scale=Vector2(-方向,1)
	近战攻击容器.position=Vector2(方向*近战攻击距离*0.5,-75)
	if 动画节点:
		动画节点.面向调整(方向>0)
	
