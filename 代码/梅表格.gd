extends Node
class_name CSVReader# 自动加载的CSV读取器，用于从CSV文件中读取数据
var 装备蓝图: Array
##已蓝图名称为键名,返回对应蓝图数组
var 蓝图字典:Dictionary = {}
##缓存对应表头的int
var 蓝图表头:Dictionary = {}
##缓存被使用的贴图实例
var 蓝图贴图:Dictionary[String,Texture2D] = {}
##所有被加载的字典 已字典名称为键
var 表格字典:Dictionary = {}
##预先加载标签
var 缓存蓝图标签:Dictionary={}
func _ready():
	#print_all_res_files()
	加载所有表格()
	#保留旧接口
	装备蓝图=处理表格数据(表格字典["装备蓝图"])
	字典加载()
	标签加载()
	#print("打印简介",获取简介("深渊苦露粉"))
func 标签加载():
	缓存蓝图标签={}
	var 图纸标签=装备蓝图[0].find("标签")
	for 蓝图 in 装备蓝图:
		缓存蓝图标签[蓝图[0]]=蓝图[图纸标签]
func 字典加载():
	蓝图表头={}
	var 缓存序号=0
	for 表头 in 装备蓝图[0]:
		蓝图表头[表头]=缓存序号
		缓存序号+=1
	蓝图字典={}
	for 蓝图 in 装备蓝图:
		蓝图字典[蓝图[0]]=蓝图
	#print(蓝图表头)
func 道具贴图(贴图名称:String):#->Texture2Dprint("贴图名称",贴图名称)
	if 贴图名称 in 蓝图贴图:
		return 蓝图贴图[贴图名称]
	if 贴图名称 in 蓝图字典:
		var 贴图:Texture2D=load(蓝图字典[贴图名称][蓝图表头["icon"]])
		if 贴图:
			蓝图贴图[贴图名称]=贴图
			return 贴图
	
	return null
	
func 加载所有表格():
	# 清空现有数据
	表格字典.clear()
	# 打开表格目录
	var 目录 = DirAccess.open("res://表格/")
		
	if 目录 == null:
		print("无法打开表格目录: ", DirAccess.get_open_error())
		return
		
	# 枚举目录中的所有文件
	目录.list_dir_begin()
	var 文件名 = 目录.get_next()
	
	while 文件名 != "":
		# 同时处理 .csv 和 .csv.import 文件
		var 是CSV文件 = 文件名.ends_with(".csv") and !文件名.ends_with(".csv.import")
		var 是Import文件 = 文件名.ends_with(".csv.import")
		
		if 是CSV文件 or 是Import文件:
			# 处理基础文件名（去掉对应的扩展名）
			var 基础文件名 = ""
			if 是CSV文件:
				基础文件名 = 文件名.get_basename()  # 去掉 .csv
			else:
				基础文件名 = 文件名.get_basename().get_basename()  # 先去掉 .import，再去掉 .csv
			
			# 处理键名（保持原有的分割逻辑）
			var 分割结果 = 基础文件名.split(" - ")
			var 键名 = 基础文件名
			if 分割结果.size() >= 2:
				键名 = 分割结果.slice(1)[0]
			
			# 修正三元运算符语法：使用 GDScript 支持的 "if else" 形式
			var 加载文件名 = 文件名.get_basename() if 是CSV文件 else 基础文件名
			
			# 加载对应文件
			表格字典[键名] = 获取表格(加载文件名)
			
			# 打印提示，区分两种文件类型
			#if 是CSV文件:
				#print("加载CSV文件: ", 文件名, " 键名: ", 键名)
			#else:
				#print("加载Import文件: ", 文件名, " 键名: ", 键名)
		
		文件名 = 目录.get_next()
	
	目录.list_dir_end()
	# print("已加载:", 表格字典)

func 获取表格(表格: String) -> Array:
	var 文件路径 = "res://表格/" + 表格 + ".csv"
	var 文件 = FileAccess.open(文件路径, FileAccess.READ)
	if 文件 == null:
		print("尝试打开"+表格+".CSV文件失败\r", 文件路径)
		文件路径 = "res://表格/" + 表格 + ".csv.import"
		文件 = FileAccess.open(文件路径, FileAccess.READ)
		# 如果.import文件也不存在，返回错误
		if 文件 == null:
			print("错误：无法打开文件 ", 文件路径)
			return []
	var 结果数组 = []
	while !文件.eof_reached():
		var 一行内容 = 文件.get_line().strip_edges()
		var 子数组 = []
		# 先判断是否包含双引号，决定解析方式
		if 一行内容.find("\"") == -1:# 无引号，直接用split快速处理,需要转换会普通数组
			子数组 = Array(一行内容.split(","))
		else:# 当前单行行存在引号无法直接解析，需要使用逐字解析
			var 当前单元格 = ""
			var 在引号内 = false
			var 上一个字符是引号 = false
			for i in range(一行内容.length()):
				var 字符 = 一行内容[i]
				if 字符 == "\"":
					if 上一个字符是引号:
						当前单元格 += "\""  # 连续两个引号转为一个
						上一个字符是引号 = false
						continue
					在引号内 = !在引号内
					上一个字符是引号 = true
					continue
				else:
					上一个字符是引号 = false
				if 字符 == "," and !在引号内:
					子数组.append(当前单元格)
					当前单元格 = ""
				else:
					当前单元格 += 字符
			子数组.append(当前单元格)  # 添加最后一个单元格
		结果数组.append(子数组)
	文件.close()
	return 结果数组

func 获取表格信息(表格数组: Array, 检索名称: String, 读取表值: String) -> Variant:
	var 项目索引 = _表头检索(表格数组[0], 读取表值)
	if 项目索引 == -1:
		print("获取表格信息失败 参数:",读取表值,"\r",表格数组[0])
		return ""
	# 遍历武器数据行
	var 编号 = 0  # 定义编号变量并初始化为0
	for 首项行 in 表格数组:
		if 首项行[0] == 检索名称:
			var 找到的值
			if 项目索引 == 0:
				找到的值 = 编号
			else:
				找到的值 = 首项行[项目索引]
			return 找到的值
		编号 += 1  # 每次循环+1
	return ""
func 获取表格信息数组(表格数组: Array, 检索名称数组: Array, 读取表值: String) -> Array:
	var 项目索引 = _表头检索(表格数组[0],读取表值)
	if 项目索引 == -1:
		print("获取表格信息失败：未找到读取项目 '", 读取表值, "'")
		return []
	var 结果数组 = []
	for 首项名称 in 检索名称数组:
		var 找到的值 = ""
		var 编号 = 0  # 定义编号变量并初始化为0
		for 数据行 in 表格数组:
			if 编号 == 0:
				编号 += 1
				continue
			if 数据行[0] == 首项名称:
				if 项目索引 == 0:
					找到的值 = 编号
				else:
					找到的值 = 数据行[项目索引]
				break
			编号 += 1  # 每次循环+1
		结果数组.append(找到的值)
	return 结果数组

func _表头检索(表头: Array, 读取项目: String):
	for i in range(表头.size()):
		#print("表头:", 表头[i], " | 项目:", 读取项目, " | 结果:", 表头[i] == 读取项目)
		if 表头[i] == 读取项目:
			return i
	return -1

# 通用方法：通过表格行号获取表格数据字典
func 获取表格字典(表格数据,表格行号:int, 首项名称 = null) -> Dictionary:
		# 如果指定了首项名称，则检索对应的行号
	if 首项名称 != null:
		# 遍历数据行（跳过表头行0）
		for i in range(1, 表格数据.size()):
			# 检查当前行是否有数据且首项匹配
			if i < 表格数据.size() and 表格数据[i].size() > 0 and 表格数据[i][0] == 首项名称:
				表格行号 = i
				break
		if 首项名称 != 表格数据[表格行号][0]:
			# 未找到匹配的首项名称
			push_warning("未找到首项名称对应的行: " + 首项名称)
			return {}
	
	# 验证表格行号有效性
	if 表格行号 < 1 or 表格行号 >= 表格数据.size():
		push_warning("表格行号无效: " + str(表格行号))
		return {}
	
	# 获取表头和对应行数据
	var 表头 = 表格数据[0]
	var 行数据 = 表格数据[表格行号]
	var 结果字典 = {}
	
	# 遍历表头与行数据，生成键值对
	for i in range(表头.size()):
		if i >= 行数据.size():# 确保索行的值引不越界
			continue
		var 键 = 表头[i]
		var 原始值 = 行数据[i].strip_edges()  # 去除值的前后空格
		# 尝试转换为浮点，无法转换则保留字符串
		if 原始值.is_valid_float():
			结果字典[键] = float(原始值)
		else:
			结果字典[键] = 原始值
	
	return 结果字典
	
func print_all_res_files():
	var root_path = "res://"
	# 使用静态方法获取目录访问实例
	var dir = DirAccess.open(root_path)
	
	if dir == null:
		print("无法打开目录: ", root_path, " 错误: ", DirAccess.get_open_error())
		return
	
	# 开始递归遍历
	print("开始列出所有 res:// 下的文件和目录：")
	traverse_directory_files(dir, root_path)

func traverse_directory_files(dir: DirAccess, current_path: String):
	dir.list_dir_begin()
	var entry = dir.get_next()
	
	while entry != "":
		# 跳过 . 和 ..
		if entry == "." or entry == "..":
			entry = dir.get_next()
			continue
		
		var full_path = current_path + entry
		var is_dir = dir.current_is_dir()
		
		# 打印路径
		if is_dir:
			print("[目录] ", full_path)
			# 递归遍历子目录：使用静态方法打开子目录
			var sub_dir = DirAccess.open(full_path)
			if sub_dir != null:
				traverse_directory_files(sub_dir, full_path + "/")
				sub_dir.list_dir_end()  # 结束子目录遍历
		else:
			print("[文件] ", full_path)
		
		entry = dir.get_next()
	dir.list_dir_end()
func 处理表格数据(表格: Array):
	if len(表格) == 0 or len(表格[0]) == 0:# 检查表头是否存在必要字段
		print("表格数据为空")
		return []
	var icon索引 = 表格[0].find("icon")# 获取"icon"和"名称"在表头的索引
	var 名称索引 = 表格[0].find("名称")
	if icon索引 == -1 or 名称索引 == -1:# 检查索引有效性
		print("表头缺少必要字段: icon 或 名称")
		return []
	var 表格拷贝=表格.duplicate(true)
	for 行索引 in range(1, len(表格)):# 从第二行开始遍历数据行（跳过表头）
		var 当前行 = 表格[行索引]
		if len(当前行) <= icon索引 or len(当前行) <= 名称索引:# 确保当前行有足够的字段
			print("第", 行索引, "行数据不完整，跳过处理")
			continue
		var 原始icon路径:String = 当前行[icon索引]
		var 物品名称:String = 当前行[名称索引]
		var 处理后icon路径:String = 原始icon路径
		# 检查是否需要特殊转译（以*号结尾）
		if 原始icon路径.ends_with("*"):
			# 移除末尾*号，拼接名称和.png
			处理后icon路径 = 原始icon路径.trim_suffix("*") + 物品名称 + ".png"
		表格拷贝[行索引][icon索引]=处理后icon路径
	return 表格拷贝
# 生成简介文本（仅依赖传入的尺寸参数，完全解耦节点）
func 获取简介(物品名称: String, 图片尺寸: int=40) -> String:
	var 基础简介文本: String = 蓝图字典[物品名称][蓝图表头["简介"]]
	if 基础简介文本=="":
		return ""
	var 匹配器: RegEx = RegEx.new()# 正则匹配所有 "替换#{图片名称}" 标记
	匹配器.compile("替换#\\{([^}]+)\\}")  # 匹配格式：替换#{图片名}
	var 匹配结果: Array = 匹配器.search_all(基础简介文本)
	var 结果文本: String = 基础简介文本# 从后往前替换，避免索引偏移
	for i in range(匹配结果.size() - 1, -1, -1):
		var 匹配项: RegExMatch = 匹配结果[i]
		var 图片名称: String = 匹配项.get_group(1)  # 提取图片名称
		var 图片路径: String = 道具贴图(图片名称)   # 调用你的图片路径方法
		var 替换内容: String = ""# 生成替换内容（图片路径错误则不显示）
		if not 图片路径=="":
			var 尺寸字符串: String = "%dx%d" % [图片尺寸, 图片尺寸]# 生成尺寸字符串（如 "100x100"）
			替换内容 = ("[img=%s]%s[/img]") % [尺寸字符串, 图片路径]
		结果文本 = 结果文本.substr(0, 匹配项.get_start()) + 替换内容 + 结果文本.substr(匹配项.get_end())# 执行替换
	return 结果文本
