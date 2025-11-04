extends Node
class_name 梅打印
func 智能打印(打印对象, 标签: String="无标签"):
	# 先打印标签
	print("=== " + 标签 + " ===")
	
	# 检查对象是否为null
	if 打印对象 == null:
		print("对象为 null")
		return
	
	# 根据对象类型进行智能打印
	match typeof(打印对象):
		TYPE_OBJECT:
			_打印对象属性(打印对象)
		TYPE_NIL:
			print("对象为 null")
		TYPE_STRING:
			print("字符串: ", 打印对象)
		TYPE_INT:
			print("整数: ", 打印对象)
		TYPE_FLOAT:
			print("浮点数: ", 打印对象)
		TYPE_BOOL:
			print("布尔值: ", 打印对象)
		TYPE_VECTOR2:
			print("Vector2: ", 打印对象)
		TYPE_VECTOR3:
			print("Vector3: ", 打印对象)
		TYPE_RECT2:
			print("Rect2: ", 打印对象)
		TYPE_ARRAY:
			print("数组长度: ", 打印对象.size())
			print("数组内容: ", 打印对象)
		TYPE_DICTIONARY:
			print("字典键数量: ", 打印对象.size())
			print("字典内容: ", 打印对象)
		_:
			print("未知类型: ", 打印对象)

func _打印对象属性(对象: Object):
	# 检查是否为节点
	if 对象 is Node:
		_打印节点属性(对象)
	# 检查是否为图片/纹理
	elif 对象 is Texture2D or 对象 is Image:
		_打印图片属性(对象)
	# 检查是否为音频
	elif 对象 is AudioStream:
		_打印音频属性(对象)
	# 检查是否为资源
	elif 对象 is Resource:
		_打印资源属性(对象)
	# 其他对象类型
	else:
		print("对象类型: ", 对象.get_class())
		print("对象ID: ", 对象.get_instance_id())
		print("原生打印: ", 对象)

func _打印节点属性(节点: Node):
	print("📋 节点信息:")
	print("   名称: ", 节点.name)
	print("   类型: ", 节点.get_class())
	print("   路径: ", 节点.get_path())
	
	# 如果是Control或Node2D等有尺寸的节点
	if 节点 is Control:
		var 控制节点: Control = 节点
		print("   尺寸: ", 控制节点.size)
		print("   位置: ", 控制节点.position)
		print("   是否可见: ", 控制节点.visible)
		print("   是否启用: ", 控制节点.visible and not 控制节点.is_set_as_top_level())
	elif 节点 is Node2D:
		var 二维节点: Node2D = 节点
		print("   位置: ", 二维节点.position)
		print("   旋转: ", 二维节点.rotation)
		print("   缩放: ", 二维节点.scale)
		print("   是否可见: ", 二维节点.visible)
	elif 节点 is Node3D:
		var 三维节点: Node3D = 节点
		print("   位置: ", 三维节点.position)
		print("   旋转: ", 三维节点.rotation)
		print("   缩放: ", 三维节点.scale)
		print("   是否可见: ", 三维节点.visible)
	else:
		print("   是否在场景中: ", 节点.is_inside_tree())

func _打印图片属性(图片对象):
	print("🖼️ 图片信息:")
	
	if 图片对象 is Texture2D:
		var 纹理: Texture2D = 图片对象
		print("   类型: Texture2D")
		print("   尺寸: ", 纹理.get_size())
		print("   是否有alpha通道: ", 纹理.has_alpha())
		if 纹理 is ImageTexture:
			var 图像纹理: ImageTexture = 纹理
			@warning_ignore("incompatible_ternary")
			print("   图像格式: ", 图像纹理.get_format() if 图像纹理.get_image() else "无图像数据")
	elif 图片对象 is Image:
		var 图像: Image = 图片对象
		print("   类型: Image")
		print("   尺寸: ", 图像.get_size())
		print("   格式: ", 图像.get_format())
		print("   是否支持mipmap: ", 图像.has_mipmaps())
	else:
		print("   未知图片类型: ", 图片对象.get_class())

func _打印音频属性(音频对象: AudioStream):
	print("🎵 音频信息:")
	print("   类型: ", 音频对象.get_class())
	
	# 获取音频长度
	var 长度 = 音频对象.get_length()
	if 长度 > 0:
		print("   长度: ", 长度, " 秒")
	else:
		print("   长度: 流式音频或未知长度")
	
	# 尝试获取文件名（如果是资源）
	if 音频对象 is Resource:
		var 资源路径 = (音频对象 as Resource).resource_path
		if 资源路径 and not 资源路径.begins_with("res://"):  # 修正变量名
			print("   文件名: ", 资源路径.get_file())
		else:
			print("   文件名: 内置资源或临时资源")
	
	# 特定音频类型信息
	if 音频对象 is AudioStreamWAV:
		var wav音频: AudioStreamWAV = 音频对象
		print("   格式: WAV")
		print("   立体声: ", wav音频.stereo)
		print("   采样率: ", wav音频.mix_rate, " Hz")
	elif 音频对象 is AudioStreamMP3:
		print("   格式: MP3")
	elif 音频对象 is AudioStreamOggVorbis:
		print("   格式: OGG Vorbis")

func _打印资源属性(资源对象: Resource):
	print("📦 资源信息:")
	print("   类型: ", 资源对象.get_class())
	print("   路径: ", 资源对象.resource_path if 资源对象.resource_path else "临时资源")
	print("   本地化: ", 资源对象.resource_local_to_scene)  # 修正变量名
