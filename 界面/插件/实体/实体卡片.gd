extends Control
class_name 实体卡片
@onready var 名称: Label = $"名称"
@onready var 动画: AnimationPlayer = $动画
@onready var 贴图: TextureRect = %贴图
@onready var 图片: Control = $图片
@export var 实体名称:String="默认实体"
@export var 实体贴图:Texture2D=null
@export_enum("玩家","队友","怪物","村民") var 实体类型: String="玩家"
func _ready() -> void:
	名称.text=实体名称
	贴图.texture=实体贴图
	var 样式:扩展的扁平样式框=get_theme_stylebox("panel").duplicate()
	match 实体类型:
		"玩家":图片.z_index=2
		_:图片.z_index=1
	样式.bg_color=Color("ab8538b5")
	add_theme_stylebox_override("panel",样式)
func 传入数据(新名称,新贴图,新类型):
	实体名称=新名称
	实体贴图=新贴图
	实体类型=新类型
