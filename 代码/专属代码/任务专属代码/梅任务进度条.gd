extends ProgressBar
class_name 梅任务进度条
var 目标值=0
var 任务数据:任务资源
var 功能按钮:Callable
func _ready() -> void:
	if 任务数据.任务本地.is_empty():
		功能按钮.call()
		queue_free()
	else :
		目标值=任务数据.任务本地["当前进度列表"].size()
		custom_minimum_size=Vector2(0,60)
		size_flags_horizontal=Control.SIZE_EXPAND_FILL
		size_flags_vertical=Control.SIZE_SHRINK_CENTER
		min_value = 0  # 最小值
		step = 0.01  # 步长
		max_value = 目标值  # 最大值
		计划.任务.任务更新.connect(_更新进度)
		_更新进度()
func _更新进度(更新任务:Array[任务资源]=[]) -> void:
	if 更新任务.is_empty() or 更新任务.has(任务数据):
		value = 任务数据.任务本地["完成总进度"]
		if value>=max_value:
			if not is_queued_for_deletion() and 功能按钮 is Callable:
				功能按钮.call()
				queue_free()
