##引擎文件专属
extends Node
class_name 引擎文件

func 获取当前运行目录():
	return 引擎.字符串.路径_取目录(OS.get_executable_path())
	pass
##用于扫描文件的东西,返回:["a/a.gd", "b/b.gd", "c.gd"]
##[codeblock]
##var 读取文件数组=引擎.文件.扫描文件("res://data/",true,["gd","json"]) #指定找gd + json
##var 读取文件数组=引擎.文件.扫描文件("res://data/",true) #递归扫子目录
##var 读取文件数组=引擎.文件.扫描文件("res://data/") #默认不扫子目录
##[/codeblock]
func 扫描文件(路径:String, 是否扫描子目录:bool = false, 指定格式:Array = []) -> Array:
	var 文件列表 = []
	var 目录 = DirAccess.open(路径)
	if 目录:
		目录.list_dir_begin()
		var 文件名 = 目录.get_next()
		while 文件名 != "":
			if 目录.current_is_dir():
				if 是否扫描子目录:
					var 子目录路径 = 路径 + "/" + 文件名
					var 子文件列表 = 扫描文件(子目录路径, 是否扫描子目录, 指定格式)
					for 子文件 in 子文件列表:
						文件列表.append(文件名 + "/" + 子文件)
			else:
				var 扩展名 = 文件名.get_extension()
				if 指定格式.is_empty() or 指定格式.find(扩展名) != -1:
					文件列表.append(文件名)
			文件名 = 目录.get_next()
		目录.list_dir_end()
	else:
		print("尝试访问路径时出错。")
	return 文件列表
	
func 扫描原始文件(路径:String, 是否扫描子目录:bool = false, 指定格式:Array = []) -> Array:
	#func 扫描文件(路径:String, 是否扫描子目录:bool = false, 指定格式:Array = []) -> Array:
	var 文件列表:Array = []
	var 资源列表 = ResourceLoader.list_directory(路径)
	
	for 资源路径 in 资源列表:
		# 检查是否为目录
		if 资源路径.ends_with("/"):
			if 是否扫描子目录:
				# 递归扫描子目录
				var 子文件列表 = 扫描原始文件(路径+资源路径, 是否扫描子目录, 指定格式)
				文件列表.append_array(子文件列表)#["乡村的温暖时光.mp3", "乡村的温暖时光.wav"]
		else:
			# 检查文件格式
			var 文件名 = 资源路径.get_file()
			var 扩展名 = 文件名.get_extension()
			if 指定格式.is_empty() or 指定格式.has(扩展名):
				# 计算相对路径
				var 相对路径 = 资源路径.replace(路径 + "/", "")
				文件列表.append(相对路径)
	
	return 文件列表
	
## 读取指定目录下所有文件的JSON内容，存储到字典
## 功能：扫描目录下的文件，解析JSON内容并以 {文件名: JSON数据} 格式返回
## [codeblock]
## # 读取res://json目录下的所有JSON文件（不递归子目录）
## var json数据 = 引擎.文件.读取目录下所有JSON到字典("res://json/")
## 
## [/codeblock]
func 读取目录下所有JSON到字典(目录: String) -> Dictionary:
	var json数据字典 = {}
	var 文件列表 = 引擎.文件.扫描文件(目录)
	
	if 文件列表.is_empty():
		print("目录为空或无文件: ", 目录)
		return json数据字典
	for 文件名 in 文件列表:
		# 尝试打开文件
		var file = FileAccess.open(目录+文件名, FileAccess.READ)
		if not file:
			push_error("无法打开文件: ", 目录+文件名)
			continue
		# 读取文件内容
		var 文件内容 = file.get_as_text()
		file.close()
		
		# 解析JSON
		var 解析结果 = JSON.parse_string(文件内容)
		if 解析结果 == null:
			push_error("JSON解析失败: ", 目录+文件名)
			continue
		
		# 存储到字典
		json数据字典[文件名] = 解析结果
	
	return json数据字典

##获取文件的MD5哈希值(用于文件校验)
##[codeblock]
##var md5 = 引擎.文件.获取MD5值("res://data/savegame.dat")
##print("文件MD5: ", md5)
##[/codeblock]
func 获取MD5值(文件路径:String):
	return FileAccess.get_md5(文件路径)

##加载Godot资源(如场景、纹理、脚本等)
##[codeblock]
##var scene = 引擎.文件.加载资源("res://scenes/main.tscn")
##add_child(scene.instantiate())
##[/codeblock]
func 加载资源(_文件: String):
	return load(_文件)

## 智能检查文件或资源是否存在(自动处理物理文件和导入资源)
## 优先检查物理文件，不存在时再检查导入资源
## 参数:[br]
##   - 文件路径: 要检查的文件路径
## 返回:[br]
##   - 如果文件或资源存在返回true，否则返回false
##[codeblock]
##if 引擎.文件.是否存在("res://scripts/player.gd"):           # 检查普通文件
##if 引擎.文件.是否存在("res://images/player.png"):          # 检查导入资源
##if 引擎.文件.是否存在("res://fonts/my_font.tres"):         # 检查TRES资源
##[/codeblock]
func 是否存在(文件路径:String) -> bool:
	# 优先检查物理文件是否存在
	if FileAccess.file_exists(文件路径):
		return true
	# 物理文件不存在时，检查是否为已导入的资源
	return ResourceLoader.exists(文件路径)

## 将文本内容保存到指定文件
## [br]参数:[br]
##   - 文本: 要保存的文本内容[br]
##   - 文件地址: 保存路径，默认为"user://save_game.dat"
## [br]异常:[br]
##   - 如果文件无法打开，会抛出错误
##[codeblock]
##引擎.文件.保存文本到文件("游戏进度数据", "user://save_game.dat")
##引擎.文件.保存文本到文件("配置信息", "user://config.txt")
##[/codeblock]
func 保存文本到文件(文本:String, 文件地址:String = "user://save_game.dat") -> bool:
	var _文件 = FileAccess.open(文件地址, FileAccess.WRITE)
	if _文件:
		_文件.store_string(文本)
		_文件.close() # 确保关闭文件
		return true
	else:
		push_error("无法打开文件进行写入: " + 文件地址)
		return false

	

## 从指定文件读取文本内容
## [br]参数:[br]
##   - 文件地址: 读取路径，默认为"user://save_game.dat"
## [br]返回:[br]
##   - 成功时返回文件内容字符串，失败时返回空字符串
##[codeblock]
##var 保存数据 = 引擎.文件.读取文件到文本("user://save_game.dat")
##var 配置内容 = 引擎.文件.读取文件到文本("user://config.txt")
##[/codeblock]
func 读取文件到文本(文件地址:String = "user://save_game.dat") -> String:
	var _文件 = FileAccess.open(文件地址, FileAccess.READ)
	if _文件:
		var 读取文本 = _文件.get_as_text()
		_文件.close() # 确保关闭文件
		return 读取文本
	else:
		push_error("无法打开文件进行读取: " + 文件地址)
		return ""

## 将变量序列化并保存到指定文件，支持加密
## [br]参数:[br]
##   - 数据: 要保存的变量[br]
##   - 文件地址: 保存路径，默认为"user://save_game.dat"[br]
##   - 密码: 加密密码，为空则不加密，默认为空
## [br]返回:[br]
##   - 成功返回true，失败返回false
## [br]异常:[br]
##   - 如果JSON序列化失败，会抛出错误
##   - 如果文件无法打开，会抛出错误
##[codeblock]
##var 游戏数据 = {"分数": 100, "关卡": 5}
##引擎.文件.保存变量到文件(游戏数据, "user://game_data.dat")  # 不加密
##引擎.文件.保存变量到文件(游戏数据, "user://game_data.dat", "123456")  # 加密保存
##[/codeblock]
func 保存变量到文件(数据:Variant,文件地址:String = "user://save_game.dat",密码: String = ""):
	var json_string=JSON.stringify(数据)
	if json_string == "":  # 序列化失败时返回空字符串
		push_error("JSON序列化失败，数据可能包含无法序列化的类型")
		return false
	# 根据密码是否存在选择普通保存或加密保存
	if 密码 == "":
		return 保存文本到文件(json_string, 文件地址)
	else:
		var file = FileAccess.open_encrypted_with_pass(文件地址, FileAccess.WRITE, 密码)
		if file:
			file.store_string(json_string)
			file.close()
			return true
		else:
			push_error("无法创建加密文件: " + 文件地址)
			return false
			
## 从指定文件读取数据并反序列化为变量，支持加密
## [br]参数:[br]
##   - 文件地址: 读取路径，默认为"user://save_game.dat"[br]
##   - 密码: 解密密码，需与保存时一致，默认为空
## [br]返回:[br]
##   - 成功返回变量内容，失败返回null
## [br]异常:[br]
##   - 如果文件不存在或无法打开，会抛出错误
##   - 如果JSON解析失败，会抛出错误
##   - 如果密码错误，会抛出错误
##[codeblock]
##var 读取的数据 = 引擎.文件.读取文件到变量("user://game_data.dat")  # 读取未加密数据
##var 加密数据 = 引擎.文件.读取文件到变量("user://game_data.dat", "123456")  # 读取加密数据
##if 读取的数据:
##    print("读取成功:", 读取的数据)
##[/codeblock]
func 读取文件到变量(文件地址: String = "user://save_game.dat", 密码: String = "") -> Variant:
	var json_string = ""
	
	# 根据密码是否存在选择普通读取或加密读取
	if 密码 == "":
		var file = FileAccess.open(文件地址, FileAccess.READ)
		if not file:
			push_error("无法打开文件: " + 文件地址)
			return null
		json_string = file.get_as_text()
		file.close()
	else:
		var file = FileAccess.open_encrypted_with_pass(文件地址, FileAccess.READ, 密码)
		if not file:
			push_error("无法打开加密文件（可能密码错误）: " + 文件地址)
			return null
		json_string = file.get_as_text()
		file.close()
	
	# 解析JSON数据
	var parse_result = JSON.parse_string(json_string)
	if parse_result == null:
		push_error("JSON解析失败: ")
		return null
	
	return parse_result#.result
	
## 加载外部PCK或ZIP资源包
## [br]参数:[br]
##   - 路径资源: 要加载的资源包路径，默认为"user://update.zip"
## [br]返回:[br]
##   - 加载成功返回true，失败返回false
##[codeblock]
## 引擎.文件.加载PCK("user://custom_content.pck")
##[/codeblock]
func 加载PCK(路径资源:String = "user://update.zip") -> bool:
	return ProjectSettings.load_resource_pack(路径资源)


#追加ini

## 配置文件缓存字典，键为文件路径，值为ConfigFile实例
var 配置 = {}

## 加载指定路径的配置文件（或从缓存中获取）
## [br]参数:[br]
##   - _文件路径: 配置文件路径，默认为"res://配置项.ini"
## [br]返回:[br]
##   - ConfigFile对象，可用于读取和修改配置
##[codeblock]
## var 配置 = 引擎.配置文件.ini_读取配置文件("res://settings.ini")
##[/codeblock]
func ini_读取配置文件(_文件路径: String = "res://配置项.ini") -> ConfigFile:
	if not (_文件路径 in 配置):
		配置[_文件路径] = ConfigFile.new()
	
	var 读取配置 = 配置[_文件路径].load(_文件路径)
	return 配置[_文件路径]

## 从配置文件中读取指定节和键的值
## [br]参数:[br]
##   - _文件: ConfigFile对象[br]
##   - _节: 配置节名称[br]
##   - _键: 配置键名称
## [br]返回:[br]
##   - 配置值，如果不存在则返回null
##[codeblock]
## var 值 = 引擎.配置文件.ini_读取(配置, "General", "Volume")
##[/codeblock]
func ini_读取(_文件: ConfigFile, _节, _键) -> Variant:
	return _文件.get_value(_节, _键)

## 设置配置文件中指定节和键的值
## [br]参数:[br]
##   - _文件: ConfigFile对象[br]
##   - _节: 配置节名称[br]
##   - _键: 配置键名称[br]
##   - _内容: 要设置的值
## [br]返回:[br]
##   - 操作是否成功（始终返回true）
##[codeblock]
## 引擎.配置文件.ini_设置(配置, "General", "Fullscreen", true)
##[/codeblock]
func ini_设置(_文件: ConfigFile, _节, _键, _内容) -> bool:
	_文件.set_value(_节, _键, _内容)
	return true

## 保存配置文件到指定路径
## [br]参数:[br]
##   - _文件: ConfigFile对象[br]
##   - 保存到哪里: 保存路径，默认为"res://配置项.ini"
## [br]返回:[br]
##   - 错误码（OK表示成功，其他值表示失败）
##[codeblock]
## 引擎.配置文件.ini_保存配置文件(配置, "user://saved_settings.ini")
##[/codeblock]
func ini_保存配置文件(_文件: ConfigFile, 保存到哪里: String = "res://配置项.ini") -> Error:
	var _状态 = _文件.save(保存到哪里)
	print("状态:%s 保存成功,路径:%s" % [_状态, 保存到哪里])
	return _状态


##保存到自带配置
func 保存自带配置的变量(配置项名称:String,配置值:Variant):
	ProjectSettings.set_setting(配置项名称,配置值)
	ProjectSettings.save_custom("override.cfg")
	pass
##从自带配置读取
func 读取自带配置的变量(配置项名称:String):
	return ProjectSettings.get_setting(配置项名称)
