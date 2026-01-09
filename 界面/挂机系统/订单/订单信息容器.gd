extends ScrollContainer
var 生成间隔:int=600
var 缓存订单节点:Array
func _ready() -> void:
	生成间隔=计划.订单参数["生成间隔"]
	计划.过去一秒.connect(更新计时)
	计划.更新_UI.connect(更新UI)
	
func 更新计时():
	计划.处理订单更新()
	更新UI()
func 更新UI():
	var 剩余时间 = max(0,生成间隔 - 计划.数据订单("时间戳"))
	%"订单标题".text="刷新倒计时:%s\r通用提交:%d/%d"%[计划.格式化时间(剩余时间,2),计划.数据订单("订单数量"),计划.数据订单("订单上限")]
	if 缓存订单节点.size()<0:
		缓存订单节点=%"订单".get_children()
	for 订单 in 缓存订单节点:
		if 订单 is Panel:订单.更新UI()
