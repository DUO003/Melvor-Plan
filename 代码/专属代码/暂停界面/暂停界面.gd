extends CanvasLayer
func _ready():
	%"跳转设置".pressed.connect(func():
		print($"..".初始界面)
		if $"..".初始界面=="任务窗口" and 初始化.节点有效性检查("任务界面"):
			初始化.节点["任务界面"].切换到设置()
		else :
			初始化.跳转设置=true
			初始化.切换场景(null,"任务窗口")
		visible=false
		)
	%"保存关闭".pressed.connect(func():
		初始化.保存存档("关闭游戏")
		get_tree().quit())
	%"取消".pressed.connect(func():切换暂停())
	
func _input(event: InputEvent):
	# 检测 ESC 键按下（对应 InputMap 中的 "ui_cancel" 动作）
	if event.is_action_pressed("显示控制台"):
		切换暂停()
		# 这里可以调用暂停界面的显示逻辑，比如：
		# 切换暂停状态()
func 切换暂停():
	visible=not visible
