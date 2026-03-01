extends 基类梅窗口
func _ready():
	# 游戏初始化
	super._ready()
	%水排序.pressed.connect(func(): 计划.切换场景("小游戏_水排序"))
