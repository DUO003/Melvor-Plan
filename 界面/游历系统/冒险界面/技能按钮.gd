@tool
extends Panel
class_name 梅游历技能按钮
@onready var 冷却动画: Panel = %冷却动画
@onready var 技能图标: TextureRect = $技能图标
@onready var 技能冷却文本: Label = $技能冷却
@onready var 技能点击: Button = $技能点击
##技能真实的冷却秒数
@export var 技能冷却:float=10
##技能冷却百分比0为已冷却,1为刚进入冷却,由外部更新
@export var 冷却条进度:float=0:
	set(值):
		冷却条进度 = 值
		更新动画()
##技能贴图
@export var 技能贴图:Texture2D=null:
	set(值):
		技能贴图 = 值
		更新贴图()
##技能名称
@export var 技能资源:梅技能配置=null
@export var 绑定实体:游历实体=null
var 样式:扩展的扁平样式框=null
func _ready() -> void:
	if not 冷却动画:
		print("找不到动画")
		return
	样式=冷却动画.get_theme_stylebox("panel").duplicate()
	冷却动画.add_theme_stylebox_override("panel",样式)
	更新动画()
	技能点击.pressed.connect(点击事件)
func 点击事件():
	if 绑定实体:
		绑定实体.技能按下检查(技能资源)
func 更新贴图():
	if not 技能图标:
		return
	技能图标.texture=技能贴图
func 更新动画():
	if not 样式 or not 冷却动画:
		return
	样式.margin_bottom=int((size.y-样式.border_width_top-样式.border_width_bottom)*(冷却条进度-1))
	if 冷却条进度<=0:
		技能冷却文本.text=""
	else :
		技能冷却文本.text="%.1f"%(技能冷却*冷却条进度)
