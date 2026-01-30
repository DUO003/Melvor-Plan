extends 基类梅窗口
@onready var 提示: VBoxContainer = %提示
@onready var 最大通知文本: Label = %最大通知文本
@onready var 标签: TabContainer = %标签
func _ready() -> void:
	加载通知()
	计划.通知更新.connect(加载通知)
	计划.过去一秒.connect(func():
		if 通知更新冷却>0:
			通知更新冷却=0
			加载通知())
	任务栏初始化()
var 通知更新冷却:int=0
func 加载通知():
	if 通知更新冷却>2:
		return
	计划.清除子节点(提示)
	最大通知文本.text="最多保留,本次游戏中,最新的%d条通知"%[计划.配置文件.get("最大通知",20)]
	通知更新冷却=true
	var 序号=0
	for 文本 in 计划.历史通知文本列表:
		序号+=1
		var 节点=Label.new()
		节点.text="第%d条通知:"%序号+文本
		提示.add_child(节点)
func 任务栏初始化():
	var 窗口=%"窗口切换按钮模板"
	var 窗口解锁数组 = 计划.梅存档.挂机.窗口解锁
	var 窗口禁用数组 = 计划.梅存档.挂机.窗口禁用
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
			if 计划.节点有效性检查("空节点"):
				计划.节点["空节点"].生成任务栏按钮())
		任务按钮.mouse_entered.connect(func():
			%"窗口名".text="窗口名称:"+界面名称
			处理样式(%"展示按钮",界面名称)
			var 加载简介=计划.窗口.界面简介.get(界面名称,["当前窗口简介丢失"])
			%"窗口介绍".text="简介:\r"+ "\r".join(加载简介) +"\r管理任务栏中显示的按钮")
		%"任务栏盒子".add_child(任务按钮)
	窗口.hide()# 按钮本体初始隐藏
func 处理样式(节点: Button, 界面名称: String) -> void:
	var 纹理地址=计划.窗口.界面路径映射[界面名称]
	if 纹理地址.size()>=1:
		var 纹理 = null
		if not 纹理地址[1]=="":纹理 =load(纹理地址[1])# 1. 加载图片
		var 样式 = 节点.get_theme_stylebox("disabled")
		if 纹理:样式.样式数组[2].texture = 纹理
		else :样式.样式数组[2].texture = null
