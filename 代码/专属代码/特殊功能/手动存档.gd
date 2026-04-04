extends Button
var 计时器:Timer
func _ready():
	gui_input.connect(func(按键信号): # 确保节点可以接收鼠标事件
		if 按键信号 is InputEventMouseButton and 按键信号.pressed:
			if GBIS.has_moving_item():
				GBIS.moving_item_service.安全清除移动物品()
			计划.保存存档("手动存档")
			计划.语法糖通知("手动存档成功可以安全关闭","手动存档")
			计划.emit_signal("更新_UI"))
	$"存档时间/时间".text="未存档"
	计时器=计划.创建计时器(1,func():更新显示())
	计划.connect("更新_UI",func():更新显示())
func 更新显示():
	if 计划.存档时间戳==-1:
		$"存档时间/时间".text="未存档"
		return
	var 总秒数=Time.get_unix_time_from_system()-计划.存档时间戳
	if 总秒数>60:
		$"存档时间/时间".text=计划.格式化时间(总秒数)+"前"
	elif 总秒数>3600:
		$"存档时间/时间".text="大于1小时"
	elif 总秒数<1:
		$"存档时间/时间".text="已保存"
	else :
		$"存档时间/时间".text=计划.格式化时间(总秒数)+"秒前"
func _exit_tree():
	if 计时器:
		计时器.queue_free()
