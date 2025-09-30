extends Control
func _ready():
	# 游戏初始化
	%水排序.pressed.connect(func(): 初始化.切换场景("小游戏_水排序","小游戏界面"))
