extends Button
var 展开=false
func _ready():
	展开界面()
	pressed.connect(func():
		展开=not 展开
		展开界面())
func 展开界面():
	$"测试".visible=展开
	$"存档/存档时间".visible=展开
	if 展开:
		text=">"
	else :
		text="<"
