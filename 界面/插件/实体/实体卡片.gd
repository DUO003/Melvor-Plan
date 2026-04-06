@tool
extends Control
class_name 实体卡片
@onready var 名称: Label = $背景/名称
@onready var 动画: AnimationPlayer = $动画
@onready var 贴图: TextureRect = %贴图
@onready var 图片: Control = $背景/图片
@export var 实体名称:String="默认实体"
@export var 实体贴图:Texture2D=null
@export var 面向反转:bool=true
@onready var 背景: Panel = $背景
@export_enum("玩家","队友","怪物","村民") var 实体类型: String="玩家"
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	名称.text=实体名称
	贴图.texture=实体贴图
	var 样式:扩展的扁平样式框=背景.get_theme_stylebox("panel").duplicate()
	match 实体类型:
		"玩家":图片.z_index=2
		_:图片.z_index=1
	样式.bg_color=Color("ab8538b5")
	背景.add_theme_stylebox_override("panel",样式)
	图片.pivot_offset_ratio = Vector2(0.5, 0.5)
	面向调整(true)
func 传入数据(新名称:String="",新贴图:Texture2D=null,新类型:String="玩家"):
	if not 新名称=="":
		实体名称=新名称
	if 新贴图:
		实体贴图=新贴图
	实体类型=新类型
func 面向调整(向左看: bool):
	# 方向：向左=1，向右=-1
	var 方向 = 1 if 向左看 else -1
	# 反转开关
	if 面向反转:方向 *= -1
	# 统一设置轴心（只需要设置一次，也可以移到_ready里）
	图片.scale.x = 方向
