extends CanvasLayer
func _ready():
	if 梅存档格式.单例.启用测试:
		var 测试功能=%"测试功能"
		var 测试默认显示:bool=false
		if OS.has_feature("editor_runtime"):
			测试默认显示=true
		测试功能.visible=计划.窗口状态管理("测试","显示",测试默认显示)
		%"显示测试".visible=true
		%"显示测试".button_pressed=测试功能.visible
		%"显示测试".pressed.connect(func():
			测试功能.visible= not 测试功能.visible
			计划.窗口状态管理("测试","显示",null,测试功能.visible))
	else :
		%"显示测试".visible=false
	%"跳转设置".pressed.connect(func():
		计划.切换场景("设置界面")
		visible=false)
	%"保存关闭".pressed.connect(func():
		await 计划.保存存档("手动存档")
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
