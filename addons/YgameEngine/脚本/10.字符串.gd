## 字符串处理工具类
## 提供常用的字符串操作方法
extends Node
class_name 引擎字符串

## 不区分大小写替换字符串中的所有匹配项
## [br]参数:[br]
##   - 原字符串: 要处理的原始字符串[br]
##   - 哪个要换: 需要被替换的子字符串[br]
##   - 要换成什么: 替换后的新字符串
## [br]返回:[br]
##   - 替换后的新字符串
##[codeblock]
## var 结果 = 引擎.字符串.替换文本("Hello World", "world", "Godot", true)
## print(结果) # 输出: Hello Godot
##[/codeblock]
func 替换文本(原字符串:String, 哪个要换:String, 要换成什么:String) -> String:
	return 原字符串.replacen(哪个要换, 要换成什么)

## 从指定位置截取字符串
## [br]参数:[br]
##   - 原字符串: 要处理的原始字符串[br]
##   - 开始位置: 截取的起始位置（从0开始）[br]
##   - 长度: 要截取的字符长度
## [br]返回:[br]
##   - 截取的子字符串
##[codeblock]
## var 子串 = 引擎.字符串.从指定位置获取字符串("Hello", 1, 3)
## print(子串) # 输出: ell
##[/codeblock]
func 从指定位置获取字符串(原字符串:String, 开始位置:int, 长度:int) -> String:
	return 原字符串.substr(开始位置, 长度)

## 使用分隔符分割字符串为数组
## [br]参数:[br]
##   - _字符串: 要分割的原始字符串[br]
##   - _分割符: 用于分割的字符串
## [br]返回:[br]
##   - 分割后的字符串数组
##[codeblock]
## var 数组 = 引擎.字符串.分割("a,b,c", ",")
## print(数组) # 输出: [a, b, c]
##[/codeblock]
func 分割(_字符串:String, _分割符:String) -> Array:
	return _字符串.split(_分割符)

## 获取分割后的特定索引位置的子字符串
## [br]参数:[br]
##   - _字符串: 要处理的原始字符串[br]
##   - _分割符: 用于分割的字符串[br]
##   - _索引位置: 要获取的索引位置
## [br]返回:[br]
##   - 指定索引位置的子字符串
##[codeblock]
## var 切片 = 引擎.字符串.获取切片("a_b_c", "_", 1)
## print(切片) # 输出: b
##[/codeblock]
func 获取切片(_字符串:String, _分割符:String, _索引位置:int) -> String:
	return _字符串.get_slice(_分割符, _索引位置)

## 在字符串左侧填充指定字符到目标长度
## [br]参数:[br]
##   - _字符串: 要处理的原始字符串[br]
##   - _填充后的长度: 填充后的目标长度[br]
##   - _填充占位字符串: 用于填充的字符或字符串
## [br]返回:[br]
##   - 填充后的字符串
##[codeblock]
## var 填充后 = 引擎.字符串.左侧填充("42", 5, "0")
## print(填充后) # 输出: 00042
##[/codeblock]
func 左侧填充(_字符串:String, _填充后的长度:int, _填充占位字符串:String) -> String:
	return _字符串.lpad(_填充后的长度, _填充占位字符串)

## 将字符串转换为UTF-8字节数组
## [br]参数:[br]
##   - _字符串: 要转换的字符串
## [br]返回:[br]
##   - UTF-8字节数组
##[codeblock]
## var 字节数组 = 引擎.字符串.到uft8字节数据("你好")
## print(字节数组) # 输出: [228, 189, 160, 229, 165, 189]
##[/codeblock]
func 到uft8字节数据(_字符串:String) -> PackedByteArray:
	return _字符串.to_utf8_buffer()


## 从路径中取出文件名 
## 路径_取文件名("www.baidu.com/a/z.zip") >z.zip
func 路径_取文件名(文件路径:String):
	var 取最后出现的字符串位置=文件路径.rfind("/")
	var 提取的文件名=文件路径.substr(取最后出现的字符串位置+1,文件路径.length()-取最后出现的字符串位置)
	return 提取的文件名

## "c:/b/a.txt" >>> c:/b/a  从路口取不含扩展名
func 路径_取文件名不含扩展名(文件路径:String):
	return 文件路径.get_basename()

## c:/b/a.txt >>> txt  从路径取文件的扩展
func 路径_取文件扩展名(文件路径:String):
	return 文件路径.get_extension()

## c:/b/a.txt >>> c:/b  从路径取目录
func 路径_取目录(文件路径:String):
	return 文件路径.get_base_dir()
	
## c:/b/a.txt >>> a.txt  从路径取文件名(含扩展)
func 路径_取文件名含扩展名(文件路径:String):
	return	文件路径.get_file()
	

## 将数据通过JSON格式转换为字符串
## 参数:
##   数据: 可序列化的Variant类型（字典、数组等）
## 返回:
##   成功返回JSON字符串，失败返回空字符串
## [codeblock]
## var 数据 = {"a": 1, "b": [2, 3]}
## var str = 引擎.字符串.Json_到字符串(数据)  # 结果: '{"a":1,"b":[2,3]}'
## [/codeblock]
func Json_到字符串(数据: Variant) -> String:
	var json_str = JSON.stringify(数据)
	if json_str == "":
		push_error("JSON序列化失败")
	return json_str

## 从JSON格式的字符串解析为数据
## 参数:
##   json字符串: 符合JSON格式的字符串
## 返回:
##   成功返回解析后的数据（字典/数组等），失败返回null
## [codeblock]
## var str = '{"a":1,"b":[2,3]}'
## var 数据 = 引擎.字符串.Json_到数据(str)  # 结果: {"a": 1, "b": [2, 3]}
## [/codeblock]
func Json_到数据(json字符串: String) -> Variant:
	var 数据 = JSON.parse_string(json字符串)
	if 数据 == null:
		push_error("JSON解析失败")
	return 数据

func 正则匹配(字符串:String,模式)->String:
	var regex = RegEx.new()
	regex.compile(模式) # Negated whitespace character class.
	var 返回值 = ""
	for result in regex.search_all(字符串):
		返回值+=result.get_string()
	return 返回值

var 领取次数=1
func 获取不重复随机码() -> String:
		if 领取次数==null:
			print("tool调试无法获取")
			return ""
		领取次数+=1
		var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		var code = ""
		
		for i in range(3):
			# 从字符集中随机选择一个字符
			var random_index = randi() % chars.length()
			code += chars[random_index]
		
		return str(int(领取次数*10))+str(code)
