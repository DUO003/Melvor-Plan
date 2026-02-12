@tool  # 启用编辑器内预览
extends Control
@export_enum("挂机", "木料", "矿城", "手工", "游历", "职业", "召唤") var 系统 = "手工"
@export var 玩法:String="合成":
	set(值):
		玩法=值
		if Engine.is_editor_hint():_更新_UI()
var 等级=100
@onready var 玩法文本: Label = %玩法文本
@onready var 系统文本: Label = %系统文本
@onready var 文本数值:RichTextLabel = %文本数值
func _ready() -> void:
	_更新_UI()
	if Engine.is_editor_hint():
		return  # 直接返回，不执行后续可能出错的代码
	计划.connect("更新_UI", Callable(self, "_更新_UI"))
	文本数值.size.y=100
	%"精通进度条".custom_minimum_size.y=50
	%"熟练进度条".custom_minimum_size.y=50
	%"熟练进度条".position.y=50
	custom_minimum_size.y=100
	position=Vector2(0,0)
	文本数值.position.y=0
	await get_tree().process_frame
	_更新_UI()
func _更新_UI():
	if not has_node("玩法文本") or not is_instance_valid(玩法文本):
		return
	if Engine.is_editor_hint():
		玩法文本.text= "%s"%[玩法]
		系统文本.text= "%s LV:%d"%[系统,等级]
		文本数值.position.x=文本节点宽度(系统文本).x+20
		文本数值.size.x=size.x-文本数值.position.x
		%精通进度条.max_value=100
		%精通进度条.value=33
		%熟练进度条.max_value=100
		%熟练进度条.value=66
		文本数值.text="熟练:\r精通:"
	else :
		等级=计划.数据系统(系统,"等级")
		if 玩法==系统:
			玩法文本.text= ""
		else :
			玩法文本.text= "%s"%[玩法]
		系统文本.text= "%s LV:%d"%[系统,等级]
		文本数值.position.x=文本节点宽度(系统文本).x+20
		文本数值.size.x=size.x-文本数值.position.x
		var 精通=计划.数据系统(系统,"精通")
		var 精通上限=计划.数据系统(系统,"精通上限")
		var 熟练=计划.数据系统(系统,"熟练")
		var 熟练上限=计划.结算升级(系统,计划.玩法枚举.无,"null",true)
		var 升级检查:Dictionary=计划.梅存档[系统].get("升级检查",{})
		var 增益文本=""
		if 升级检查.size()>=1:
			增益文本="加成%d%%"%(升级检查.size()*5)
		文本数值.text="[img=40x40]%s[/img]熟练%s:%d/%d\r[img=40x40]%s[/img]精通:%d/%d"%[
			计划.表格.道具贴图("熟练").resource_path,增益文本,熟练,熟练上限,
			计划.表格.道具贴图("精通").resource_path,精通,精通上限]
		if 熟练上限==-1:
			熟练=0
			熟练上限=1
		%熟练进度条.max_value=熟练上限
		%精通进度条.max_value=精通上限
		%熟练进度条.value=熟练
		%精通进度条.value=精通
		#print(%精通进度条.value,"/",%精通进度条.max_value)

func 文本节点宽度(文本节点,对齐方式:HorizontalAlignment=HORIZONTAL_ALIGNMENT_LEFT)->Vector2:
	if 文本节点 is RichTextLabel or 文本节点 is Label:
		var 字体:Font
		var 文本内容:String=文本节点.text
		var 字体大小:int
		if 文本节点 is RichTextLabel:
			字体=文本节点.get_theme_font("normal_font")
			字体大小=文本节点.get_theme_font_size("normal_font_size")
		else :
			字体=文本节点.get_theme_font("font")
			字体大小=文本节点.get_theme_font_size("font_size")
		return 字体.get_string_size(文本内容,对齐方式, -1,字体大小)
	return Vector2(0,0)
