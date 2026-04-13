extends 基类梅窗口
var 任务字典:Dictionary=计划.任务.任务字典
@onready var 任务盒子: 任务栏插件 = %"主线任务"
@onready var 循环盒子: 任务栏插件 = %"循环任务"
@onready var 下拉任务: OptionButton = %显示任务
@onready var 切换以完成: CheckButton = %以完成任务
@onready var 任务选项卡: TabContainer = %任务
@onready var 订单按钮: Button = %订单按钮
@onready var 成就按钮: Button = %成就按钮
@onready var 背包按钮: Button = %背包按钮
@onready var 设置按钮: Button = %设置按钮
var 任务的卡片:任务卡片=preload("res://界面/挂机系统/任务窗口/任务卡片.tscn").instantiate()
func _ready() -> void:
	super._ready()
	下拉任务.clear()
	for 序号 in 3:
		下拉任务.add_item(tr("显示%d个")%(序号+1))
	var 显示任务数量=计划.窗口状态管理(基类窗口名称,"显示任务数量",1)#需要先获取值
	下拉任务.selected=显示任务数量 if 显示任务数量 is int and 显示任务数量>=0 and 显示任务数量<=2 else 1
	var 以完成任务=计划.窗口状态管理(基类窗口名称,"以完成任务",false)
	切换以完成.button_pressed = 以完成任务 if 以完成任务 is bool else true
	切换以完成.pressed.connect(func():
		计划.窗口状态管理(基类窗口名称,"以完成任务",null,切换以完成.button_pressed)
		初始化所有任务容器(true))
	下拉任务.item_selected.connect(func(序号):
		计划.窗口状态管理(基类窗口名称,"显示任务数量",null,序号)
		初始化所有任务容器(true))
	订单按钮.pressed.connect(计划.切换场景.bind("订单界面"))
	成就按钮.pressed.connect(计划.切换场景.bind("原罪_傲慢界面"))
	背包按钮.pressed.connect(计划.切换场景.bind("背包界面"))
	设置按钮.pressed.connect(计划.切换场景.bind("设置界面"))
	初始化所有任务容器()
	计划.更新_UI.connect(加载任务完成统计)
func _exit_tree() -> void:
	super._exit_tree()
@onready var 任务板主线: 梅任务面板 = %任务板主线
@onready var 任务板循环: 梅任务面板 = %任务板循环
@onready var 任务板订单: 梅任务面板 = %任务板订单
@onready var 任务板成就: 梅任务面板 = %任务板成就
@onready var 任务统计: ScrollContainer = %任务统计
@onready var 任务板容器: GridContainer = %任务板容器

func 加载任务完成统计():
	var 打包数据:任务打包资源=计划.任务.打包数据
	var 点数:=计划.点数
	var 统计任务完成:Array=[]
	for 任务 in ["作者","挂机","手工"]:
		统计任务完成.append(完成任务计数(任务))
	任务板主线.text=tr("<键_主线任务介绍>")%["\n".join(统计任务完成),]
	任务板循环.text=tr("<键_循环任务介绍>")%[计划.表格.道具贴图("熟练").resource_path,
		打包数据.已完成循环任务,打包数据.循环任务数量,打包数据.循环任务难度,点数.查看点数("任务")]
	任务板订单.text=tr("<键_订单任务介绍>")%[",".join(打包数据.返回翻译标签()),打包数据.订单任务数量]
	任务板成就.text=tr("<键_成就任务介绍>")%[计划.表格.道具贴图("傲慢").resource_path,计划.steam.成就字典.size()]
	var 任务宽度:float=size.x-120
	var 间距:float= 任务板容器.get_theme_constant("h_separation")
	var 任务版宽度:float=(任务宽度-(间距*任务板容器.columns)+间距)/任务板容器.columns
	for 任务版: 梅任务面板 in [任务板主线,任务板循环,任务板订单,任务板成就]:
		任务版.custom_minimum_size.x=任务版宽度
	#任务板容器.queue_sort()
	print("任务版宽度%d/%d"%[任务版宽度,任务宽度])
func 完成任务计数(任务)->String:
	var 来源数组:Array[任务资源]=计划.任务.筛选任务来源资源(任务)
	var 完成次数:int = 0  # 统计满足条件的任务数量
	for 任务数据 in 来源数组:
		if 任务数据.任务完成:
			完成次数 += 1  # 每满足一个，次数+1
	return tr("<任务完成数量>")%[tr(任务),完成次数,来源数组.size()]
func 初始化所有任务容器(刷新:bool=false):
	计划.显示后执行(加载任务完成统计,任务板容器)
	for 容器:任务栏插件 in [任务盒子,循环盒子]:
		容器.以完成任务=切换以完成.button_pressed
		容器.显示任务数量=下拉任务.selected+1
		if 刷新:计划.显示后执行(容器.刷新任务显示,容器)
func 窗口最大化(状态:bool)->bool:
	super(状态)
	初始化所有任务容器(true)
	return true
