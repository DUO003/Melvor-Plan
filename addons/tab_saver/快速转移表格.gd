@tool
extends EditorScript
class_name 快速转移表格
#func _run():
	#pass
	#剪切文件("梅尔沃计划重制数据 - 多语言.csv","res://表格/翻译/")
func 剪切文件(文件名称:String,目标目录:String,文件路径:String)->bool:
	var 源文件路径 = 文件路径+文件名称
	var 目标文件路径 = 目标目录 + 文件名称
	#检查源文件是否存在
	if not FileAccess.file_exists(源文件路径):
		push_error("源文件不存在: " + 源文件路径)
		return false
	#确保目标目录存在
	var 目录操作 = DirAccess.open(目标目录)
	if 目录操作 == null:
		# 如果目录不存在，则递归创建
		var 创建目录错误码 = DirAccess.make_dir_recursive_absolute(目标目录)
		if 创建目录错误码 != OK:
			push_error("创建目标目录失败: " + 目标目录)
			return false
		目录操作 = DirAccess.open(目标目录)
	#执行文件复制（模拟“剪切”的第一步）
	# 读取源文件内容
	var 源文件操作 = FileAccess.open(源文件路径, FileAccess.READ)
	if 源文件操作 == null:
		push_error("无法打开源文件进行读取: " + 源文件路径)
		return false
	var 文件内容 = 源文件操作.get_as_text()
	源文件操作.close()
	# 写入到目标路径
	var 目标文件操作 = FileAccess.open(目标文件路径, FileAccess.WRITE)
	if 目标文件操作 == null:
		push_error("无法打开目标文件进行写入: " + 目标文件路径)
		return false
	目标文件操作.store_string(文件内容)
	目标文件操作.close()
	#完成“剪切”操作
	# 警告：此操作不可逆，请谨慎使用。可以先注释掉，仅测试复制功能。
	var 源目录操作 = DirAccess.open(文件路径)
	if 源目录操作:
		var 删除文件错误码 = 源目录操作.remove(文件名称)
		if 删除文件错误码 != OK:
			push_warning("文件复制成功，但删除源文件失败。这将成为一次复制操作。")
		else:
			print("文件剪切操作成功完成！")
	else:
		push_warning("文件复制成功，但无法访问源目录以进行删除。这将成为一次复制操作。")
	print("文件已成功转移至: " + 目标文件路径)
	# 刷新编辑器文件系统面板，使新文件可见
	EditorInterface.get_resource_filesystem().scan()
	return true
func 打开存档目录(存档的路径="res://测试/"):
	var 系统绝对路径: String = ProjectSettings.globalize_path(存档的路径)
	# 确保目录存在
	if not DirAccess.dir_exists_absolute(系统绝对路径):
		var 创建结果 = DirAccess.make_dir_recursive_absolute(系统绝对路径)
		if 创建结果 != OK:
			print("存档目录创建失败：", 系统绝对路径)
			return false
