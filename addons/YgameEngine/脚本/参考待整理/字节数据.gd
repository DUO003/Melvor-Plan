## 字节数据处理工具类
## 提供PackedByteArray的常用操作和解析功能
extends Node
class_name 引擎字节数据

## 将字节数组转换为十六进制字符串表示
## [br]参数:[br]
##   - _字节数据: 要转换的字节数组
## [br]返回:[br]
##   - 十六进制字符串
##[codeblock]
## var hex_str = 引擎.字节数据.显示十六进制(PackedByteArray([0x41, 0x42, 0x43]))
## print(hex_str)  # 输出: "414243"
##[/codeblock]
func 显示十六进制(_字节数据:PackedByteArray) -> String:
	return _字节数据.hex_encode()

## 从字节数组中获取指定范围的切片
## [br]参数:[br]
##   - _字节数据: 源字节数组[br]
##   - 开始: 起始索引（从0开始）[br]
##   - 获取几个字节: 要获取的字节数
## [br]返回:[br]
##   - 包含指定范围字节的新字节数组
##[codeblock]
## var 切片 = 引擎.字节数据.获取切片(PackedByteArray([1, 2, 3, 4]), 1, 2)
## print(切片)  # 输出: [2, 3]
##[/codeblock]
func 获取切片(_字节数据:PackedByteArray, 开始:int, 获取几个字节:int) -> PackedByteArray:
	return _字节数据.slice(开始, 开始 + 获取几个字节)

## 从字节数组中解析8位无符号整数
## [br]参数:[br]
##   - _字节数据: 源字节数组[br]
##   - _偏移: 起始解析位置，默认为0
## [br]返回:[br]
##   - 解析出的8位无符号整数
##[codeblock]
## var 值 = 引擎.字节数据.到8位整数(PackedByteArray([0xFF]))
## print(值)  # 输出: 255
##[/codeblock]
func 到8位整数(_字节数据:PackedByteArray, _偏移 = 0) -> int:
	return _字节数据.decode_u8(_偏移)

## 从字节数组中解析16位无符号整数（小端序）
## [br]参数:[br]
##   - _字节数据: 源字节数组[br]
##   - _偏移: 起始解析位置，默认为0
## [br]返回:[br]
##   - 解析出的16位无符号整数
##[codeblock]
## var 值 = 引擎.字节数据.到16位整数(PackedByteArray([0xFF, 0x01]))
## print(值)  # 输出: 511 (0x01FF)
##[/codeblock]
func 到16位整数(_字节数据:PackedByteArray, _偏移 = 0) -> int:
	return _字节数据.decode_u16(_偏移)

## 从字节数组中解析32位无符号整数（小端序）
## [br]参数:[br]
##   - _字节数据: 源字节数组[br]
##   - _偏移: 起始解析位置，默认为0
## [br]返回:[br]
##   - 解析出的32位无符号整数
##[codeblock]
## var 值 = 引擎.字节数据.到32位整数(PackedByteArray([0xFF, 0xFF, 0xFF, 0x00]))
## print(值)  # 输出: 16777215 (0x00FFFFFF)
##[/codeblock]
func 到32位整数(_字节数据:PackedByteArray, _偏移 = 0) -> int:
	return _字节数据.decode_u32(_偏移)


#
#var _packed:PackedByteArray;
#func 写入字符串(text:String):
	##英文占用一个字节(推荐不含中文的字符串用这个),中文占用3个字节
	#var 字节大小=text.length()
	#_packed.append(字节大小)
	#_packed.append_array(text.to_utf8_buffer())
#func 写入字符串2(text:String):
	##宽字符串,中文占用2个字节(推荐含中文的用这个)
	#var 字节大小=text.length()
	#_packed.append(字节大小)
	#_packed.append_array(text.to_wchar_buffer())
#
#func _init(数据类型) -> void:
	##new用到这个
	#_packed=PackedByteArray([数据类型])
	#
#func 获取字节数据():
	#return _packed
	#pass

#var 队列数据=[]
#enum 数据类型 {
	#登入,
	#注册
#}
	#
#func append(数据:PackedByteArray):
	#队列数据.append(数据)
	#print("添加的队列",数据)
	#pass
#
#func _physics_process(delta: float) -> void:
	#if (队列数据.size()>0):
		#var 拿到的数据=队列数据.pop_front()
		#处理数据(拿到的数据)
		#print("处理")
	#pass
#
#
#func 处理数据(数据:PackedByteArray):
	#var 数据包类型=数据[0] #接收到的数据包
	#match 数据包类型:
		#数据类型.注册:
			#print("注册")
		#数据类型.登入:
			#print("登入",数据)
			#var 账号长度=数据[1]
			#var 账号=数据.slice(2,2+账号长度)
			#var 密码长度=2+账号长度+1
			#var 密码=数据.slice(密码长度,数据.size())
			#print("user:",账号.get_string_from_utf8())
			#print("press:",密码.get_string_from_utf8())
			#
	#pass
