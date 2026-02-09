extends 基类梅窗口
var 任务字典:Dictionary=计划.任务.任务字典
@onready var 任务盒子: 任务栏插件 = %"主线任务"
@onready var 循环盒子: 任务栏插件 = %"循环任务"
@onready var 下拉任务: OptionButton = %显示任务
@onready var 切换以完成: CheckButton = %以完成任务
@onready var 任务选项卡: TabContainer = %任务
@onready var 成就按钮: Button = %成就按钮
var 任务的卡片:任务卡片=preload("res://界面/挂机系统/任务窗口/任务卡片.tscn").instantiate()
func _ready() -> void:
	super._ready()
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
	成就按钮.pressed.connect(func():计划.切换场景("原罪_傲慢界面"))
	初始化所有任务容器()
func _exit_tree() -> void:
	super._exit_tree()
@onready var 任务数量: RichTextLabel = %任务数量
func 加载任务完成统计():
	var 统计任务完成:Array=[]
	for 任务 in ["作者","挂机","手工"]:
		统计任务完成.append(完成任务计数(任务))
	任务数量.text="主线任务\n[font_size=35]消耗循环任务次数\n完成主线任务解锁新玩法[/font_size]
[font_size=30]%s[/font_size]\r循环任务
[font_size=35]完成任务获取[img=35x35]%s[/img][/font_size]\r订单任务"%["\n".join(统计任务完成),
计划.表格.道具贴图("熟练").resource_path]
func 完成任务计数(任务)->String:
	var 来源数组:Array[任务资源]=计划.任务.筛选任务来源资源(任务)
	var 完成次数:int = 0  # 统计满足条件的任务数量
	for 任务数据 in 来源数组:
		if 任务数据.任务完成:
			完成次数 += 1  # 每满足一个，次数+1
	return "	%s完成数量:%d/%d"%[任务,完成次数,来源数组.size()]
func 初始化所有任务容器(刷新:bool=false):
	加载任务完成统计()
	for 容器:任务栏插件 in [任务盒子,循环盒子]:
		容器.以完成任务=切换以完成.button_pressed
		容器.显示任务数量=下拉任务.selected+1
		if 刷新:容器.刷新任务显示()
