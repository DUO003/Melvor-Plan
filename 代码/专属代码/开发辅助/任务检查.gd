@tool  # 标记为工具脚本，支持在编辑器中运行
extends EditorScript
class_name 任务检查器  # 中文类名
# 右键运行的入口方法（Godot会识别带参的_run方法）
func _run():
	#var 任务类:=梅任务.new()
	#var 文本:=提取循环任务(任务类.任务模板)
	#print("执行结束:",文本)
	var 窗口:=梅窗口.new()
	var 窗口名数组:Array=[]
	for 窗口名 in 窗口.窗口数据:
		if 窗口.窗口数据[窗口名].has("显示名"):
			窗口名数组.append(窗口.窗口数据[窗口名]["显示名"])
	var 最终文本:String="\r".join(窗口名数组)
	DisplayServer.clipboard_set(最终文本)
	return 0  # 表示运行成功
func 提取循环任务(任务字典: Dictionary) -> String:
	var 结果行列表:Array = []
	var 任务名称列表:Array=[]
	for 任务类型 in 任务字典:
		if 任务类型 is String:
			continue
		for 任务名称 in 任务字典[任务类型]:
			var 任务信息:Dictionary = 任务字典[任务类型][任务名称]
			if not 结果行列表.has(任务名称):
				任务名称列表.append(任务名称)
			if 任务信息.has("模板"):
				var 描述列表:Array = 任务信息["模板"]
				for 单行描述:String in 描述列表:
					if not 结果行列表.has(单行描述):
						结果行列表.append(单行描述)
	var 最终文本 = "\n".join(任务名称列表)+"\n"+"\n".join(结果行列表)
	DisplayServer.clipboard_set(最终文本)
	return 最终文本
func 提取任务文本(任务字典: Dictionary) -> String:
	print(任务字典)
	var 结果行列表:Array = []
	for 任务名称:String in 任务字典:
		var 任务信息:Dictionary = 任务字典[任务名称]
		if not 结果行列表.has(任务名称):
			结果行列表.append(任务名称)
		if 任务信息.has("任务描述"):
			var 描述列表:Array = 任务信息["任务描述"]
			for 单行描述:String in 描述列表:
				if not 结果行列表.has(单行描述):
					结果行列表.append(单行描述)
	var 最终文本 = "\n".join(结果行列表)
	DisplayServer.clipboard_set(最终文本)
	return 最终文本
static func 检查缺失的键(A: Dictionary, B: Dictionary) -> void:# 核心检查逻辑（中文方法名）
	for A子字典名 in A:
		for 任务名称 in A[A子字典名]:
			if 任务名称 in B:
				# 绿色显示正确的任务名称
				print_rich("[color=green]正确: " + 任务名称 + "[/color]")
			else:
				# 红色显示错误的任务名称，并将变量值嵌入颜色标签
				print_rich("[color=red]错误: " + 任务名称 + "[/color]")
