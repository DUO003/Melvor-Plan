extends Control
var 金币=初始化.梅存档["金币"]
func _ready():
	%物品栏选项卡.set_tab_title(0, "物品栏")
	初始化.connect("更新_UI", Callable(self, "_更新_UI"))
	_更新_UI()
func _更新_UI():
	if 金币>=0:
		%"金币节点".visible=true
	else :
		%"金币节点".visible=false
	%"金币文本".text="金币:"+str(金币)
