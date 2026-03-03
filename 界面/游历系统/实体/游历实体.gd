@tool
extends CharacterBody2D
class_name 游历实体
var 卡片素材:Dictionary={
	"玩家":{
		"场景":preload("res://界面/插件/实体/玩家.tscn"),
		"范围":Vector2(65,140),
		"偏移":Vector2(0,-75),
		"血条偏移":Vector2(-70,-186),
		"代码":游历实体_玩家},
	"村民":{
		"场景":preload("res://界面/插件/实体/实体卡片.tscn"),
		"范围":Vector2(65,140),
		"偏移":Vector2(0,-75),
		"血条偏移":Vector2(-70,-186)},}
@export var 实体名称: String="玩家"
@export_enum("玩家","队友","怪物","村民") var 实体类型: String="玩家"
## 生命值：修改时仅更新血量进度条
@export var 生命值: float = 100:
	set(值):
		生命值 = clamp(值, 0, 最大生命)  # 限制数值范围
		# 仅更新血量进度条（最小化更新）
		if is_inside_tree() and 血量 and 血量.is_inside_tree():
			血量.value = 生命值
## 最大生命值：修改时仅更新血量进度条的最大值+同步当前生命值
@export var 最大生命: float = 100:
	set(值):
		最大生命 = max(值, 0)  # 确保最大值不为负
		生命值 = clamp(生命值, 0, 最大生命)  # 修正当前生命值不超限
		# 仅更新血量进度条的最大值和当前值
		if is_inside_tree() and 血量 and 血量.is_inside_tree():
			血量.max_value = 最大生命
			血量.value = 生命值
## 护盾值：修改时仅更新护盾进度条
@export var 护盾值: float = 0:
	set(值):
		护盾值 = clamp(值, 0, 最大护盾)
		if is_inside_tree() and 护盾 and 护盾.is_inside_tree():
			护盾.value = 护盾值
## 最大护盾：修改时仅更新护盾进度条的最大值+同步当前护盾值
@export var 最大护盾: float = 0:
	set(值):
		最大护盾 = max(值, 0)
		护盾值 = clamp(护盾值, 0, 最大护盾)
		if is_inside_tree() and 护盾 and 护盾.is_inside_tree():
			护盾.max_value = 最大护盾
			护盾.value = 护盾值
## 魔法值：修改时仅更新魔法进度条
@export var 魔法值: float = 0:
	set(值):
		魔法值 = clamp(值, 0, 最大魔法)
		if is_inside_tree() and 魔法 and 魔法.is_inside_tree():
			魔法.value = 魔法值
## 最大魔法：修改时仅更新魔法进度条的最大值+同步当前魔法值
@export var 最大魔法: float = 0:
	set(值):
		最大魔法 = max(值, 0)
		魔法值 = clamp(魔法值, 0, 最大魔法)
		if is_inside_tree() and 魔法 and 魔法.is_inside_tree():
			魔法.max_value = 最大魔法
			魔法.value = 魔法值
##不为0时显示血条
@export var 血条显示: float = 0:
	set(值):
		血条显示 = 值
		更新血条显示状态()
@onready var 血量: ProgressBar = %血量
@onready var 护盾: ProgressBar = %护盾
@onready var 魔法: ProgressBar = %魔法
@onready var 碰撞范围: CollisionShape2D = %碰撞范围
@onready var 动画节点: Control = $动画
var 重力加速度:float=ProjectSettings.get("physics/2d/default_gravity") as float
var 速度:float=500.0
var 跳跃高度:float=-870
var 地图外判断:int=1100#Y大于这个值视为掉出地图
var 出生点:Vector2
func _ready():
	if Engine.is_editor_hint():
		var 编辑器名: Label = %编辑器名
		编辑器名.text=实体名称
		return
	初始化实体()
	更新进度条()
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
	# 3. 获取该角色对应的配置数据
	var 角色配置: Dictionary = 卡片素材[实体类型]
	# 5. 新建RectangleShape2D并设置尺寸
	var 判定范围区: RectangleShape2D = RectangleShape2D.new()
	判定范围区.size = 角色配置.get("范围",Vector2(65,140))  # 从字典读取尺寸
	碰撞范围.shape = 判定范围区          # 设置新的Shape
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
			if 动画节点 is 实体卡片:
				动画节点.传入数据(实体名称,计划.表格.道具贴图(实体名称),实体类型)
		add_child(动画节点,false,INTERNAL_MODE_FRONT)
	else :print("错误：无法加载【%s】的动画场景：%s" % [实体名称, 角色配置["场景"]])
	出生点=position
	if 血量:
		血量.position=角色配置.get("血条偏移",Vector2(-70,-186))
	血条显示=0
	设置碰撞层和遮罩()
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
	move_and_slide()
	if position.y > 地图外判断:
		回到出生点()
	if not velocity.is_zero_approx():
		更新位置状态()
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
# 补充：受伤害时显示血条
func 受伤害(伤害值: float):
	# 非玩家受伤害时也显示3秒血条
	if 血条显示>=0:血条显示=3
	# 扣血逻辑（省略）
	生命值 -= 伤害值
	if 生命值<=0:
		死亡逻辑()
func 死亡逻辑():
	match 实体类型:
		"玩家":
			pass
		_:queue_free()
