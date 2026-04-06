extends CanvasLayer
#@export var 相关按钮:Dictionary[String,Node]
@onready var 跳转设置: Button = %跳转设置
@onready var 保存关闭: Button = %保存关闭
@onready var 取消: Button = %取消
@onready var 显示测试: CheckButton = %显示测试
@onready var 测试功能: CanvasLayer = %测试功能
@onready var 动画: AnimationPlayer = %动画_暂停界面

func _ready():
	visible=false
	计划.显示暂停界面.connect(显示暂停界面)
	if 梅存档格式.单例.启用测试:
		var 测试默认显示:bool=false
		if OS.has_feature("editor_runtime"):
			测试默认显示=true
		测试功能.visible=计划.窗口状态管理("测试","显示",测试默认显示)
		显示测试.visible=true
		显示测试.button_pressed=测试功能.visible
		显示测试.pressed.connect(func():
			测试功能.visible= not 测试功能.visible
			计划.窗口状态管理("测试","显示",null,测试功能.visible))
	else :
		显示测试.visible=false
	跳转设置.pressed.connect(func():
		计划.切换场景("设置界面")
		visible=false)
	保存关闭.pressed.connect(func():
		await 计划.保存存档("手动存档")
		get_tree().quit())
	取消.pressed.connect(func():切换暂停())
func 显示暂停界面(状态:bool=true):
	if 状态:	
		visible=状态
		动画.play("进入")
	else :
		动画.play("关闭")
		await 动画.animation_finished
		visible=状态
func _input(event: InputEvent):
	# 检测 ESC 键按下（对应 InputMap 中的 "ui_cancel" 动作）
	if event.is_action_pressed("显示控制台"):
		切换暂停()
		# 这里可以调用暂停界面的显示逻辑，比如：
		# 切换暂停状态()
func 切换暂停():
	visible=not visible
