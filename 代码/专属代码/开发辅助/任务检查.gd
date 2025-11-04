@tool  # 标记为工具脚本，支持在编辑器中运行
extends EditorScript
class_name 任务检查器  # 中文类名
# 右键运行的入口方法（Godot会识别带参的_run方法）
func _run():
	print("===== 开始检查任务键 =====")
	var 任务类=梅任务.new()
	var A字典=任务类.任务字典
	var B字典=任务类.任务奖励字典
	检查缺失的键(A字典, B字典)
	return 0  # 表示运行成功
static func 检查缺失的键(A: Dictionary, B: Dictionary) -> void:# 核心检查逻辑（中文方法名）
	for A子字典名 in A:
		for 任务名称 in A[A子字典名]:
			if 任务名称 in B:
				# 绿色显示正确的任务名称
				print_rich("[color=green]正确: " + 任务名称 + "[/color]")
			else:
				# 红色显示错误的任务名称，并将变量值嵌入颜色标签
				print_rich("[color=red]错误: " + 任务名称 + "[/color]")
