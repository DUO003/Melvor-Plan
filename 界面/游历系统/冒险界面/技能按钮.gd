@tool
extends Panel
class_name 梅游历技能按钮
@onready var 冷却动画: Panel = %冷却动画
@onready var 技能图标节点: TextureRect = $技能图标
@onready var 技能冷却文本: Label = $技能冷却
@onready var 技能点击: Button = $技能点击
##技能冷却百分比0为已冷却,1为刚进入冷却
@export var 冷却条进度:float=0:
	set(值):
		if not 冷却条进度==值:
			冷却条进度 = 值
			更新动画()
##技能图标
@export var 技能图标:Texture2D=null:
	set(值):
		技能图标 = 值
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
func _physics_process(_间隔: float) -> void:
	if 技能资源:
		var 时间戳:float=Time.get_unix_time_from_system()
		if 技能资源.技能释放时间戳+技能资源.冷却时间>时间戳:
			冷却条进度=((时间戳-技能资源.技能释放时间戳)/技能资源.冷却时间)
		else :
			冷却条进度=0
func 绑定事件(实体:游历实体,序号:int):
	if 实体:
		绑定实体=实体
		冷却条进度=0
		if 实体.技能配置.size()>序号:
			var 资源:梅技能配置=实体.技能配置[序号]
			技能资源=资源
			技能图标=技能资源.技能图标
		else :
			技能资源=null
			技能图标=null
func 点击事件():
	if 技能资源 and 绑定实体 :
		if 技能资源.技能可用检查(绑定实体):
			技能资源.释放技能(绑定实体)
	else :
		print("技能绑定参数错误")
func 更新贴图():
	if not 技能图标节点:
		return
	技能图标节点.texture=技能图标
func 更新动画():
	if not 样式 or not 冷却动画:
		return
	var 冷却:float=1
	if  技能资源:冷却=技能资源.冷却时间
	样式.margin_bottom=int((size.y-样式.border_width_top-样式.border_width_bottom)*(冷却条进度-1))
	if 冷却条进度<=0:
		技能冷却文本.text=""
	else :
		技能冷却文本.text="%.1f"%(冷却*(1-冷却条进度))
