extends 基类梅窗口
var 任务字典:Dictionary={}
var 窗口解锁数组: Array
var 窗口禁用数组: Array
var 任务文本字典
var 配置
func _ready() -> void:
	配置={%"任务盒子":["作者","挂机"],%"手工盒子":["手工"]}
	super._ready()
	任务字典=计划.任务.任务字典
	var 显示任务数量=计划.窗口状态管理(基类窗口名称,"显示任务数量",1)#需要先获取值
	%"显示任务".selected=显示任务数量 if 显示任务数量 is int and 显示任务数量>=0 and 显示任务数量<=2 else 1
	var 以完成任务=计划.窗口状态管理(基类窗口名称,"以完成任务",true)
	%"以完成任务".button_pressed = 以完成任务 if 以完成任务 is bool else true
	await 初始化所有任务容器()
	任务栏初始化()
	%"以完成任务".pressed.connect(func():
		计划.窗口状态管理(基类窗口名称,"以完成任务",null,%"以完成任务".button_pressed)
		刷新任务显示())
	%"显示任务".item_selected.connect(func(序号):
		计划.窗口状态管理(基类窗口名称,"显示任务数量",null,序号)
		刷新任务宽度())
	%"标签".tab_clicked.connect(func(标签序号):计划.窗口状态管理(基类窗口名称,"标签",null,标签序号))
	%"支线任务".tab_clicked.connect(func(标签序号):计划.窗口状态管理(基类窗口名称,"支线任务",null,标签序号))
	if 计划.跳转设置:
		print("跳转设置成功")
		切换到设置()
func _exit_tree() -> void:
	super._exit_tree()
	计划.跳转设置=false
func 切换到设置():
	%"标签".current_tab=3
func 加载任务完成统计():
	%"当前完成任务数量".text="当前完成数量:"+str(计划.任务.完成任务计数("手工"))
func 加载窗口状态(选项卡:TabContainer,名称:String):
	var 标签=计划.窗口状态管理(基类窗口名称,名称,0)#这里的0是假设存档没有数据返回值
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
func 刷新任务宽度():
	var 显示任务数量=%"显示任务".selected+1
	if 显示任务数量<1:显示任务数量=1
	var 任务宽度=(1680-显示任务数量*10+10)/显示任务数量#水平间距10
	for 容器 in 配置:
		var 场景容器: GridContainer = 容器
		场景容器.columns=显示任务数量
		for 任务卡 in 场景容器.get_children():
			任务卡.custom_minimum_size.x=任务宽度
func 刷新任务显示():
	#print("以完成任务隐藏逻辑触发")
	var 以完成任务=%"以完成任务".button_pressed
	for 容器 in 配置:
		for 任务卡 in 容器.get_children():
			if 任务卡 is 任务卡片:
				if 以完成任务:任务卡.visible=true
				else:if 任务卡.任务进度==1:任务卡.visible=false
				else :任务卡.visible=true
func 初始化所有任务容器():
	for 容器 in 配置:
		清除子节点(容器)
	任务文本字典={}
	var 任务的卡片:任务卡片=preload("res://界面/挂机系统/任务窗口/任务卡片.tscn").instantiate()
	加载任务完成统计()
	加载窗口状态(%"标签","标签")
	加载窗口状态(%"支线任务","支线任务")
	var 显示任务数量=%"显示任务".selected+1
	if 显示任务数量<1:显示任务数量=1
	var 任务宽度=(1660-显示任务数量*10+10)/显示任务数量#水平间距10
	for 容器 in 配置:
		var 场景容器: GridContainer = 容器
		场景容器.columns=显示任务数量
		for 主容器名 in 任务字典:
			if not 主容器名 in 配置[容器]:continue
			var 序号=1
			for 任务名称 in 任务字典[主容器名]:
				var 任务卡=任务的卡片.duplicate()
				任务卡.custom_minimum_size.x=任务宽度
				任务卡.任务名称=任务名称
				任务卡.任务类型=主容器名
				任务卡.任务详情=任务字典[主容器名][任务名称]
				任务卡.任务序号=序号
				任务卡.初始化任务()
				场景容器.add_child(任务卡)
	刷新任务显示()
func 任务栏初始化():
	var 窗口=%"窗口切换按钮模板"
	窗口解锁数组 = 计划.梅存档["挂机"].get("窗口解锁",[])
	窗口禁用数组 = 计划.梅存档["挂机"].get("窗口禁用",[])
	计划.梅存档["挂机"]["窗口禁用"]=窗口禁用数组
	if not 窗口解锁数组.has("任务窗口"):
		窗口解锁数组.append("任务窗口")
	for 界面名称 in 窗口解锁数组:
		var 任务按钮: CheckButton = 窗口.duplicate()
		任务按钮.show()#防止节点为隐藏
		任务按钮.text = 界面名称.replace("界面", "").replace("窗口", "")
		任务按钮.button_pressed=not 窗口禁用数组.has(窗口)
		任务按钮.pressed.connect(func(): 
			var 按钮状态= 任务按钮.button_pressed
			if 按钮状态 and 窗口禁用数组.has(界面名称):
				窗口禁用数组.erase(界面名称)
			if not 按钮状态 and not 窗口禁用数组.has(界面名称):
				窗口禁用数组.append(界面名称)
			if "空节点" in 计划.节点 and 计划.节点["空节点"] != null:
				计划.节点["空节点"].生成任务栏按钮()
				)
		任务按钮.mouse_entered.connect(func():
			%"窗口名".text="窗口名称:"+界面名称
			处理样式(%"展示按钮",界面名称)
			var 加载简介=计划.窗口.界面简介.get(界面名称,["当前窗口简介丢失"])
			%"窗口介绍".text="简介:\r"+ "\r".join(加载简介) +"\r管理任务栏中显示的按钮"
			)
		%"任务栏盒子".add_child(任务按钮)
	窗口.hide()# 按钮本体初始隐藏
func 处理样式(节点: Button, 界面名称: String) -> void:
	var 纹理地址=计划.窗口.界面路径映射[界面名称]
	if 纹理地址.size()>=1:
		var 纹理 = null
		if not 纹理地址[1]=="":纹理 =load(纹理地址[1])# 1. 加载图片
		var 样式 = 节点.get_theme_stylebox("disabled")
		if 纹理:
			样式.样式数组[2].texture = 纹理
		else :
			样式.样式数组[2].texture = null
