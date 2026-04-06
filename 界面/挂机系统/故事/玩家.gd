extends CharacterBody2D
class_name 大地图玩家
var 重力加速度:float=ProjectSettings.get("physics/2d/default_gravity") as float
var 玩家速度:float=500.0
var 玩家跳跃高度:float=-870
@onready var 按钮: Button = $按钮
@onready var 玩家图片: 实体卡片 = $玩家卡片
var 动画: AnimationPlayer
var 出生点:Vector2
var 地图外判断:int=1100#Y大于这个值视为掉出地图
@onready var 地图: 大地图管理 = $"../地图管理器"
func _ready() -> void:
	动画=玩家图片.动画
	玩家图片.z_index=-1
	按钮.visible=false
	计划.地图.更新_交互.connect(交互逻辑)
	按钮.pressed.connect(点击按钮)
	
var 二段跳:bool
var 松开跳跃:bool
var 自动前进目标:float
var 启用自动前进=false
var 当前位置方块=null
func _physics_process(间隔: float) -> void:
	var 控制按钮组: Array = ["移动_左", "移动_右", "移动_跳"]
	var 移动:float
	if 任意被按下(控制按钮组):
		启用自动前进=false
		移动=Input.get_axis("移动_左","移动_右")
		当前位置方块=null
	else :
		if 启用自动前进:
			当前位置方块=null
			var 玩家全局:float = global_position.x
			if 自动前进目标>玩家全局:
				移动=1
			else :
				移动=-1
			if abs(玩家全局-自动前进目标)<=10:
				#print(自动前进目标,"/",玩家全局)
				启用自动前进=false
		elif 当前位置方块==null:
			当前位置方块=地图.获取方块(global_position)
	velocity.x=move_toward(velocity.x,玩家速度*移动,50)
	velocity.y+=间隔*重力加速度
	if is_on_floor():
		if Input.is_action_just_pressed("移动_跳"):
			velocity.y=玩家跳跃高度
			二段跳=true
			松开跳跃=false
		if 移动==0.0:
			动画.play("待机")
		else :
			动画.play("移动")
	else :
		if Input.is_action_just_pressed("移动_跳"):
			if 松开跳跃 and 二段跳:
				velocity.y=玩家跳跃高度
				二段跳=false
		else :
			松开跳跃=true
	move_and_slide()
	if position.y > 地图外判断:
		回到出生点()
func 任意被按下(按键数组: Array) -> bool:
	for 按键名 in 按键数组:
		if Input.is_action_pressed(按键名):
			return true
	return false
# 封装回到出生点的逻辑，便于复用
func 回到出生点() -> void:
	# 1. 重置玩家位置到出生点
	position = 出生点
	# 2. 重置玩家速度（避免回到出生点后仍有下落/移动速度）
	velocity = Vector2.ZERO
	# 可选：添加提示或音效
	print("玩家掉出地图，已回到出生点！")
var 交互节点:交互功能区
func 交互逻辑(增加:bool,内容:String,节点:Node,强制:bool):
	#print("强制:",强制,内容)
	if 增加:
		按钮.text=内容
		按钮.visible=true
		if 节点 and 节点 is 交互功能区:
			交互节点=节点
	else :
		按钮.visible=false
		if 交互节点 and 节点 and 节点==交互节点:
			交互节点=null
	if 增加 and 强制:
		点击按钮()
func 点击按钮():
	if 交互节点:
		交互节点.执行方法()
