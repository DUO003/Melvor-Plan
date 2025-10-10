extends Control
func _ready():
	# 游戏初始化
	%副本.pressed.connect(func():初始化.切换场景("战斗_副本","战斗界面"))
