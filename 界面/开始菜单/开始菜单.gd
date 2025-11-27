extends Control
var 游戏版本 = ProjectSettings.get_setting("application/config/version", "错误") # 第二个参数是默认值
var 存档单例:梅存档格式
var 存档字典: Dictionary = {}
func _ready() -> void:
	%"开始游戏".pressed.connect(开始)
	%"新建".pressed.connect(新建)
	%"设置".pressed.connect(设置)
	%"删除".pressed.connect(删除)
	%"退出游戏".pressed.connect(退出)
	%"删除二次确认".confirmed.connect(确认删除)
	计划.提示容器=%"提示容器"
	存档单例=梅存档格式.单例
	存档单例.基础存档()
	重新加载存档()

## 返回格式化后的相对时间文本（如：5分钟前 / 2 hours ago）
## 时间戳: float 【必须传入】存档时保存的Unix时间戳（秒）
## 返回值语言: String 【可选】默认中文，支持扩展其他语言
func 时间文本(时间戳: float, 返回值语言: String = "中文") -> String:
	# 内置多语言翻译字典（可按需扩展更多语言）
	var 语言字典 = {
		"中文": { # 中文
			"刚刚": "刚刚",
			"分钟前": "分钟前",
			"小时前": "小时前",
			"天前": "天前",
			"月前": "月前",
			"年前": "年前",
		},
		"英文": { # 英文
			"刚刚": "just now",
			"分钟前": "minutes ago",
			"小时前": "hours ago",
			"天前": "days ago",
			"月前": "months ago",
			"年前": "years ago",
		},
		"日语": { # 日语（可选扩展）
			"刚刚": "たった今",
			"分钟前": "分前",
			"小时前": "時間前",
			"天前": "日前",
			"月前": "月前",
			"年前": "年前",
		}
	}

	# 容错：若传入的语言不在字典中，默认使用中文
	var 当前语言 = 语言字典.get(返回值语言, 语言字典["中文"])
	
	# 使用Time单例获取当前时间（文档中提到的Time类）
	var 当前时间 = Time.get_unix_time_from_system()
	var 时间差: float = max(0.0, 当前时间 - 时间戳)

	# 时间单位换算（秒）- 使用浮点数避免整数除法警告
	const 一分钟 = 60.0
	const 一小时 = 3600.0
	const 一天 = 86400.0
	const 一个月 = 2592000.0  # 30天
	const 一年 = 31536000.0   # 365天

	# 按时间区间生成文本（使用文档中提到的字符串格式化方法）
	if 时间差 < 一分钟:
		return 当前语言["刚刚"]
	elif 时间差 < 一小时:
		var 分钟数 = floor(时间差 / 一分钟)
		# 使用文档中的格式化字符串语法：%s占位符
		return "%s%s" % [分钟数, 当前语言["分钟前"]]
	elif 时间差 < 一天:
		var 小时数 = floor(时间差 / 一小时)
		var 剩余分钟 = floor(fmod(时间差, 一小时) / 一分钟)
		# 精细显示：如"1小时5分钟前" / "2 hours 10 minutes ago"
		if 剩余分钟 > 0:
			# 根据语言处理文本格式
			if 返回值语言 == "中文":
				return "%s小时%s%s" % [小时数, 剩余分钟, 当前语言["分钟前"]]
			else:
				return "%s %s %s %s" % [小时数, 当前语言["小时前"], 剩余分钟, 当前语言["分钟前"]]
		else:
			return "%s%s" % [小时数, 当前语言["小时前"]]
	elif 时间差 < 一个月:
		var 天数 = floor(时间差 / 一天)
		return "%s%s" % [天数, 当前语言["天前"]]
	elif 时间差 < 一年:
		var 月数 = floor(时间差 / 一个月)
		return "%s%s" % [月数, 当前语言["月前"]]
	else:
		var 年数 = floor(时间差 / 一年)
		return "%s%s" % [年数, 当前语言["年前"]]
func 重新加载存档():
	for 节点 in %"存档选择".get_children():
		%"存档选择".remove_child(节点)
		节点.queue_free()
		print("清除节点成功")
	存档字典=存档单例.加载所有存档()
	var 存档样式=preload("res://界面/开始菜单/存档样式.tscn").instantiate()
	for 存档名称 in 存档字典:
		var 存档=存档样式.duplicate()
		var 梅存档数据=存档字典[存档名称]
		var 挂机等级=梅存档数据.梅存档.get("挂机",{}).get("等级",0)
		var 等级文本="挂机:%d"%挂机等级 if 挂机等级>0 else "新存档"
		var 保存时间=梅存档数据.保存时间
		存档.文本信息="当前存档:%s\r%s\r保存时间:%s"%[存档名称,等级文本,时间文本(保存时间)]
		存档.name=存档名称
		%"存档选择".add_child(存档)

func 开始():
	#print("哈希A:","78&9".hash())
	#print("哈希B:","9%87".hash())
	#return
	var 存档名称=存档字典.keys()[%"存档选择".current_tab]
	计划.存档名称=存档名称
	计划.存档路径=存档单例.存档配置路径
	计划.梅存档=存档字典[存档名称].梅存档
	await 计划.正式加载()
func 新建():
	if %"自定义存档名".text=="":
		计划.语法糖通知("请输入存档名")
		return
	elif 存档字典.has(%"自定义存档名".text):
		计划.语法糖通知("存档名已存在")
		return
	var 存档名称=%"自定义存档名".text
	存档单例.存档(存档名称)
	重新加载存档()
	计划.语法糖通知("新建存档成功")
func 设置():
	计划.跳转设置=true
	开始()
func 删除():
	%"删除二次确认".show()
func 退出():
	get_tree().quit()
func 确认删除():
	var 存档名称=存档字典.keys()[%"存档选择".current_tab]
	存档单例.删除存档(存档名称)
	重新加载存档()
	计划.语法糖通知("删除存档成功")
