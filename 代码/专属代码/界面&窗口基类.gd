extends Control
class_name 基类梅窗口#逐渐改使用基类 当前大部分窗口未使用
@export var 基类窗口名称:String=""#所有继承者必须重写这个
@export_multiline var 提示文本: Array[String] = []#非强制
@export var 选项卡同步: Dictionary[String,TabContainer] = {}
@export var 滚动区同步: Dictionary[String,ScrollContainer] = {}
@export var 生命周期计时器: Array[Timer]
var 主容器窗口:梅主容器窗口
func _ready() -> void:
	if Engine.is_editor_hint() or 基类窗口名称=="演示示例":
		return
	assert(基类窗口名称 != "", "基类窗口名称不能为空，所有继承者必须重写这个属性")
	计划.节点[基类窗口名称]=self#注册
	call_deferred("自动加载")
	计划.场景全局样式.connect(设置样式)
	call_deferred("设置样式")
func 设置样式():
	pass
	#var 标题: ColorRect = %标题
	#var 背景: ColorRect = %背景
	#if 背景 and 标题:
		#var 全局配置字典:Dictionary = ProjectSettings.get_setting("global/snake_case")
		#var 标题色:=Color(计划.配置文件.get("主题标题色", 全局配置字典.get("主题标题色","#86a684"))as String)
		#var 背景色:=Color(计划.配置文件.get("主题背景色", 全局配置字典.get("主题背景色","#d1bb7db4"))as String)
		#标题.color=标题色
		#背景.color=背景色
	#else :
		#print("错误窗口找不到节点:",基类窗口名称)
func 自动加载():
	var 首个焦点:bool=false
	for 选项名称:String in 选项卡同步:
		var 当前选项卡:=选项卡同步[选项名称]
		#当前选项卡.current_tab=计划.窗口状态_限制(基类窗口名称,选项名称,0,当前选项卡.get_tab_count(),0)
		加载选项卡状态(当前选项卡,选项名称)
		if not 首个焦点:
			首个焦点=true
			var 当前控件: TabBar = 当前选项卡.get_tab_bar()
			当前控件.grab_focus()
		当前选项卡.tab_selected.connect(func(序号):计划.窗口状态管理(基类窗口名称,选项名称,null,序号))
	for 选项名称:String in 滚动区同步:
		var 当前滚动区=滚动区同步[选项名称]
		当前滚动区.scroll_horizontal=计划.窗口状态管理(基类窗口名称,选项名称+"水平",0)
		当前滚动区.scroll_vertical=计划.窗口状态管理(基类窗口名称,选项名称+"垂直",0)
		var 水平=当前滚动区.get_h_scroll_bar()
		var 垂直=当前滚动区.get_v_scroll_bar()
		水平.mouse_exited.connect(func():保存滚动区(当前滚动区,选项名称))
		垂直.mouse_exited.connect(func():保存滚动区(当前滚动区,选项名称))
func 加载选项卡状态(选项卡:TabContainer,名称:String):
	选项卡.tab_focus_mode = Control.FOCUS_ALL
	选项卡.focus_mode = Control.FOCUS_CLICK
	选项卡.focus_entered.connect(_将焦点转移到当前标签.bind(选项卡))
	var 标签=计划.窗口状态管理(基类窗口名称,名称,null)
	if 标签 is int and 标签>=0 and 标签<选项卡.get_tab_count():#检查是合法标签,例如上个版本保存的值
		选项卡.current_tab=标签
		return
	elif 标签 is String:
		var 匹配失败 = true
		for i in range(选项卡.get_tab_count()):
			var 当前标签名 = 选项卡.get_tab_title(i)
			if 当前标签名 == 标签:
				标签 = i
				匹配失败 = false
				break
		if 匹配失败:
			print(选项卡,名称,"标签匹配失败:",标签)
			标签 = 0#文本不合法
	else :标签 = 0#标签超出合法范围
	计划.窗口状态管理(基类窗口名称,名称,null,标签)
	选项卡.current_tab=标签#非法值默认参数
func _将焦点转移到当前标签(选项卡:TabContainer) -> void:
	var 标签栏: = 选项卡.get_tab_bar()
	if 标签栏 == null:
		print("错误：无法获取标签栏")
		return
	标签栏.grab_focus()# 将焦点转移到标签栏
func 保存滚动区(当前滚动区:ScrollContainer,选项名称:String):
	计划.窗口状态管理(基类窗口名称,选项名称+"水平",null,当前滚动区.scroll_horizontal)
	计划.窗口状态管理(基类窗口名称,选项名称+"垂直",null,当前滚动区.scroll_vertical)
	#print("已保存",当前滚动区.scroll_vertical,当前滚动区.scroll_horizontal)
func _exit_tree() -> void:
	if 计划.节点.has(基类窗口名称):# 安全检查：确保字典中存在该键再移除
		计划.节点.erase(基类窗口名称)
	for 计时器 in 生命周期计时器:
		计时器.queue_free()
	for 选项名称:String in 滚动区同步:
		保存滚动区(滚动区同步[选项名称],选项名称)
func 清除子节点(节点容器,保留节点=null):
	计划.清除子节点(节点容器,保留节点)#用的太多了,移动到全局代码更方便
func 定期更新提示文本(目标文本节点):
	if 目标文本节点 == null:
		return
	elif 提示文本.size() == 0:
		目标文本节点.text = "温馨提示"
		return
	elif 提示文本.size() == 1:
		目标文本节点.text = 提示文本[0]
		return
	var 当前显示文本 = 目标文本节点.text# 4. 数组有多条文本时，选择与当前文本不同的提示
	var 可选提示列表 = 提示文本.filter(func(单条提示):# 过滤出与当前文本不同的可选提示
		return 单条提示 != 当前显示文本)
	if 可选提示列表.size() > 0:# 5. 从可选提示中随机选择一条（若所有提示都与当前相同，则随机选数组中任意一条）
		var 随机索引 = randi() % 可选提示列表.size()
		目标文本节点.text = 可选提示列表[随机索引]
	else:# 极端情况：数组所有元素相同（虽不符合常规，但做兼容处理）
		目标文本节点.text = 提示文本[0]
func 节点有效性检查(节点名称:String)->bool:
	return 节点名称 in 计划.节点 and 计划.节点[节点名称] != null
func 窗口最大化(状态:bool)->bool:
	if 状态:
		set_size(Vector2(1900,970))
		set_position(Vector2(10,110))
	else :
		set_size(Vector2(1660,880))
		set_position(Vector2(20,120))
	return true
func _input(按键: InputEvent) -> void:
	if 按键.is_action_pressed("返回菜单"):
		# 获取你的任务栏容器
		var 当前焦点节点: Control = get_viewport().gui_get_focus_owner()
		if not 当前焦点节点 or 当前焦点节点.is_in_group(基类窗口名称):
			var 任务栏节点: VBoxContainer = 主容器窗口.任务栏节点
			# 安全判断：容器存在 + 有子节点
			if 任务栏节点 != null and 任务栏节点.get_child_count() > 0:
				# 获取第一个子节点
				var 第一个子控件 = 任务栏节点.get_child(0)
				
				# 再次安全判断：必须是 Control 才能获得焦点
				if 第一个子控件 is Control:
					第一个子控件.grab_focus()  # 把焦点给它
