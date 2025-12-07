extends 基类梅窗口
var 任务字典:Dictionary={}
var 窗口解锁数组: Array
var 窗口禁用数组: Array
var 任务文本字典
func _ready() -> void:
	super._ready()
	任务字典=计划.梅任务单例.任务字典
	$"内容区域/标签/支线任务/介绍".visible=true
	await 初始化所有任务容器()
	任务栏初始化()
	计划.任务更新.connect(加载任务说明)
	%"启用全屏".button_pressed=计划.配置文件.get("全屏",false)
	%"启用全屏".toggled.connect(func(条件):计划.切换全屏(条件))
	if 计划.跳转设置:
		print("跳转设置成功")
		切换到设置()
func _exit_tree() -> void:
	super._exit_tree()
	计划.跳转设置=false
func 切换到设置():
	%"标签".current_tab=3
func 加载任务说明(任务数组=null):
	#print("信号正确接受",任务数组,任务文本字典)
	if 任务数组==null:
		print("理论上刷新所有任务但现在什么也不做")
	elif 任务数组 is Array:
		for 任务名称 in 任务数组:
			#print("信号正确解析")
			if 任务名称 in 任务文本字典:
				var 字典=任务文本字典[任务名称]["字典"]
				var 文本节点=任务文本字典[任务名称]["节点"]
				解析文本(字典,文本节点,任务名称)
func 加载任务完成统计():
	%"当前完成任务数量".text="当前完成数量:"+str(计划.梅任务单例.完成任务计数("手工"))
func 初始化所有任务容器():
	var 配置={%"任务盒子":["作者","挂机"],%"手工盒子":["手工"]}
	for 容器 in 配置:
		清除子节点(容器)
	任务文本字典={}
	var 默认展开容器=计划.窗口状态管理("任务","默认展开容器","作者")
	var 默认展开任务=计划.窗口状态管理("任务","默认展开任务","新手任务")
	var 红点提示:红点场景=preload("res://界面/插件/红点提示.tscn").instantiate()
	if (默认展开容器=="作者" or 默认展开容器=="挂机") :
		%"标签".current_tab=0
	else :
		%"标签".current_tab=1
		if 默认展开容器=="手工":
			$"内容区域/标签/支线任务/手工".visible=true
	加载任务完成统计()
	for 容器 in 配置:
		var 场景容器: Node = 容器
		for 主容器名 in 任务字典:
			if not 主容器名 in 配置[容器]:
				continue
			var 序号=1
			for 子容器名 in 任务字典[主容器名]:
				var 前置任务=任务字典[主容器名][子容器名].get("前置任务",[])
				var 任务数量=前置任务.size()
				var 任务完成量=0
				var 第一个未完成任务=""
				for 条件 in 前置任务:
					var 前置剧情进度=计划.梅存档["挂机"].get("任务进度",{}).get(条件,0)
					if 前置剧情进度==1:
						任务完成量+=1
					elif 第一个未完成任务=="":
						第一个未完成任务=条件
				#创建折叠容器,如果任务无法显示显示进度条
				var 折叠子容器=FoldableContainer.new()
				if 任务完成量==任务数量:
					折叠子容器=任务节点组合(任务字典[主容器名][子容器名],折叠子容器,子容器名)
				else :
					var 垂直进度条容器 = VBoxContainer.new()
					var 进度条 = ProgressBar.new()
					var 文本节点 = Label.new()
					进度条.min_value = 0  # 最小值
					进度条.max_value = 任务数量  # 最大值
					进度条.step = 1  # 步长
					进度条.value = 任务完成量  # 当前值
					进度条.custom_minimum_size=Vector2(500,50)
					文本节点.text = "前置任务未解锁"+str(任务完成量)+"/"+str(任务数量)+"\n下一个前置任务:"+str(第一个未完成任务)
					垂直进度条容器.add_child(文本节点)  # 加入垂直容器
					垂直进度条容器.add_child(进度条)
					折叠子容器.add_child(垂直进度条容器)
				折叠子容器.folding_changed.connect(func(折叠):
					if not 计划.红点.红点数据.has("任务_"+子容器名):
						计划.红点.红点数据["任务_"+子容器名]=1
						计划.更新红点.emit("任务_"+子容器名)
						折叠子容器.folded=false
						return
					if not 折叠:
						计划.窗口状态管理("任务","默认展开容器",null,主容器名)
						计划.窗口状态管理("任务","默认展开任务",null,子容器名))
				var 剧情进度=计划.梅存档["挂机"].get("任务进度",{}).get(子容器名,0)#初始=0,完成=1,进行中0到1之间
				var 后缀=""
				if 默认展开任务==子容器名:
					折叠子容器.folded=false#展开
				else :
					折叠子容器.folded=true
				if 剧情进度==1:
					后缀="(已完成)"
				elif 计划.红点.获取红点状态("任务_"+子容器名)==1:
					后缀="(进行中)"
					折叠子容器.folded=false#展开
				折叠子容器.title=主容器名+str(序号)+"."+子容器名+后缀
				var 克隆红点:红点场景=红点提示.duplicate()
				克隆红点.红点条目="任务_"+子容器名
				场景容器.add_child(克隆红点)
				场景容器.add_child(折叠子容器)
				序号+=1
func 任务节点组合(字典,容器,任务名称):
	var 水平容器=HBoxContainer.new()
	var 文本节点=RichTextLabel.new()
	var 垂直容器右=VBoxContainer.new()
	var 垂直容器左=VBoxContainer.new()
	var 任务文本=解析文本(字典,文本节点,任务名称)
	文本节点.add_theme_constant_override("paragraph_separation", -10)
	文本节点.custom_minimum_size=Vector2(1490,clamp(任务文本.count("\n")*57+20, 200, 400))
	#print(文本节点.custom_minimum_size)
	垂直容器左.custom_minimum_size=Vector2(1490,200)
	垂直容器右.custom_minimum_size=Vector2(200,200)
	if 计划.梅任务单例.任务全局.has(任务名称):
		var 进度条:梅任务进度条 = 梅任务进度条.new()
		进度条.任务名称=任务名称
		if 字典.get("功能按钮", []).size() >= 1:
			进度条.功能按钮=func():解析功能按钮(字典["功能按钮"],垂直容器右)
		else :
			进度条.功能按钮=func():print("错误缺少功能")
		垂直容器左.add_child(进度条)
	else :
		if 字典.get("功能按钮", []).size() >= 1:
			解析功能按钮(字典["功能按钮"],垂直容器右)
	任务文本字典[任务名称]={}
	任务文本字典[任务名称]["节点"]=文本节点
	任务文本字典[任务名称]["字典"]=字典
	垂直容器左.add_child(文本节点)
	水平容器.add_child(垂直容器左)
	水平容器.add_child(垂直容器右)
	容器.add_child(水平容器)
	return 容器
func 解析文本(字典,文本节点,任务名称):
	var 任务描述数组=字典["任务描述"]
	var 任务文本:String="\n".join(任务描述数组)
	if not 任务文本.find("{当前进度}")==-1 and "进度描述" in 字典:
		var 缓存任务=计划.梅任务单例.任务全局
		if 任务名称 in 缓存任务:
			var 替换文本=字典["进度描述"]
			var 任务当前=缓存任务[任务名称]["当前进度列表"]
			var i=0
			for 条件 in 字典["前置条件"]:
				var 条件文本="{"+条件["条件名称"]+"}"
				替换文本=替换文本.replace(条件文本, str(任务当前[i]))
				条件文本="{"+条件["条件名称"]+"需求}"
				替换文本=替换文本.replace(条件文本, str(条件["目标值"]))
				i+=1
			任务文本 = 任务文本.replace("{当前进度}", 替换文本)
		else :
			任务文本 = 任务文本.replace("{当前进度}", "任务以完成")
	文本节点.text=任务文本
	return 任务文本
func 解析功能按钮(功能数组的数组,容器):
	#print("功能数组的数组:",功能数组的数组,"容器:",容器)
	for 功能数组 in 功能数组的数组:
		var 按钮=Button.new()#目前仅存在按钮一种功能后续可能会追加其他选项
		按钮.text=功能数组[1]
		if 功能数组[0]=="对话":
			按钮.pressed.connect(func():启动对话(功能数组[2]))
		elif 功能数组[0]=="解锁":
			按钮.pressed.connect(func():
				if 计划.梅存档["挂机"].get("任务进度",{}).get(功能数组[2],0)==1:
					计划.语法糖通知("任务奖励已领取","任务提示")
					return
				if 功能数组.size()>=4:
					解锁窗口(功能数组[2],功能数组[3])
				else :
					解锁窗口(功能数组[2]))
		elif 功能数组[0]=="提交":
			按钮.pressed.connect(func():
				if 计划.梅存档["挂机"].get("任务进度",{}).get(功能数组[2],0)==1:
					计划.语法糖通知("任务奖励已完成,无需重复","任务提示")
					return
				if 计划.检查背包物品数量("绿色电路板")>=功能数组[3]:
					计划.语法糖消耗物品("绿色电路板",功能数组[3])
					解锁窗口(功能数组[2]))
		容器.add_child.call_deferred(按钮)
func 解锁窗口(任务代号,参数="null"):
	计划.删除强调通知.emit(任务代号)
	计划.任务完成处理(任务代号,参数,1)
func 启动对话(对话时间线):
	if Dialogic.current_timeline != null:
		return
	var 剧情进度=计划.梅存档["挂机"].get("任务进度",{}).get(对话时间线,0)
	if 剧情进度==0:
		Dialogic.VAR.set("SCJQ", true)#首次剧情=真
	else :
		Dialogic.VAR.set("SCJQ", false)#首次剧情=假
	Dialogic.start(对话时间线)
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
