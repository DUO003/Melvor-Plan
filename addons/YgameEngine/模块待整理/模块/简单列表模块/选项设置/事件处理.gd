extends Node
func _ready() -> void:
	#默认隐藏
	$"选项设置".hide()
	#进入设置选项
	$"首页菜单".确定选项.connect(func(选项):
		if $"首页菜单".get_item_text(选项)=="开始游戏":
			$"场景切换".切换.emit()
		if $"首页菜单".get_item_text(选项)=="设置选项":
			$"选项设置".grab_focus()#设置焦点
			$"选项设置".select(0)
			$"首页菜单".hide();
			$"选项设置".show();
		)
	#返回按钮
	$"选项设置/返回按钮".button_down.connect(func ():
		退出选项()
		)
func 退出选项():
	$"首页菜单".grab_focus()#设置焦点
	$"首页菜单".select(0)
	$"选项设置".hide();
	$"首页菜单".show();
func _input(event: InputEvent) -> void:
	if $"选项设置".visible:
		if event is InputEventKey:
			if event.keycode==4194305:
				退出选项()
				
