extends Control
@onready var 系统装备槽: TabContainer = %系统装备槽
@onready var 属性左: RichTextLabel = %属性左
@onready var 属性右: RichTextLabel = %属性右
@onready var 属性详情: CheckButton = %属性详情
@onready var 属性: RichTextLabel = %属性
func _ready() -> void:
	属性详情.button_pressed=计划.窗口状态管理("装备栏","详情",false)
	属性详情.pressed.connect(更新属性)
	系统装备槽.current_tab=计划.窗口状态管理("装备栏","装备页",0)
	系统装备槽.tab_changed.connect(更新属性)
	更新属性()
func 更新属性(_值=null):
	计划.窗口状态管理("装备栏","装备页",null,系统装备槽.current_tab)
	计划.窗口状态管理("装备栏","详情",null,属性详情.button_pressed)
	var 当前标签名 = 系统装备槽.get_tab_title(系统装备槽.current_tab)
	if 属性详情.button_pressed:
		属性.text=计划.装备.战力文本详情(当前标签名)
		属性左.text=""
		属性右.text=""
	else :
		var 用户文本="用户:"+计划.梅存档["挂机"]["用户信息"].get("用户名","玩家")
		var 属性数组:Array=[用户文本]
		if ["游历","手工"].has(当前标签名):
			属性数组+=计划.装备.战力文本更新(当前标签名)
		var 属性数组左:Array=[]
		var 属性数组右:Array=[]
		var 序号:int=0
		for 文本 in 属性数组:
			if 文本 is String:
				if 序号%2==0:属性数组左.append(文本)
				else :属性数组右.append(文本)
				序号+=1
		属性左.text="\r".join(属性数组左)
		属性右.text="\r".join(属性数组右)
		属性.text=""
