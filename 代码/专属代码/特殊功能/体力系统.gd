extends Control
class_name 体力插件
var 固定文本
var 体力上限:int=240
var 体力值:int=100
var 体力恢复速度:int=计划.体力恢复速度
var 恢复量:int=计划.恢复量
var 计时器:Timer=null
func _ready() -> void:
	%"扩展内容".visible=false
	%"触发显示范围".mouse_entered.connect(生成动态文本)
	%"触发显示范围".mouse_exited.connect(结束更新)
	计划.connect("更新_UI", Callable(self, "_更新_UI"))
	_更新_UI()
func _更新_UI():
	体力上限=计划.数据体力("体力上限")
	体力值=计划.数据体力("体力")
	%"体力值".max_value=体力上限
	%"体力值".value=体力值
	%"体力".text=str(体力值)+"/"+str(体力上限)
	pass
func 生成动态文本():
	体力恢复速度=计划.体力恢复速度
	恢复量=计划.恢复量
	%"扩展内容".visible=true
	%"体力回复条".max_value=体力恢复速度
	更新进度条()
	_更新_UI()
	计时器=计划.创建计时器(0.05,更新进度条)
	var 门票名:Array=计划.数据体力("门票数组")
	var 体力 = "[img=50x33]res://素材/游戏素材/食品包/体力蛋糕.png[/img]"+"体力恢复速度"+str(恢复量)+"点/"+str(体力恢复速度)+"秒"
	var 门票 = "[img=40x30]res://素材/游戏素材/货币/17.png[/img]"+"门票总库存:"+",".join(门票名)
	%"扩展信息".text="%s\n%s" % [体力,门票]# 拼接文本
func 更新进度条():
	%"体力回复条".value=计划.处理时间戳(计划.梅存档["挂机"]["体力"])
func 结束更新():
	%"扩展内容".visible=false
	if 计时器 != null:
		计时器.stop()
		计时器.queue_free()
		计时器 = null
func _exit_tree():
	if 计时器:
		计时器.queue_free()
