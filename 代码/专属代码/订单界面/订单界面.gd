extends 基类梅窗口
var 网格容器:GridContainer
var 显示订单:OptionButton
var 提交数量滑块:HSlider
func _ready() -> void:
	super._ready()
	计划.数据订单("时间戳")
	显示订单=%"显示订单"
	显示订单.clear()
	显示订单.add_item("显示全部")
	提交数量滑块=%"提交模式"
	var 最小值:float=0.0 if 计划.数据技能树("订单提交改良","等级")>=9 else 1.0
	print(计划.数据技能树("订单提交改良","等级"),"订单提交改良")
	提交数量滑块.min_value=最小值
	提交数量滑块.max_value=计划.数据技能树("订单提交改良")
	提交数量滑块.value=计划.窗口状态_限制(基类窗口名称,"提交数量",1,提交数量滑块.max_value,提交数量滑块.min_value)
	提交数量滑块.更新刻度()
	提交数量滑块.drag_ended.connect(func(修改:bool=true):
		if 修改:计划.窗口状态管理(基类窗口名称,"提交数量",null,int(提交数量滑块.value)))
	for 功能名称 in 计划.订单参数["订单类型"]:
		显示订单.add_item(功能名称)
	显示订单.selected=计划.窗口状态_限制(基类窗口名称,"显示订单",0,显示订单.get_item_count())
	显示订单.item_selected.connect(func(序号):
		计划.窗口状态管理(基类窗口名称,"显示订单",null,序号)
		订单筛选()
		)
	网格容器=%"网格容器"
	加载订单()
	计划.更新玩法.connect(加载订单)
	%"手动刷新".pressed.connect(func(): 手动刷新订单())
func 订单筛选():
	var 逻辑=显示订单.text
	for 节点:订单卡片 in 网格容器.get_children():
		var 订单数据:梅订单数据=节点.订单数据 as 梅订单数据
		if 订单数据:
			if 逻辑=="显示全部":节点.visible=true
			else:节点.visible=订单数据.订单类型==逻辑
		else :节点.visible=false#不应该有节点不存在这个数据
func 手动刷新订单():
	if 计划.体力门票(5):
		计划.数据订单("订单数量",1,-1)
		计划.更新_UI.emit()
	else :计划.语法糖通知("体力不足","体力通知")
func 加载订单():
	var 有效订单 = 计划.数据订单("订单存档")
	计划.清除子节点(网格容器)
	var 提交数量:float=提交数量滑块.value
	var 订单卡片实例=preload("res://界面/插件/订单.tscn").instantiate()
	for 订单数据 in 有效订单:
		var 订单场景实例:订单卡片 = 订单卡片实例.duplicate()
		订单场景实例.订单数据 = 订单数据
		订单场景实例.提交数量=clamp(int(提交数量),0,10)
		网格容器.add_child(订单场景实例)
	订单筛选()
