extends Button
func _ready() -> void:
	$"../奖励悬浮面板".奖励显示变化.connect(同步显示)
	pressed.connect(清空)
	
func 同步显示(显示):
	visible=显示
func 清空():
	计划.语法糖奖励显示([],"",0,true)
