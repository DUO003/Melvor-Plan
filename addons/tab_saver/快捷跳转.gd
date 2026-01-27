@tool
extends ScrollContainer
var 场景页:GridContainer
var 代码页:GridContainer
var 标签字典: Dictionary = {
	#"空界面": "res://界面/空界面.tscn"
}
#代码字典
@onready var 水平分割: HSplitContainer = %水平分割
@onready var 标签: TabContainer = %标签
@onready var 重新载入: Button = %重新载入
@onready var 载入脚本: Button = %载入脚本
@onready var 文件路径: LineEdit = %文件路径
@onready var 导入表格: Button = %导入表格
var 代码字典: Dictionary={
	"代码教程":["res://代码/专属代码/A代码.gd",""],
	"GBIS":["res://addons/grid_base_inventory_system/core/grid_base_inventory_system.gd",""],
	"插件本体":["res://addons/tab_saver/快捷跳转.gd","#代码字典"],
	"订单数据":["res://代码/专属代码/特殊功能/订单状态.gd",""],
	"BUFF数据":["res://代码/专属代码/特殊功能/BUFF状态.gd",""],
	"梅BUFF":["res://代码/专属代码/特殊功能/BUFF管理.gd",""],
	"任务管理":["res://代码/专属代码/任务专属代码/任务管理.gd",""],
	"标准物品":["res://道具/标准物品.gd",""],
	"手工":["res://代码/挂机逻辑/手工.gd",""],
	"窗口管理":["res://代码/专属代码/特殊功能/窗口管理.gd",""]}
var 按钮宽度:=163
var 按钮高度:=60
@onready var 导入文件名: OptionButton = $水平分割/功能按钮/导入文件名
func _ready() -> void:
	visibility_changed.connect(重新分配区域)
	resized.connect(重新分配区域)
	水平分割.drag_ended.connect(重新分配区域)
	水平分割.dragged.connect(func(_序号):重新分配区域())
	场景页=%"场景页"
	代码页=%"代码页"
	重新载入.pressed.connect(func():
		重新载入场景()
		重新分配区域())
	载入脚本.pressed.connect(func():打开代码文件("res://代码/梅计划.gd","#region 简短单例"))
	导入表格.pressed.connect(func():
		var 转移表格:快速转移表格=快速转移表格.new()
		var 文件名:String=导入文件名.text
		if 转移表格.剪切文件("梅尔沃计划重制数据 - %s.csv"%文件名,"res://表格/",文件路径.text):
			if 文件名=="创世蓝图":
				var 表格检查:json检查器=json检查器.new()
				表格检查.表格初始化()
				表格检查.批量检查JSON格式()
			else :
				print("导入文件",文件名))
			
	重新载入场景()
func 重新分配区域():
	if visible:
		await get_tree().process_frame
		await get_tree().process_frame
		var 真实宽度=(标签.size.x-10)
		场景页.columns=int(真实宽度/按钮宽度)
		代码页.columns=int(真实宽度/按钮宽度)
func 重新载入场景():
	_加载外部界面路径字典()
	for 节点 in 场景页.get_children():
		场景页.remove_child(节点)
		节点.queue_free()
	for 节点 in 代码页.get_children():
		代码页.remove_child(节点)
		节点.queue_free()
	#print(场景页.get_children())
	#遍历场景路径字典，创建多个跳转按钮
	for 键名称 in 标签字典:
		var 按钮:Button =返回按钮()
		按钮.text = 键名称
		按钮.pressed.connect(func(): 打开场景(标签字典[键名称]))
		场景页.add_child(按钮)
	for 键名称 in 代码字典:
		var 按钮:Button =返回按钮()
		按钮.text = 键名称
		按钮.pressed.connect(func(): 打开代码文件(代码字典[键名称][0],代码字典[键名称][1]))
		代码页.add_child(按钮)
func 返回按钮()->Button:
	var 按钮: = Button.new()
	按钮.add_theme_font_size_override("font_size", 20)
	按钮.custom_minimum_size=Vector2(按钮宽度,按钮高度)
	按钮.size=Vector2(按钮宽度,按钮高度)
	按钮.text_overrun_behavior=TextServer.OVERRUN_TRIM_CHAR
	按钮.clip_text=true
	按钮.clip_contents=true
	按钮.size_flags_horizontal=Control.SIZE_EXPAND
	return 按钮
##读取字典失败则使用默认值
func _加载外部界面路径字典() -> void:
	var 窗口管理脚本:梅窗口 = 梅窗口.new()
	var 原始字典 = 窗口管理脚本.界面路径映射#读取脚本中的「界面路径映射」变量
	标签字典={}
	if not 原始字典 or not 原始字典 is Dictionary:
		print("【快捷跳转插件】脚本中未找到有效的「界面路径映射」字典",原始字典)
		return
	#转换字典结构：提取键 + 数组第0项（路径）
	for 界面名称 in 原始字典:
		var 路径数组 = 原始字典[界面名称]
		# 校验数组有效性，且第0项为路径
		if 路径数组 is Array and 路径数组.size() > 0 and not 路径数组[0].is_empty():
			标签字典[界面名称] = 路径数组[0]
		else:
			print("【快捷跳转插件】「", 界面名称, "」的路径配置无效，跳过")
# 按钮点击事件：打开指定场景
func 打开场景(路径: String) -> void:
	if not ResourceLoader.exists(路径):# 增加路径有效性校验
		print("【插件】场景路径不存在：", 路径)
		return
	var 编辑器接口 = EditorInterface
	编辑器接口.open_scene_from_path(路径)
	await get_tree().process_frame
	编辑器接口.set_main_screen_editor("2D")
# 按钮点击事件：打开指定代码文件（.gd）
func 打开代码文件(路径: String,目标备注: String="") -> void:
	# 1. 路径有效性校验
	if not ResourceLoader.exists(路径):
		print("【插件】代码文件路径不存在：", 路径)
		return
	# 可选：校验是否为脚本文件（避免打开非.gd文件）
	if not 路径.ends_with(".gd"):
		print("【插件】路径非GDScript文件：", 路径)
		return
	# 2. 获取编辑器接口并打开脚本
	var 编辑器接口 =  EditorInterface
	# 核心API：打开指定路径的脚本文件
	var 脚本资源: Script = load(路径)
	# 2. 读取脚本源代码，查找目标备注的行号
	var 目标行号: int = -1  # -1表示未找到
	if 脚本资源 != null and 目标备注!="":
		# 获取脚本源代码（内置脚本/外部脚本都适用）
		var 源代码: String = 脚本资源.get_source_code()
		# 按换行拆分所有行（\n 兼容Linux/Mac，\r\n 兼容Windows）
		var 所有行: PackedStringArray = 源代码.split("\n", true)

		# 逐行查找目标备注（忽略大小写/空格可选）
		for 行索引 in 所有行.size():
			var 行内容: String = 所有行[行索引].strip_edges()  # 去除首尾空格
			if 行内容 == 目标备注:  # 精确匹配；若要模糊匹配用 `行内容.contains(目标备注)`
				目标行号 = 行索引+1#+1刚好定位到备注上
				break  # 找到第一个匹配行就停止
	if 目标行号 == -1 and 目标备注!="":
		print("【插件】未找到备注：", 目标备注, "（文件：", 路径, "）")
		目标行号 = 0  # 未找到则定位到第一行
	编辑器接口.edit_script(脚本资源, 目标行号, 0, true)
	# 3. 可选：激活脚本编辑器面板（确保脚本编辑器显示在前台）
	编辑器接口.set_main_screen_editor("Script")
