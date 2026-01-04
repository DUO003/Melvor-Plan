extends Control
@onready var 主菜单: Button = %主菜单
@onready var 成就容器: GridContainer = %成就容器
@onready var 成就进度: ProgressBar = %成就进度
@onready var 成就数值: Label = %成就数值
var 成就字典 = {}
var 原始成就字典
var 成就卡片 = preload("res://界面/挂机系统/原罪/成就卡片.tscn").instantiate()
@onready var 悬浮提示: 梅悬浮提示 = %悬浮提示
var 鼠标选中
func _ready() -> void:
	鼠标选中=""
	主菜单.pressed.connect(func():
		var 窗口解锁数组: Array = 计划.梅存档["挂机"].get("窗口解锁",[])
		if 窗口解锁数组.has("原罪界面"):
			计划.切换场景(null,"原罪界面")
		else :
			计划.切换场景(null,"任务窗口"))
	计划.清除子节点(成就容器)
	成就字典 =计划.梅存档["挂机"]["成就"]
	原始成就字典=计划.steam.原始成就字典
	for 成就名称 in 原始成就字典:
		var 克隆卡片:梅成就卡片=成就卡片.duplicate()
		克隆卡片.成就名称=成就名称
		克隆卡片.mouse_entered.connect(func():
			鼠标选中=成就名称
			悬浮提示.更新文本(获取成就文本(成就名称)))
		克隆卡片.mouse_exited.connect(func():
			if 鼠标选中==成就名称:
				悬浮提示.更新文本(""))
		克隆卡片.gui_input.connect(GUI_检查任务完成.bind(成就名称))
		成就容器.add_child(克隆卡片)
	var 已完成数=计划.steam.统计已完成成就数量()
	成就进度.max_value=原始成就字典.size()
	成就进度.value=已完成数
	成就数值.text="%d/%d"%[已完成数,原始成就字典.size()]
func GUI_检查任务完成(按键信号:InputEvent,成就名称):
	if 按键信号 is InputEventMouseButton and 按键信号.pressed:
		if 按键信号.button_index == MOUSE_BUTTON_LEFT:
			if 计划.steam.检查成就(成就名称):
				if not 计划.steam.检查成就解锁(成就名称):
					计划.语法糖通知("奖励已领取过","成就")
					return
				var 任务进度=计划.梅存档["挂机"].get("任务进度",{})
				var 完成状态=任务进度.get(成就名称,0)==1
				if 完成状态:
					计划.语法糖通知("奖励已领取过","成就")
					return
				完成任务(成就名称)
				计划.语法糖通知("成功领取成就","成就")
				计划.更新_UI.emit()
			else :
				计划.语法糖通知("成就未完成","成就")
func 获取成就文本(成就名称)->String:
	var 任务进度=计划.梅存档["挂机"].get("任务进度",{})
	var 完成状态=任务进度.get(成就名称,0)==1
	var 成就数据=计划.steam.原始成就字典[成就名称]
	var 成就文本=成就数据.get("成就介绍","")
	var 前缀=""
	if 完成状态:
		前缀="以领取\r"
	else :
		var 任务全局:Dictionary=计划.任务.任务全局
		if 任务全局.has(成就名称):
			var 任务信息=任务全局[成就名称]
			前缀="完成%.0f%%\r"%(100.0*任务信息["完成总进度"]/任务信息["当前进度列表"].size())
	var 启用标示=计划.steam.启用标示
	if 启用标示 and 成就数据.has("成就标识"):
		前缀+="在steam可解锁\r"
	elif 启用标示:
		前缀+="本地成就\r"
	if 成就文本 is String:
		return 前缀+成就文本
	elif 成就文本 is Array:
		return 前缀+"\n".join(成就文本)
	else :
		return ""
func 完成任务(任务代号):
	计划.删除强调通知.emit(任务代号)
	计划.任务完成处理(任务代号,"null",1)
