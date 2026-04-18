extends Button
func _ready() -> void:
	$"../奖励悬浮面板".奖励显示变化.connect(同步显示)
	pressed.connect(清空)
	
func 同步显示(显示):
	visible=显示
func 清空():
	计划.语法糖奖励显示([],"",0,true)
func _input(按键: InputEvent) -> void:
	# 只在可见时生效
	if not visible:
		return
	# 核心：只拦截【键盘/手柄 按下动作】，过滤鼠标移动/点击/滚轮/松开
	if 按键 is InputEventKey and 按键.pressed:
		# 任意键按下执行逻辑
		清空()
		get_viewport().set_input_as_handled()
