@tool
extends HSlider
var 标签:Label
@export var 标签文本:String="提交%d次"
@export var 零点标签:String="最大提交"
@export_enum("更新玩法","更新_UI")var 信号选项:String="更新_UI"
@export var 文本偏移:Vector2=Vector2(-250,0):
	set(值):
		文本偏移=值
		标签=$"标签" as Label
		if 标签:标签.position=文本偏移
		else :print("标签未获取")
var 信号字典:Dictionary[String,Signal]
func _ready() -> void:
	if Engine.is_editor_hint():return
	信号字典={
	"更新玩法":计划.更新玩法,
	"更新_UI":计划.更新_UI}
	标签=$"标签"
	标签.position=文本偏移
	drag_ended.connect(模式显示)
	await get_tree().process_frame
	模式显示(true,false)
	更新刻度()
func 更新刻度():
	tick_count=int((max_value-min_value+step)/step)
func 模式显示(修改:bool=true,信号:bool=true):
	if 修改:
		if value<1:标签.text=零点标签
		else :标签.text=标签文本%int(value)
	if 信号:信号字典[信号选项].emit()
