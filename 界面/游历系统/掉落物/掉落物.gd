extends RigidBody2D
class_name 掉落物实例

# 物品核心数据
var 物品名称: String = ""
var 物品数量: int = 1
var 不再获取: bool = false  # 特殊销毁标记（岩浆/深渊等）
var 已拾取:bool=false
var 物品类型: String = "标准物品"
var 自定义参数: Dictionary = {}
var 尺寸:int=64
# 节点引用
@onready var 碰撞形状: CollisionShape2D = $碰撞形状
@onready var 图片: Sprite2D = $图片
@onready var 文本: Label = $文本

# 缓存区
var _待初始化数据: Dictionary = {}

# ====================== 初始化（外部调用）======================
func 初始化数据(
	名称: String,
	数量: int,
	目标像素尺寸: Vector2,
	生成位置: Vector2,
	物品贴图: Texture2D,
	类型: String = "标准物品",
	参数: Dictionary = {}):
	_待初始化数据 = {
		"名称": 名称,
		"数量": 数量,
		"目标尺寸": 目标像素尺寸,
		"位置": 生成位置,
		"贴图": 物品贴图,
		"类型": 类型,
		"参数": 参数}
func _process(_间隔):
	# 强制抵消父节点的旋转，让文本永远正立
	文本.rotation = -global_rotation
	# 保持文本跟随位置（可选，更稳定）
	文本.global_position = global_position + Vector2(0, -尺寸) + Vector2(文本.size.x*-0.5, -文本.size.y)
# ====================== 自动执行 ======================
func _ready():
	# 碰撞层设置
	collision_layer = 1 << 3
	collision_mask = (1 << 0) | (1 << 3)
	
	# 物理阻尼
	linear_damp = 1.2
	angular_damp = 1.5
	mass = 1
	gravity_scale = 1.0

	# 自动初始化
	if not _待初始化数据.is_empty():
		_执行真正初始化(_待初始化数据)
		_待初始化数据 = {}

# ====================== 真正初始化 ======================
func _执行真正初始化(数据: Dictionary):
	# 基础赋值
	物品名称 = 数据["名称"]
	物品数量 = 数据["数量"]
	position = 数据["位置"]
	物品类型 = 数据["类型"]
	自定义参数 = 数据["参数"]
	var 目标像素尺寸 = 数据["目标尺寸"]
	var 物品贴图 = 数据["贴图"]
	
	# 设置图片
	图片.texture = 物品贴图
	
	# 自动缩放
	var 原始贴图尺寸 = 物品贴图.get_size()
	if 原始贴图尺寸.x > 0 && 原始贴图尺寸.y > 0:
		图片.scale = 目标像素尺寸 / 原始贴图尺寸
	
	# 碰撞形状
	var 圆形形状: CircleShape2D = CircleShape2D.new()
	尺寸=目标像素尺寸.x / 2
	if 圆形形状 != null:
		圆形形状.radius = 尺寸
	碰撞形状.shape=圆形形状
	# 随机反弹
	apply_impulse(Vector2(
		randf_range(-70, 70),
		randf_range(-140, -60)
	))

	# ========== 新功能：设置文本 ==========
	文本.text = 物品名称 + "×" + str(物品数量)

# ====================== 【新功能】拾取 + 特效 ======================
func 尝试拾取():
	if 已拾取:
		return
	
	# 1. 先获得物品
	已拾取 = true
	计划.获得物品语法糖(物品名称, 物品数量,物品类型,自定义参数)
	
	# 2. 关闭碰撞
	碰撞形状.set_deferred("disabled", true)
	collision_layer = 0
	collision_mask = 0
	
	# 3. 播放向上飘移动画（0.5秒 上移60px + 渐隐）
	创建拾取特效()

# ====================== 飘移动画 ======================
func 创建拾取特效():
	linear_velocity = Vector2.ZERO  # 清空移动速度
	angular_velocity = 0.0  # 清空旋转速度
	gravity_scale=0
	# 动画时长
	var 时长:float = 1
	# 补间动画
	var 补间:Tween = create_tween()
	补间.set_ease(Tween.EASE_OUT)
	
	# 向上飘 + 渐隐
	补间.tween_property(self, "position:y", position.y - 180, 时长)
	补间.tween_property(self, "modulate:a", 0.0, 时长)
	
	# 结束销毁
	补间.finished.connect(queue_free)

# ====================== 退出树时自动拾取 ======================
func _exit_tree():
	if not 不再获取 and not 已拾取:
		if 文本:
			计划.语法糖通知("自动拾取:"+文本.text)
		计划.获得物品语法糖(物品名称, 物品数量,物品类型,自定义参数)
