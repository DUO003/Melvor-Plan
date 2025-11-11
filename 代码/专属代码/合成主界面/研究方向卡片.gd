@tool  # 启用编辑器内预览
extends Panel
@export var 研究方向="长剑":
	set(值):
		研究方向=值
		_更新_UI()
@export var 总进度=20:
	set(值):
		总进度=值
		_更新_UI()
@export var 进度=0:
	set(值):
		进度=值
		_更新_UI()
var 按钮按下=false
func _ready() -> void:
	$Timer.timeout.connect(func():更新进度())
	$"按钮".button_down.connect(func():按钮按下=true)
	$"按钮".button_up.connect(func():按钮按下=false)
	_更新_UI()
func 更新进度():
	if 按钮按下:
		进度+=1
		_更新_UI()
func _更新_UI():
	$"精通条".value=进度
	$"精通条".max_value=总进度
	$"文本".text="研究方向:"+研究方向
	
