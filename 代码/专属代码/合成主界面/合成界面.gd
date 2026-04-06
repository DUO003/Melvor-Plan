extends 基类梅窗口
var 资源每秒 = {"木材":1, "矿石":1, "皮革":1, "药草":1}
var 制作队列节点:Array[梅自动化进度条]=[]
# 存储最近一分钟内的帧间隔数据
var 帧率数据: Array[float] = []
# 累计最近一分钟的总时间（用于快速判断是否超过60秒）
var 总时间: float = 0.0
# 计算得到的一分钟平均帧率
var 平均帧率: float = 0.0
var 类型="基础素材"
var 筛选器条件:Array=[]
@onready var 研究方向: OptionButton = %研究方向
@onready var 等阶: OptionButton = %等阶
@onready var 检索: LineEdit = %检索
@onready var 更新: TextureButton = %更新
@onready var 已解锁: CheckButton = %已解锁
@onready var 物质加点:ScrollContainer = %物质加点

func _ready() -> void:
	super._ready()#注册
	类型=计划.窗口状态管理(基类窗口名称,"类型","所有类型")
	研究方向.item_selected.connect(func(_序号):生成配方节点(研究方向.text))
	已解锁.button_pressed=计划.窗口状态管理(基类窗口名称,"仅显示已解锁",false)
	已解锁.pressed.connect(func():
		计划.窗口状态管理(基类窗口名称,"仅显示已解锁",null,已解锁.button_pressed)
		生成配方节点())
	检索.text=""
	更新.pressed.connect(func():生成配方节点())
	等阶.item_selected.connect(func(_序号):
		计划.窗口状态管理(基类窗口名称,"阶级条件",null,等阶.selected)
		生成配方节点())
	生成筛选器(计划.窗口状态管理(基类窗口名称,"阶级条件",0))
	计划.手工.处理资源回复()#资源回复逻辑
	计划.处理时间戳(计划.梅存档["手工"])#熟练度逻辑
	生命周期计时器+=[计划.创建计时器(1.0, Callable(self, "更新信息"))]#更新在线合成结算的精通熟练显示信息
	生命周期计时器+=[计划.创建计时器(8,func(): 定期更新提示文本(%"温馨提示"))]#每隔8秒更新一次文本
	定期更新提示文本(%"温馨提示")
	计划.更新_UI.connect(_更新_UI)
	计划.更新玩法.connect(生成筛选器)
	%动作进度条.开始动作("资源回复",5.0,self)
	清空制作队列()
	注册按钮()
	_更新_UI()
func _process(delta: float) -> void:
	更新制作队列进度条()
	帧率数据.append(delta)# 1. 记录当前帧的间隔时间
	总时间 += delta
	while 总时间 > 60.0:# 2. 移除超过1分钟的旧数据
		var  oldest_delta = 帧率数据.pop_front()  # 移除最早的帧数据
		总时间 -= oldest_delta
	if 总时间 > 0:# 3. 计算平均帧率（总帧数 / 总时间）
		var 原始帧率 = 帧率数据.size() / 总时间
		平均帧率 = round(原始帧率 * 10) / 10  # 保留1位小数（精度0.1）
	else:
		平均帧率 = 0.0
func _exit_tree() -> void:
	super._exit_tree()
func 生成筛选器(阶级赋值=-1):
	if 阶级赋值==-1:
		阶级赋值=等阶.selected
	筛选器条件=["所有类型", "基础素材", "特殊"]
	for 项 in 计划.手工.数据灵感("研究方向"):
		if not 筛选器条件.has(项):
			筛选器条件.append(项)
	if not 筛选器条件.has(类型):类型="所有类型"
	研究方向.clear()
	等阶.clear()
	for 内容 in 筛选器条件:
		研究方向.add_item(内容)
		if 类型==内容:研究方向.selected=研究方向.get_item_count()-1
	var 等阶数组=["不限制"]
	var 阶级=计划.数据系统("手工","阶级")
	if 计划.装备.制作力>=阶级*(阶级+1):
		阶级+=1
	for i in range(min(20,阶级)):
		等阶数组.append(str(i+1)+"阶")
	for 内容 in 等阶数组:
		等阶.add_item(内容)
	等阶.selected=阶级赋值
	生成配方节点()
@onready var 配方表格: VBoxContainer = %配方表格
func 生成配方节点(类型名称=类型):
	if not 类型==类型名称:
		类型=类型名称
		计划.窗口状态管理(基类窗口名称,"类型",null,类型)
	清除子节点(配方表格)
	if 类型=="所有类型":
		for 项 in 筛选器条件:
			if not 项=="所有类型":克隆按钮(项)
	else :克隆按钮(类型)
func 克隆按钮(项):
	var 标签=Label.new()
	标签.text="%s类型"%项
	配方表格.add_child(标签)
	var 配方列表:Array=[]
	var 表格=GridContainer.new()
	表格.add_theme_constant_override("h_separation", -4)
	表格.add_theme_constant_override("v_separation", 0)
	表格.columns=8
	配方表格.add_child(表格)
	if 等阶.text=="不限制":
		配方列表 = 计划.获取配方(项,ceili(计划.数据系统("手工","等级") / 5.0),1)
	else :
		配方列表 = 计划.获取配方(项,等阶.selected,等阶.selected)
	配方表格.克隆配方节点(配方列表,表格)
func 注册按钮():
	%强化.pressed.connect(func(): 计划.切换场景("合成_强化界面"))
	%抽奖机.pressed.connect(func(): 计划.切换场景("合成_抽奖机界面"))
	%蓝图库.pressed.connect(func(): 计划.切换场景("合成_蓝图库界面"))
	#print("按钮已注册")
func 更新信息():
	#print ("更新信息触发")
	var 熟练值:float = 计划.精通收益(计划.处理时间戳(计划.梅存档["手工"]))
	熟练值*=(1+0.1*计划.梅存档["挂机"].get("等级",0))
	%提示文本.text="暂存熟练\r%.0f\rfps:%.0f" % [熟练值, 平均帧率]
	pass
var 自动化进度:梅自动化进度条 = preload("res://界面/手工系统/合成/自动化进度.tscn").instantiate()
@onready var 制作队列: HBoxContainer = %制作队列
func 清空制作队列():
	计划.清除子节点(制作队列)
	制作队列节点=[]
func 注册进度条():
	var 队列上限=计划.手工.队列合成("制作队列上限")
	if 制作队列节点.size()>队列上限:
		清空制作队列()
	if 自动化进度:
		var 制作队列数组:Array = 计划.手工.队列合成()
		for i in range(队列上限):
			var 克隆节点:梅自动化进度条
			if i < 制作队列节点.size():
				克隆节点 = 制作队列节点[i]
			else:
				克隆节点 = 自动化进度.duplicate()
				%制作队列.add_child(克隆节点)
				制作队列节点.append(克隆节点)
				克隆节点.更新进度(0.0)
				克隆节点.配方贴图.mouse_entered.connect(func():
					计划.数据包提示.emit(加载队列文本(i,克隆节点)))
				克隆节点.配方贴图.mouse_exited.connect(func():
					计划.全局悬浮提示.emit("",克隆节点,30))
				克隆节点.取消.gui_input.connect(func(按键信号):
					if 按键信号 is InputEventMouseButton and 按键信号.pressed:
						制作队列更新(按键信号,i))
			if i < 制作队列数组.size():
				var 配方的名称:String=制作队列数组[i] as String
				克隆节点.传入配方参数(配方的名称)
			else :
				克隆节点.传入配方参数()
func 加载队列文本(队列序号:int,节点:Node)->梅提示数据:
	var 提示数据:梅提示数据=梅提示数据.new()
	提示数据.节点=节点
	var 制作参数=计划.手工.队列合成("制作参数")
	提示数据.队列消息(制作参数,队列序号)
	return 提示数据
func _更新_UI():
	更新信息()
	注册进度条()
	for 资源 in %"资源管理器".get_children():# 循环处理每个资源的UI更新
		if 资源 is 资源进度条:
			资源.更新UI()
func 处理动作(_动作名称):
	计划.手工.处理资源回复()


func 更新制作队列进度条():#仅处理显示效果
	计划.手工.更新制作队列进度条()
	var 制作队列数组=计划.手工.队列合成("制作参数")
	var 序号=0
	for 节点 in 制作队列节点:
		if 节点:
			if 序号+1>制作队列数组.size():节点.更新进度(-1)
			else :
				var 制作时长=制作队列数组[序号]["制作时长"]
				var 时间差=Time.get_unix_time_from_system()-制作队列数组[序号]["时间戳"]
				节点.更新进度(1.0*时间差/制作时长)
			序号+=1
func 制作队列更新(按键信号:InputEventMouseButton,i:int):
	if 按键信号.button_index == MOUSE_BUTTON_LEFT:
		计划.语法糖通知( "合成队列可以右键移除","手工提示")
	elif 按键信号.button_index == MOUSE_BUTTON_RIGHT:
		var 制作队列数组 = 计划.手工.队列合成()# 获取当前制作队列
		if i >= 0 and i < 制作队列数组.size():# 检查索引是否有效（在数组范围内）
			var 装备名称 = 制作队列数组[i]
			计划.手工.队列合成("制作队列",装备名称)
			if 制作队列节点.size()>i:
				var 配方节点 = 制作队列节点[i].get_node("配方")
				计划.数据包提示.emit(加载队列文本(i,配方节点))
		# 索引无效时什么也不做
	else :
		pass
