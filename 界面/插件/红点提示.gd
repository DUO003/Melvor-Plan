#@tool
extends Control
class_name 红点场景
@export var 红点条目: String="默认红点"
@export var 红点数量=1
var 红点文本:Label
var 点击逻辑:Callable=func():print("点击红点",红点文本)
func _ready():
	if Engine.is_editor_hint():
		show()
		return
	红点文本=$"定位点/红点/数量"
	计划.更新红点.connect(_更新红点)
	$"按钮".pressed.connect(点击逻辑)
	_更新红点()
func _更新红点(指定更新=null):
	if 指定更新==null or 指定更新==红点条目:
		获取红点()
		if 红点数量==0:
			hide()
			return
		else :
			show()
		if 红点数量==1:
			红点文本.text=""
			return
		红点文本.text=str(红点数量)
func 获取红点():
	红点数量=计划.红点.获取红点状态(红点条目)
