extends Resource
## 梅存档数据库，管理不同的存档
class_name 梅存档格式
var 游戏版本 = ProjectSettings.get_setting("application/config/version", "错误") # 第二个参数是默认值
var 存档配置路径: String = "user://存档/"#最后一个字符必须传入"/"
var 存档命名: String="默认存档"
@export_storage var 梅存档:={}
@export_storage var 哈希值:int=-1
@export_storage var 保存时间:float=Time.get_unix_time_from_system()
@export_storage var 版本号: String=""
@export_storage var 启用测试:bool=false
var 用户名: String="玩家"#默认为玩家,可以在开始菜单随时修改
#@export_storage var 测试

#ContainerRepository
## 单例
static var 单例:梅存档格式:
	get:
		if not 单例:
			单例 = 梅存档格式.new()
		return 单例
func 加载所有存档():
	var 存档字典:={}
	var 目录 = DirAccess.open(存档配置路径)
	if 目录 == null:
		var 路径 = DirAccess.open("user://")
		路径.make_dir_recursive(存档配置路径)
		目录 = DirAccess.open(存档配置路径)
		if 目录 == null:
			return
	目录.list_dir_begin()# 开始枚举目录中的文件
	var 文件名 = 目录.get_next()
	while 文件名 != "":# 仅处理 .tres 文件（排除 .tres.import 等衍生文件）
		var 是Tres文件 = 文件名.ends_with(".tres") and !文件名.ends_with(".tres.import")
		if 是Tres文件:# 提取基础文件名（去掉 .tres 后缀）
			var 基础文件名 = 文件名.get_basename()  # "存档1.tres" → "存档1"
			var 完整加载路径 = 存档配置路径 + 文件名# 拼接完整加载路径
			var 加载结果 = load(完整加载路径)# 加载文件并验证是否为「梅存档格式」
			if 加载结果 != null and 加载结果 is 梅存档格式:
				# 验证通过：键=基础文件名，值=梅存档格式
				存档字典[基础文件名] = 加载结果
				print("成功加载存档文件: ", 文件名, " 键名: ", 基础文件名)
			else:
				print("文件格式错误，非梅存档格式: ", 文件名)# 格式验证失败（非梅存档格式）
		文件名 = 目录.get_next()# 遍历下一个文件
	目录.list_dir_end()# 结束目录枚举
	return 存档字典
## 新建或保存存档[br]
## 返回是否保存成功
func 存档(存档名: String = "",存档数据:Dictionary={}) -> bool:
	var 最终存档名 = (存档名 if 存档名 != "" else 存档命名).strip_edges()
	var 完整路径 = 存档配置路径 + 最终存档名 + ".tres"
	梅存档=存档数据#.duplicate(true)
	if 梅存档.has("挂机"):#新存档不含数据无需保存
		if EquipmentSlotRepository.instance:
			梅存档["挂机"]["装备栏"]=EquipmentSlotRepository.instance._slot_data_map.duplicate(true)
		if ContainerRepository.instance:
			梅存档["挂机"]["背包与商店"]=ContainerRepository.instance._container_data_map.duplicate(true)
			梅存档["挂机"]["快速移动关系"]=ContainerRepository.instance._quick_move_relations_map.duplicate(true)
		if 梅存档["挂机"].has("用户信息"):
			梅存档["挂机"]["用户信息"]["用户名"]=用户名
		if 梅存档["挂机"].has("红点存档") and 计划.红点 and 计划.红点.红点存档:
			梅存档["挂机"]["红点存档"]=计划.红点.红点存档
	哈希值=最终存档名.hash()
	保存时间=Time.get_unix_time_from_system()if 计划.存档时间戳==-1 else 计划.存档时间戳
	版本号=游戏版本
	#测试=标准物品.new(1,"蓝图纸")
	var 保存结果 = ResourceSaver.save(self, 完整路径)
	if 保存结果 == OK:# 保存存档并返回结果
		return true
	else:
		var 错误说明 = ""
		match 保存结果:
			ERR_CANT_CREATE: 错误说明 = "无法创建文件（目录不存在/权限不足）"
			ERR_FILE_NOT_FOUND: 错误说明 = "文件路径不存在（目录未创建）"
			ERR_INVALID_DATA: 错误说明 = "资源数据非法（非合法Resource）"
			ERR_FILE_NO_PERMISSION: 错误说明 = "文件访问被拒绝（权限不足）"
			_: 错误说明 = "未知错误"
		print("新建或保存存档失败：", 错误说明, "，错误码：", 保存结果)
		return false
##读取存档到游戏内,仅开始界面可使用
func 读档(存档名: String = "",存档的数据:梅存档格式=null,覆盖用户名: String="")->bool:
	var 加载结果:梅存档格式
	var 最终存档名 = (存档名 if 存档名 != "" else 存档命名).strip_edges()
	if 存档的数据 is 梅存档格式:
		加载结果=存档的数据
	else :
		var 完整路径 = 存档配置路径 + 最终存档名 + ".tres"
		加载结果 = load(完整路径)
	if 加载结果 != null and 加载结果 is 梅存档格式:
		启用测试=加载结果.启用测试
		计划.存档路径=存档配置路径
		计划.存档名称=最终存档名
		计划.梅存档=加载结果.梅存档.duplicate(true)
		梅存档=计划.梅存档
		if 覆盖用户名=="":
			用户名=梅存档.get("挂机",{}).get("用户信息",{}).get("用户名",用户名)
		else :
			用户名=覆盖用户名
		if 梅存档.has("挂机"):
			var 挂机=梅存档["挂机"]
			var 装备栏单例:EquipmentSlotRepository=EquipmentSlotRepository.instance
			if 挂机.has("装备栏")	and 装备栏单例:
				装备栏单例._slot_data_map=梅存档["挂机"]["装备栏"].duplicate(true)
			var 背包单例:ContainerRepository=ContainerRepository.instance
			if 挂机.has("背包与商店") and 背包单例:
				背包单例._container_data_map.clear()
				for 背包名称 in 梅存档["挂机"]["背包与商店"].keys():
					背包单例._container_data_map[背包名称] = 梅存档["挂机"]["背包与商店"][背包名称].deep_duplicate()
			if 挂机.has("快速移动关系") and 背包单例:
				背包单例._quick_move_relations_map=梅存档["挂机"]["快速移动关系"].duplicate(true)

		await 计划.正式加载()
		return true
	else:
		print("文件格式错误，非梅存档格式: ", 存档名)# 格式验证失败（非梅存档格式）
		return false
# Godot 4.5 存档路径文件检测函数
func 基础存档():
	# 1. 尝试打开存档目录（处理目录不存在/无法访问的情况）
	var 目录 = DirAccess.open(存档配置路径)
	if 目录 == null:
		var 路径 = DirAccess.open("user://")
		路径.make_dir_recursive(存档配置路径)
		目录 = DirAccess.open(存档配置路径)
		if 目录 == null:
			return
	# 2. 开始枚举目录中的所有条目（文件/子目录）
	目录.list_dir_begin()
	var 当前条目 = 目录.get_next()
	# 3. 遍历所有目录条目
	while 当前条目 != "":
		# 排除系统默认的 "."（当前目录）和 ".."（上级目录）
		if 当前条目 != "." and 当前条目 != "..":
			# 检查当前条目是否是「文件」（而非子目录）
			if not 目录.current_is_dir():
				# 找到任意文件 → 结束枚举并返回 true
				目录.list_dir_end()
				return true
		# 继续遍历下一个条目
		当前条目 = 目录.get_next()
	# 4. 遍历结束未找到任何文件 → 结束枚举并返回 false
	目录.list_dir_end()
	存档()
	return false
func 删除存档(存档名: String = "")->bool:
	var dir = DirAccess.open(存档配置路径)# 创建 DirAccess 实例
	if dir:
		if dir.file_exists(存档名+".tres"):# 检查文件是否存在然后删除
			var 删除结果 = dir.remove(存档名+".tres")
			if 删除结果 == OK:
				print("删除成功")
				return true
			else:
				print("删除失败，错误代码: ", 删除结果)
	else:
		print("无法访问目录")
	return false
