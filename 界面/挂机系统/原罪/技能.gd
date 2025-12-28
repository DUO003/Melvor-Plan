@tool
extends Button
class_name 技能节点
@export var 技能文本:String="默认技能"
@export var 技能层级:int=-1:
	set(值):
		技能层级=值
		position.y=-40+-150*技能层级
var 进度:float=0.5
var 技能等级=0
var 技能最大等级=1
var 前置技能=[]
@onready var 标签: Label = %标签
@onready var 名称: Label = %名称
var 纹理:Texture2D
func _ready() -> void:
	position.y=-40+-150*技能层级
	text=""
	名称.text=技能文本
	名称.visible=false
	custom_minimum_size=Vector2(120,120)
	size=custom_minimum_size
	if Engine.is_editor_hint():
		return
	纹理=计划.技能树.数据技能树(技能文本,"图标代码")
	技能最大等级=计划.技能树.数据技能树(技能文本,"最大等级")
	前置技能=计划.技能树.数据技能树(技能文本,"前置技能")
	更新等级标签()
	pressed.connect(技能点击)
	计划.更新_UI.connect(更新等级标签)
	mouse_entered.connect(func():名称.visible=true)
	mouse_exited.connect(func():名称.visible=false)
func 技能点击():
	计划.技能点击信号.emit(技能文本)
func 更新等级标签():
	if Engine.is_editor_hint():
		标签.text="标签"
		return
	技能等级=计划.技能树.数据技能树(技能文本,"等级")
	处理样式()
	if 技能等级>=1:标签.visible=true
	else :标签.visible=false
	if 技能等级 is int:
		标签.text="lv:%d"%技能等级
	else :标签.text="错误"
	for 技能 in 前置技能:
		var 前置技能等级=计划.技能树.数据技能树(技能,"等级")
		if 前置技能等级<1:
			self_modulate=Color(1,1,1,0.6)
			return
	self_modulate=Color(1,1,1,1)
func 处理样式() -> void:
	var 样式 = get_theme_stylebox("normal").duplicate(true)# 2. 复制样式模板
	样式.样式数组[2].texture = 纹理# 3. 修改复制后的基础样式（统一替换图片）
	if 技能等级>=1:# 4. 根据解锁状态设置调制颜色（白色/暗灰色）
		样式.样式数组[2].modulate_color =Color(1, 1, 1)
	else :
		样式.样式数组[2].modulate_color =Color(0.2, 0.2, 0.2)
	样式.样式数组[1].margin_top=-110+int(100*(技能等级*1.0/max(1,技能最大等级)))
	for state in ["normal", "pressed", "hover", "focus"]:# 5. 批量将修改后的基础样式，赋值给所有需要同步的状态
		add_theme_stylebox_override(state, 样式)
