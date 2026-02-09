extends 基类梅窗口
@onready var 网格容器: GridContainer = %网格容器
@onready var 提交数量滑块: HSlider = %提交模式
@onready var 显示订单: OptionButton = %显示订单
func _ready() -> void:
	super._ready()
	显示订单.clear()
	显示订单.add_item("显示全部")
	var 最小值:float=0.0 if 计划.技能树.数据技能树("订单提交改良","等级")>=9 else 1.0
	提交数量滑块.min_value=最小值
	提交数量滑块.max_value=计划.技能树.数据技能树("订单提交改良")
	提交数量滑块.value=计划.窗口状态_限制(基类窗口名称,"提交数量",1,提交数量滑块.max_value,提交数量滑块.min_value)
	提交数量滑块.更新刻度()
	提交数量滑块.drag_ended.connect(func(修改:bool=true):
		if 修改:计划.窗口状态管理(基类窗口名称,"提交数量",null,int(提交数量滑块.value)))
	var 研究方向:Array=计划.手工.数据灵感("研究方向")
	print(研究方向)
	for 功能名称 in 研究方向:
		显示订单.add_item(功能名称)
	显示订单.selected=计划.窗口状态_限制(基类窗口名称,"显示订单",0,显示订单.get_item_count())
	显示订单.item_selected.connect(func(序号):
		计划.窗口状态管理(基类窗口名称,"显示订单",null,序号)
		订单筛选())
	加载订单()
	计划.更新玩法.connect(加载订单)
func 订单筛选():
	var 逻辑=显示订单.text
	for 节点:订单卡片 in 网格容器.get_children():
		var 订单数据:梅订单数据=节点.订单数据 as 梅订单数据
		if 订单数据:
			if 逻辑=="显示全部":节点.visible=true
			else:节点.visible=订单数据.订单类型==逻辑
		else :节点.visible=false#不应该有节点不存在这个数据
func 加载订单():
	var 有效订单:Array[梅订单数据] = 计划.任务.打包数据.订单任务
	计划.清除子节点(网格容器)
	var 提交数量:float=提交数量滑块.value
	var 订单卡片实例=preload("res://界面/插件/订单.tscn").instantiate()
	for 订单数据 in 有效订单:
		var 订单场景实例:订单卡片 = 订单卡片实例.duplicate()
		订单场景实例.订单数据 = 订单数据
		订单场景实例.提交数量=clamp(int(提交数量),0,10)
		网格容器.add_child(订单场景实例)
	订单筛选()
