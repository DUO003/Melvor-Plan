extends Control
var 固定文本
var 体力上限:int=240
var 体力值:int=100
var 体力恢复速度:int=360
var 恢复量:int=1
var 计时器=null
func _ready() -> void:
	%"扩展内容".visible=false
	mouse_entered.connect(func():生成动态文本())
	mouse_exited.connect(func(): 结束更新())
	初始化.connect("更新_UI", Callable(self, "_更新_UI"))
	_更新_UI()
func _更新_UI():
	var 挂机数据 = 初始化.梅存档["挂机"]
	体力上限=挂机数据.get("体力上限", 240)
	体力值=挂机数据.get("体力值", 0)
	%"体力值".max_value=体力上限
	%"体力值".value=体力值
	%"体力".text=str(体力值)+"/"+str(体力上限)
	pass
func 生成动态文本():
	体力恢复速度=初始化.体力恢复速度
	恢复量=初始化.恢复量
	%"扩展内容".visible=true
	%"体力回复条".max_value=体力恢复速度
	更新进度条()
	_更新_UI()
	计时器=初始化.创建计时器(0.05,更新进度条)
	var 挂机数据 = 初始化.梅存档["挂机"]
	var 门票名=挂机数据.get("门票",{}).keys()
	var 体力 = "[img=50x33]res://素材/游戏素材/食品包/without background/33.png[/img]"+"体力恢复速度"+str(恢复量)+"点/"+str(体力恢复速度)+"分钟"
	var 门票 = "[img=40x30]res://素材/游戏素材/货币/without background/17.png[/img]"+"门票总库存:"+str(门票名)
	%"扩展信息".text="%s\n%s" % [体力,门票]# 拼接文本
	%"扩展信息".update_minimum_size()
	%"扩展信息".set_size(%"扩展信息".get_combined_minimum_size())
	%"扩展内容".size=Vector2(%"扩展内容".size.x,%"扩展信息".size.y+2)
func 更新进度条():
	%"体力回复条".value=初始化.处理时间戳("体力回复")
func 结束更新():
	%"扩展内容".visible=false
	if 计时器 != null:
		计时器.stop()
		计时器.queue_free()
		计时器 = null
