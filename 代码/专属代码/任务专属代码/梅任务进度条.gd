extends ProgressBar
class_name 梅任务进度条
var 目标值=0
var 任务名称:String
var 功能按钮:Callable
func _ready() -> void:
	#print("进度条")
	目标值=计划.任务.任务全局[任务名称]["当前进度列表"].size()
	custom_minimum_size=Vector2(0,60)
	size_flags_horizontal=Control.SIZE_EXPAND_FILL
	size_flags_vertical=Control.SIZE_SHRINK_CENTER
	min_value = 0  # 最小值
	step = 0.01  # 步长
	max_value = 目标值  # 最大值
	计划.任务更新.connect(_更新进度)
	_更新进度([任务名称])
func _更新进度(任务数组:Array=[]) -> void:
	if 任务名称 in 任务数组:
		var 任务全局 = 计划.梅任务单例.任务全局
		if 任务全局.has(任务名称):
			value = 计划.梅任务单例.任务全局[任务名称]["完成总进度"]
			if value>=max_value:
				if not is_queued_for_deletion() and 功能按钮 is Callable:
					功能按钮.call()
					queue_free()
		else:
			print("警告：任务名称 '", 任务名称, "' 不存在于任务全局中")
			queue_free()
