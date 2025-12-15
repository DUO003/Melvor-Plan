@tool  # 标记为工具脚本，支持在编辑器中运行
extends EditorScript
class_name 贴图检查器  # 中文类名

# EditorScript必须重写的_run方法（编辑器中运行脚本时执行）
func _run() -> void:# 执行校验逻辑
	print("开始校验贴图字典...")
	var BUFF贴图实例=BUFF贴图.new()
	BUFF贴图实例.校验贴图字典()
	print("校验流程结束")
