extends ScrollContainer
@onready var 悬浮背景色: ColorPickerButton = %悬浮背景色
@onready var 悬浮标题色: ColorPickerButton = %悬浮标题色
@onready var 悬浮数值色: ColorPickerButton = %悬浮数值色
@onready var 主题背景色: ColorPickerButton = %主题背景色
@onready var 主题标题色: ColorPickerButton = %主题标题色
@onready var 清空悬浮样式: Button = %清空悬浮样式
@onready var 清空主题样式: Button = %清空主题样式
@onready var 悬浮样式示例: Control = %悬浮样式示例
signal 更新设置(条件)
var 全局配置字典:Dictionary = ProjectSettings.get_setting("global/snake_case")
func _ready() -> void:
	%"启用全屏".button_pressed=计划.配置文件.get("全屏",false)
	%"启用全屏".toggled.connect(func(条件):计划.切换全屏(条件))
	绑定按钮(%"自动存档","自动存档")
	绑定按钮(%"制作通知","制作通知")
	绑定按钮(%"精通通知","精通通知")
	绑定按钮(%"熟练通知","熟练通知")
	绑定整数数值框(%"通知数量","最大通知",20)
	%"群二维码".visible=计划.窗口状态管理("设置","二维码",true)
	%"二维码".button_pressed=%"群二维码".visible
	%"二维码".pressed.connect(func():
		计划.窗口状态管理("设置","二维码",null,%"二维码".button_pressed)
		%"群二维码".visible=计划.窗口状态管理("设置","二维码",true))
	绑定下拉框配置(%"通知显示时长","通知显示时长")
	绑定下拉框配置(%"通知显示位置","通知位置",true)
	%"删除缓存".pressed.connect(func():
		计划.梅存档["挂机"]["窗口"]={}
		%"群二维码".visible=计划.窗口状态管理("设置","二维码",true)
		%"二维码".button_pressed=%"群二维码".visible
		if 计划.节点有效性检查("空节点"):
			计划.节点["空节点"].重新载入存档缓存()
		计划.语法糖通知("缓存已清空","通知"))
	%"打开存档文件夹".pressed.connect(func():计划.打开存档目录())
	处理颜色变更(悬浮背景色,"悬浮背景色",全局配置字典.get("悬浮背景色"))
	处理颜色变更(悬浮标题色,"悬浮标题色",全局配置字典.get("悬浮标题色"))
	处理颜色变更(悬浮数值色,"悬浮数值色",全局配置字典.get("悬浮数值色"))
	悬浮数值色.color_changed.connect(func(_颜色: Color):设置悬浮样式())
	清空悬浮样式.pressed.connect(清空设置.bind(["悬浮背景色","悬浮标题色","悬浮数值色"]))
	处理颜色变更(主题背景色,"主题背景色",全局配置字典.get("主题背景色"))
	主题背景色.color_changed.connect(func(_颜色: Color):计划.场景全局样式.emit())
	处理颜色变更(主题标题色,"主题标题色",全局配置字典.get("主题标题色"))
	主题标题色.color_changed.connect(func(_颜色: Color):计划.场景全局样式.emit())
	清空主题样式.pressed.connect(清空设置.bind(["主题背景色","主题标题色"]))
	设置悬浮样式()
	计划.场景全局样式.connect(设置悬浮样式)
func 设置悬浮样式():
	悬浮样式示例.提示数据.提示数组[2].文本="数值色[color=%s]%d[/color]"%[
		计划.配置文件.get("悬浮数值色",全局配置字典.get("悬浮数值色")),123]
func 清空设置(条件数组:Array=[]):
	for 条件 in 条件数组:
		计划.配置文件.erase(条件)
		更新设置.emit(条件)
	计划.场景全局样式.emit()
##给颜色节点绑定信号设置默认值
func 处理颜色变更(节点: ColorPickerButton,条件名:String,默认值:String="#000000FF"):
	更新设置.connect(func(条件):
		if 条件==条件名:
			节点.color=Color(计划.配置文件.get(条件名, 默认值)as String))
	节点.color=Color(计划.配置文件.get(条件名, 默认值)as String)
	节点.color_changed.connect(func(颜色: Color):计划.配置文件[条件名]=颜色转十六进制文本(颜色))
## 核心函数：将Color对象转为 #000000 格式的十六进制文本
func 颜色转十六进制文本(颜色: Color) -> String:
	# 分别将R/G/B值转换为两位十六进制（00-FF），并拼接成 #RRGGBB 格式
	var r = "%02X" % int(颜色.r * 255)  # 红色通道（0-255）转两位十六进制
	var g = "%02X" % int(颜色.g * 255)  # 绿色通道
	var b = "%02X" % int(颜色.b * 255)  # 蓝色通道
	# 关键：自动判断透明度（兼容浮点精度误差，比如0.999999≈1.0）
	var 完全不透明 = abs(颜色.a - 1.0) < 0.001  # 浮点精度容错阈值
	if 完全不透明:
		return "#" + r + g + b  # 无透明通道：#RRGGBB
	else:
		var a = "%02X" % clamp(int(颜色.a * 255), 0, 255)
		return "#" + r + g + b + a  # 带透明通道：#RRGGBBAA
func 绑定按钮(节点:Button,条件名:String,默认值:bool=true):
	节点.button_pressed=计划.配置文件.get(条件名,默认值)
	节点.toggled.connect(func(条件):计划.配置文件[条件名]=条件)
## 绑定数值框（SpinBox）
func 绑定整数数值框(节点:SpinBox,条件名:String,默认值:int=0):
	节点.value = 计划.配置文件.get(条件名, 默认值)
	节点.value_changed.connect(func(数值):# 绑定值变化信号，同步整数到配置文件
		计划.配置文件[条件名] = int(数值))
# 通用下拉框配置绑定方法（从节点自动生成映射 + 兼容新旧存档）
# 参数说明：
# - 节点: 下拉选择节点（OptionButton，如%("通知显示位置")）
# - 配置名: 配置存储的键名（如"通知位置"）
# - 启用文本转译: 是否保存文本（true=旧逻辑，保存选项文本；false=新逻辑，保存选项序号）
# - 默认索引: 兜底默认索引（可选，默认取节点初始选中的索引）
func 绑定下拉框配置(节点: OptionButton,配置名: String,启用文本转译: bool = false,默认索引: int = -1) -> void:
	if not 节点:# 安全校验：节点为空直接返回
		push_warning("绑定配置失败：下拉节点为空")
		return
	var 配置存储 = 计划.配置文件
	# 步骤1：从节点自动生成「文本→索引」「索引→文本」映射
	var 文本转索引: Dictionary = {}
	var 索引转文本: Dictionary = {}
	for 索引 in range(节点.get_item_count()):
		var 选项文本 = 节点.get_item_text(索引)
		文本转索引[选项文本] = 索引
		索引转文本[索引] = 选项文本
	# 步骤2：确定最终默认索引（优先用户指定，否则取节点初始选中项）
	var 最终默认索引 = 默认索引 if 默认索引 != -1 else 节点.selected
	# 兜底：防止默认索引超出节点选项范围
	最终默认索引 = clamp(最终默认索引, 0, 节点.get_item_count() - 1)
	# 步骤3：读取存档值并容错转换为目标索引
	var 存档值: Variant = 配置存储.get(配置名, null)
	var 目标索引: int = 最终默认索引  # 初始化为默认值
	# 容错逻辑：兼容新旧存档（文本/序号）
	if 存档值 != null:
		if 启用文本转译:
			# 旧逻辑：存档是文本 → 转索引
			if 存档值 is String and 文本转索引.has(存档值):
				目标索引 = 文本转索引[存档值]
			# 兼容：存档是序号 → 直接用
			elif 存档值 is int and 索引转文本.has(存档值):
				目标索引 = 存档值
		else:
			# 新逻辑：存档是序号 → 直接用
			if 存档值 is int and 索引转文本.has(存档值):
				目标索引 = 存档值
			# 兼容：存档是文本（旧数据）→ 转索引
			elif 存档值 is String and 文本转索引.has(存档值):
				目标索引 = 文本转索引[存档值]
	# 步骤4：设置节点选中项（确保索引有效）
	节点.selected = 目标索引
	节点.item_selected.connect(func(选中索引: int):
		# 确保选中索引有效
		if not 索引转文本.has(选中索引):
			选中索引 = 最终默认索引
		# 根据转译开关，写入文本/序号
		if 启用文本转译:
			配置存储[配置名] = 索引转文本[选中索引]  # 旧逻辑：存文本
		else:
			配置存储[配置名] = 选中索引)              # 新逻辑：存序号
## （可选）辅助方法：快速获取节点选项映射（单独调用时用）
#func 获取节点选项映射(节点: OptionButton) -> Dictionary:
	#if not 节点:
		#return {"文本转索引": {}, "索引转文本": {}}
	#var 文本转索引: Dictionary = {}
	#var 索引转文本: Dictionary = {}
	#for 索引 in range(节点.get_item_count()):
		#var 选项文本 = 节点.get_item_text(索引)
		#文本转索引[选项文本] = 索引
		#索引转文本[索引] = 选项文本
	#return {"文本转索引": 文本转索引, "索引转文本": 索引转文本}
