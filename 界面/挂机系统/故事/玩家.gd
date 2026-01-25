extends CharacterBody2D
#class_name 
var 重力加速度:float=ProjectSettings.get("physics/2d/default_gravity") as float
var 玩家速度:float=500.0
var 玩家跳跃高度:float=-600
@onready var 玩家图片: 玩家卡片 = $玩家卡片
var 动画: AnimationPlayer
var 出生点:Vector2
var 地图外判断:int=1100#Y大于这个值视为掉出地图
func _ready() -> void:
	出生点=position
	动画=玩家图片.动画
var 二段跳:bool
var 松开跳跃:bool
func _physics_process(间隔: float) -> void:
	var 移动:float=Input.get_axis("移动_左","移动_右")
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

# 封装回到出生点的逻辑，便于复用
func 回到出生点() -> void:
	# 1. 重置玩家位置到出生点
	position = 出生点
	# 2. 重置玩家速度（避免回到出生点后仍有下落/移动速度）
	velocity = Vector2.ZERO
	# 可选：添加提示或音效
	print("玩家掉出地图，已回到出生点！")
