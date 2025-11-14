extends Button
var 展开=false
func _ready():
	展开界面()
	pressed.connect(func():
		展开=not 展开
		展开界面())
	%"暂停界面".visible=false
	$"暂停".pressed.connect(func():%"暂停界面".visible=true)
func 展开界面():
	if OS.has_feature("editor_runtime"):
		$"测试".visible=展开
	$"存档".visible=展开
	if 展开:
		text=">"
	else :
		text="<"
