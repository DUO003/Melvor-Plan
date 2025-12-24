extends ScrollContainer
var 生成间隔:int=600
var 订单更新计时器: Timer=null
func _ready() -> void:
	生成间隔=计划.订单参数["生成间隔"]
	计划.过去一秒.connect(更新计时)
	计划.更新_UI.connect(更新UI)
	更新UI()
func _exit_tree() -> void:
	if not 订单更新计时器==null:
		订单更新计时器.queue_free()
func 更新计时():
	var 剩余时间 = max(0,生成间隔 - 计划.数据订单("时间戳"))
	%"订单标题".text="刷新倒计时:"+计划.格式化时间(剩余时间,2)
func 更新UI():
	更新计时()
	for 订单 in %"订单".get_children():
		if 订单 is Panel:订单.更新UI()

func 处理订单更新():
	var 下次检查间隔: int = 计划.处理订单更新()
	订单更新计时器 =计划.创建计时器(下次检查间隔,func():处理订单更新(),{"是否循环": false})
	计划.更新_UI.emit()
