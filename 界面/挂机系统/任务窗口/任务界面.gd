extends 基类梅窗口
var 任务字典:Dictionary=计划.任务.任务字典
var 任务文本字典
var 配置
@onready var 任务盒子: GridContainer = %任务盒子
@onready var 手工盒子: GridContainer = %手工盒子
@onready var 下拉任务: OptionButton = %显示任务
@onready var 切换以完成: CheckButton = %以完成任务
@onready var 任务选项卡: TabContainer = %任务
@onready var 成就按钮: Button = %成就按钮
var 任务的卡片:任务卡片=preload("res://界面/挂机系统/任务窗口/任务卡片.tscn").instantiate()
func _ready() -> void:
	配置={任务盒子:["作者","挂机"],手工盒子:["手工"]}
	super._ready()
	var 显示任务数量=计划.窗口状态管理(基类窗口名称,"显示任务数量",1)#需要先获取值
	下拉任务.selected=显示任务数量 if 显示任务数量 is int and 显示任务数量>=0 and 显示任务数量<=2 else 1
	var 以完成任务=计划.窗口状态管理(基类窗口名称,"以完成任务",false)
	切换以完成.button_pressed = 以完成任务 if 以完成任务 is bool else true
	await 初始化所有任务容器()
	切换以完成.pressed.connect(func():
		计划.窗口状态管理(基类窗口名称,"以完成任务",null,切换以完成.button_pressed)
		刷新任务显示())
	下拉任务.item_selected.connect(func(序号):
		计划.窗口状态管理(基类窗口名称,"显示任务数量",null,序号)
		刷新任务宽度())
	成就按钮.pressed.connect(func():计划.切换场景("原罪_傲慢界面","原罪界面"))
func _exit_tree() -> void:
	super._exit_tree()
@onready var 任务完成数标签: Label = %当前完成任务数量
func 加载任务完成统计():
	任务完成数标签.text="当前完成数量:"+str(计划.任务.完成任务计数("手工"))
func 刷新任务宽度():
	var 显示任务数量:int=下拉任务.selected+1
	if 显示任务数量<1:显示任务数量=1
	var 任务宽度=(1680-显示任务数量*10+10.0)/显示任务数量#水平间距10
	for 容器 in 配置:
		var 任务卡片容器: GridContainer = 容器
		任务卡片容器.columns=显示任务数量
		for 任务卡 in 任务卡片容器.get_children():
			任务卡.custom_minimum_size.x=任务宽度
func 刷新任务显示():
	#print("以完成任务隐藏逻辑触发")
	var 以完成任务=切换以完成.button_pressed
	for 容器 in 配置:
		for 任务卡 in 容器.get_children():
			if 任务卡 is 任务卡片:
				if 以完成任务:任务卡.visible=true
				else:if 任务卡.数据.任务完成:任务卡.visible=false
				else :任务卡.visible=true
func 初始化所有任务容器():
	for 容器 in 配置:
		清除子节点(容器)
	任务文本字典={}
	加载任务完成统计()
	var 唯一任务字典=计划.任务.唯一任务字典
	var 显示任务数量=下拉任务.selected+1
	if 显示任务数量<1:显示任务数量=1
	var 任务宽度=(1660-显示任务数量*10+10.0)/显示任务数量#水平间距10
	for 容器 in 配置:
		var 任务卡片容器: GridContainer = 容器
		任务卡片容器.columns=显示任务数量
		for 任务名称 in 任务字典:
			var 任务类型=任务字典[任务名称].get("来源",null)
			if not 任务类型 in 配置[容器]:continue
			var 序号=1
			var 任务卡=任务的卡片.duplicate()
			任务卡.custom_minimum_size.x=任务宽度
			任务卡.数据=唯一任务字典.get(任务名称,null)
			任务卡.任务序号=序号
			任务卡.初始化任务()
			任务卡片容器.add_child(任务卡)
	刷新任务显示()
