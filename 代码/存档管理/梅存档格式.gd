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
var 可用:bool=true
#@export_storage var 测试

#ContainerRepository
## 单例
static var 单例:梅存档格式:
	get:
		if not 单例:
			单例 = 梅存档格式.new()
		return 单例
var 优先使用存档名称=""
func 加载所有存档()->Dictionary:
	var 有效存档:int=0
	var 存档字典:={}
	var 目录 = DirAccess.open(存档配置路径)
	if 目录 == null:
		var 路径 = DirAccess.open("user://")
		路径.make_dir_recursive(存档配置路径)
		目录 = DirAccess.open(存档配置路径)
		if 目录 == null:
			return {}
	目录.list_dir_begin()# 开始枚举目录中的文件
	var 文件名 = 目录.get_next()
	while 文件名 != "":# 仅处理 .tres 文件（排除 .tres.import 等衍生文件）
		var 是Tres文件 = 文件名.ends_with(".tres") and !文件名.ends_with(".tres.import")
		if 是Tres文件:# 提取基础文件名（去掉 .tres 后缀）
			var 基础文件名 = 文件名.get_basename()  # "存档1.tres" → "存档1"
			var 完整加载路径 = 存档配置路径 + 文件名# 拼接完整加载路径
			var 加载结果 = load(完整加载路径)# 加载文件并验证是否为「梅存档格式」
			if 加载结果 != null:
				if 加载结果 is 梅存档格式:
					if 加载结果.版本比较():
						if 优先使用存档名称=="":
							优先使用存档名称=基础文件名
						存档字典[基础文件名] = 加载结果
						有效存档+=1
					else :
						存档字典[基础文件名]=错误存档创建(加载结果.版本号)
				else :
					存档字典[基础文件名]=错误存档创建()
			else:
				print("文件格式错误，非梅存档格式: ", 文件名)# 格式验证失败（非梅存档格式）
				#breakpoint#断点
		文件名 = 目录.get_next()# 遍历下一个文件
	目录.list_dir_end()# 结束目录枚举
	if 有效存档==0:
		var 有效存档名称=存档命名
		if 存档字典.has(有效存档名称):
			var 序号: int = 2
			while 序号 <= 100:
				有效存档名称 = 存档命名 + "(%d)" % 序号
				if not 存档字典.has(有效存档名称):
					break  # 找到可用名称，退出循环
				序号 += 1  # 名称仍被占用，尝试下一个序号
			if 序号 > 100:
				计划.语法糖通知("没有存档数据,重建失败")
				return {}
		if 优先使用存档名称=="":
			优先使用存档名称=有效存档名称
		存档(有效存档名称)
		存档字典[有效存档名称]=self
		计划.语法糖通知("没有存档数据,已重建")
		print("没有存档数据,已重建")
	if 优先使用存档名称=="" and 存档字典.size()>=1:
		优先使用存档名称=存档字典.keys()[0]
	print("优先使用存档名称",优先使用存档名称)
	return 存档字典
func 错误存档创建(显示版本号:String="兼容性错误")->梅存档格式:
	var 错误存档=梅存档格式.new()
	错误存档.版本号=显示版本号
	错误存档.可用=false
	return 错误存档
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
func 读档(存档名: String = "",覆盖用户名: String="")->bool:
	var 加载结果:梅存档格式
	var 最终存档名 = (存档名 if 存档名 != "" else 存档命名).strip_edges()
	计划.梅存档={"正在加载":0}
	var 完整路径 = 存档配置路径 + 最终存档名 + ".tres"
	加载结果 = load(完整路径)
	if 加载结果 != null:
		if not 加载结果 is 梅存档格式:
			计划.语法糖通知("存档数据错误")
			return false
		if not 加载结果.版本比较():
			计划.语法糖通知("不能打开新版本创建或修改后的存档,游戏可能已经更新")
			return false
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
				for 装备栏名称 in 装备栏单例._slot_data_map:
					var 装备= 装备栏单例._slot_data_map[装备栏名称].equipped_item
					if  装备 is 物品装备:
						装备.更新属性()
			var 背包单例:ContainerRepository=ContainerRepository.instance
			if 挂机.has("背包与商店") and 背包单例:
				背包单例._container_data_map.clear()
				for 背包名称 in 梅存档["挂机"]["背包与商店"].keys():
					背包单例._container_data_map[背包名称] = 梅存档["挂机"]["背包与商店"][背包名称].deep_duplicate()
					背包单例.加载物品(背包名称)
			if 挂机.has("快速移动关系") and 背包单例:
				背包单例._quick_move_relations_map=梅存档["挂机"]["快速移动关系"].duplicate(true)
		计划.存档时间戳=加载结果.保存时间
		await 计划.正式加载()
		return true
	else:
		print("文件格式错误，非梅存档格式: ", 存档名)# 格式验证失败（非梅存档格式）
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
func 解析版本号(版本字符串: String) -> Array[int]:
	# 过滤空字符串（防止多小数点/首尾小数点等异常输入）
	var 分割后的部分 = 版本字符串.split(".", true)
	var 数字版本部分: Array[int] = []
	for 单部分:String in 分割后的部分:
		# 去除首尾空格
		var 清理后的部分:String = 单部分.strip_edges()
		if 清理后的部分.is_empty():
			continue
		if 清理后的部分.is_valid_int():
			数字版本部分.append(清理后的部分.to_int())
		else :数字版本部分.append(0)
	return 数字版本部分
func 版本比较():
	var 游戏版本号:Array[int]=解析版本号(游戏版本)
	var 存档版本号:Array[int]=解析版本号(self.版本号)
	for i in 游戏版本号.size():
		var 游戏位数值 = 游戏版本号[i]
		var 存档位数值
		if i>=存档版本号.size():存档位数值=0
		else :存档位数值=存档版本号[i]
		if 存档位数值 > 游戏位数值:
			return false
		elif 存档位数值 < 游戏位数值:
			return true
	if 游戏版本号.size()<存档版本号.size():
		return false
	return true
