extends Control
var 游戏版本 = ProjectSettings.get_setting("application/config/version", "错误") # 第二个参数是默认值
var 存档单例:梅存档格式
var 存档字典: Dictionary = {}
@onready var 感谢名单: Button = %感谢名单
@onready var 名单容器: Panel = $开始菜单/名单容器
@onready var 游戏图标: TextureRect = %游戏图标
@onready var 多语言功能区: Panel = %多语言功能区
@onready var 开始游戏: Button = %开始游戏
func _ready() -> void:
	名单容器.visible=false
	感谢名单.pressed.connect(func():
		名单容器.visible=not 名单容器.visible
		游戏图标.visible=not 名单容器.visible)
	开始游戏.pressed.connect(开始)
	%"新建".pressed.connect(新建)
	%"设置".pressed.connect(设置)
	%"删除".pressed.connect(删除)
	%"退出游戏".pressed.connect(退出)
	%"确认弹窗".confirmed.connect(确认执行)
	%"确认弹窗".visible=false
	计划.提示容器=%"提示容器"
	存档单例=梅存档格式.单例
	重新加载存档()
	var 有效序号=0
	var 序号=0
	var 有效显示名称=存档单例.优先使用存档名称
	for 名称 in 存档字典:
		if 名称==有效显示名称:
			有效序号=序号
		序号+=1
	%"存档选择".current_tab=有效序号
	%"版本号".text=游戏版本
	计划.表格.翻译切换("英文")
	多语言功能区.外部更新选中(计划.表格.当前使用语言)
	开始游戏.grab_focus()
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
	存档字典=存档单例.加载所有存档()
	var 存档样式=preload("res://界面/开始菜单/存档样式.tscn").instantiate()
	for 存档名称 in 存档字典:
		var 存档=存档样式.duplicate()
		var 梅存档数据:梅存档格式=存档字典[存档名称]
		if 梅存档数据.可用:
			var 挂机等级=梅存档数据.梅存档.get("挂机",{}).get("等级",0)
			var 用户名称=梅存档数据.梅存档.get("挂机",{}).get("用户信息",{}).get("用户名","新存档")
			var 测试状态="\r启用测试"if 梅存档数据.启用测试 else ""
			var 等级文本="挂机:%d\r"%挂机等级 if 挂机等级>0 else ""
			var 保存时间=梅存档数据.保存时间
			存档.文本信息="用户名:%s\r%s保存时间:%s%s\r版本号:%s"%[用户名称,等级文本,时间文本(保存时间),测试状态,梅存档数据.版本号]
		else :
			存档.文本信息="版本号:%s\r<游戏版本低于存档版本,不能读取>"%梅存档数据.版本号
		存档.name=存档名称
		存档.visibility_changed.connect(func():设置用户名(存档名称, 存档))
		%"存档选择".add_child(存档)
func 设置用户名(存档名称,存档):
	if 存档.visible:
		var 梅存档数据=存档字典[存档名称]
		%"玩家名".text=梅存档数据.梅存档.get("挂机",{}).get("用户信息",{}).get("用户名",存档单例.用户名)
		if not 存档单例.存档命名 == 存档名称:
			%"自定义存档名".text=存档名称
		else :%"自定义存档名".text=""
func 开始():
	#print("哈希A:","78&9".hash())
	#print("哈希B:","9%87".hash())
	#return
	if %"玩家名".text=="":
		%"玩家名".text = 存档单例.用户名
	if %"存档选择".current_tab>=0:
		var 存档名称=存档字典.keys()[%"存档选择".current_tab]
		存档单例.读档(存档名称,%"玩家名".text)
	else :
		计划.语法糖通知("需要先新建存档")

func 新建():
	if 存档字典.has(%"自定义存档名".text) or (存档字典.has(存档单例.存档命名) and %"自定义存档名".text==""):
		计划.语法糖通知("存档名已存在")
		return
	%"启用测试".show()
	%"弹窗标题".text="新建存档"
	%"弹窗文本".text="存档创建后
文件名需要关闭游戏手动修改
用户名修改后进入游戏存档后生效
沙盒模式启用可以使用命令,但禁用多人(未开发)"
	%"确认弹窗".show()
func 设置():
	计划.跳转设置=true
	开始()
func 删除():
	%"启用测试".visible=false
	%"弹窗标题".text="二次确认删除"
	%"弹窗文本".text="是否确认删除存档,不可恢复!"
	%"确认弹窗".show()
func 退出():
	get_tree().quit()
func 确认执行():
	if %"弹窗标题".text=="二次确认删除":
		var 存档名称=存档字典.keys()[%"存档选择".current_tab]
		存档单例.删除存档(存档名称)
		重新加载存档()
		计划.语法糖通知("删除存档成功")
	elif %"弹窗标题".text=="新建存档":
		var 存档名称
		if 存档字典.has(%"自定义存档名".text) or (存档字典.has(存档单例.存档命名) and %"自定义存档名".text==""):
			计划.语法糖通知("存档名已存在")
			return
		elif %"自定义存档名".text=="":
			计划.语法糖通知("使用默认名称创建存档")
			存档名称=""
		else :
			存档名称=%"自定义存档名".text
		存档单例.启用测试=%"启用测试".button_pressed
		存档单例.存档(存档名称)
		重新加载存档()
		计划.语法糖通知("新建存档成功")
