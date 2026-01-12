extends 基类梅窗口
var 金币=计划.梅存档["金币"]
var 物品:ItemData=null
var 背包="背包"
var 上次查看:={}
var 物品栏选项卡:TabContainer
var 状态区:TabContainer
@onready var 装备槽: Control = %装备槽
func _ready():
	super._ready()
	状态区=%"状态区"
	物品栏选项卡=%"物品栏选项卡"
	物品栏选项卡.set_tab_title(0, "物品栏")
	物品栏选项卡.current_tab=计划.窗口状态_限制(基类窗口名称,"物品栏选项卡",0,物品栏选项卡.get_tab_count())
	状态区.current_tab=计划.窗口状态_限制(基类窗口名称,"状态区",0,状态区.get_tab_count())
	计划.connect("更新_UI", Callable(self, "_更新_UI"))
	计划.更新_背包物品信息.connect(_背包物品信息)
	_更新_UI()
	%"无选中".visible=true
	%"选中".visible=false
	%"随身商店".visibility_changed.connect(func():if %"随身商店".visible:切换物品栏(0))
	装备槽.visibility_changed.connect(func():if 装备槽.visible:切换物品栏(1))
	%"物品简介".visibility_changed.connect(func():if %"物品简介".visible:切换物品栏(0))
	物品栏选项卡.tab_selected.connect(func(序号):计划.窗口状态管理(基类窗口名称,"物品栏选项卡",null,序号))
	GBIS.sig_slot_item_unequipped.connect(func(_1,_2):装备槽.更新属性())
	GBIS.sig_slot_item_equipped.connect(func(_1,_2):装备槽.更新属性())
	GBIS.sig_item_focused.connect(func(物品实例:ItemData,背包名):#当鼠标获得物品焦点信号
		上次查看["物品实例"]=物品实例
		上次查看["背包名"]=背包名
		%"悬浮提示".更新文本(物品实例.返回简介(背包名,{"富文本":40})))
	GBIS.sig_item_focus_lost.connect(func(物品实例:ItemData):解除提示占用(物品实例))#当鼠标失去物品焦点信号(不安全概率失效)
	计划.购买物品.connect(func(物品实例:ItemData,_背包名):#购买物品后需要刷新显示
		if 上次查看.has("物品实例")and 上次查看["物品实例"] is ItemData and 物品实例==上次查看["物品实例"]:
			if 物品实例 is 标准物品 and 物品实例.商店剩余数量<=0:#如果购买完最后一个物品就不显示了
				解除提示占用()
				return
			%"悬浮提示".更新文本(上次查看["物品实例"].返回简介(上次查看["背包名"])))
	%"使用".pressed.connect(使用物品)
	%"丢弃".pressed.connect(func(): %"删除确认弹窗".visible = true)
	%"分享".pressed.connect(分享物品)
	%"图钉".pressed.connect(func():计划.全局图钉(物品.item_name,%"图钉".button_pressed))
	%"金币贴图".gui_input.connect(func(按键信号):
		if (按键信号 is InputEventMouseButton and 按键信号.pressed and
		按键信号.button_index == MOUSE_BUTTON_LEFT):
			var 按钮状态=not 计划.梅存档["挂机"]["全局图钉"].has("金币")
			计划.全局图钉("金币",按钮状态))
	%"删除确认弹窗".confirmed.connect(删除物品)
	%"整理".pressed.connect(整理物品)
	#%"玩家".mouse_entered.connect(func(): %"玩家属性".text=战力文本)
	#%"玩家".mouse_exited.connect(func():%"玩家属性".text=属性文本)


func 切换物品栏(物品栏:int):
	物品栏选项卡.current_tab=物品栏
	计划.窗口状态管理(基类窗口名称,"状态区",null,状态区.current_tab)
	解除提示占用()
	
func 整理物品():
	var 背包数据库单例=ContainerRepository.instance
	var 背包的实例:ContainerData = 背包数据库单例._container_data_map.get("背包",null)
	if 背包的实例 is ContainerData:
		背包的实例.整理物品()

func 解除提示占用(物品实例=null):
	if 物品实例==null or 上次查看.get("物品实例",null)==物品实例:
		上次查看.clear()
	%"悬浮提示".visible=false
func 使用物品():
	if not 物品==null:
		if 物品 is 标准物品:
			var 结果=物品.使用物品(背包)
			if 结果=="成功":
				if 物品==null or 物品.current_amount<=0:
					物品=null
					%"无选中".visible=true
					%"选中".visible=false
	else :
		计划.语法糖通知("错误物品异常","背包信息")
func 分享物品():
	if not 物品==null and 物品 is 标准物品:
		var 文本 = 物品.文本预处理()
		DisplayServer.clipboard_set(文本)   # 核心操作：将文本写入剪贴板
		计划.语法糖通知("物品信息已粘贴到剪切板","背包信息")
	else :
		计划.语法糖通知("错误物品异常","背包信息")
func 删除物品():
	if not 物品==null and 物品 is ItemData:
		GBIS.inventory_service.remove_item_by_data(背包, 物品)
		物品=null
		%"无选中".visible=true
		%"选中".visible=false
	pass
func _更新_UI():
	金币=计划.梅存档["金币"]
	if 金币>=0:
		%"金币节点".visible=true
	else :
		%"金币节点".visible=false
	%"金币文本".text="金币:"+str(金币)
func _背包物品信息(传入物品:ItemData,背包名称):
	背包=背包名称
	%"无选中".visible=false
	%"选中".visible=true
	if 传入物品 is 标准物品:
		物品=传入物品
		%"物品详情文本".text=物品.文本预处理()
		状态区.current_tab=0
	else :
		物品=传入物品
		%"物品详情文本".text=物品.返回简介(背包)
	%"物品详情名称".text=物品.item_name
	%"物品详情贴图".texture=物品.icon
	if 计划.节点.has("空节点"):
		%"图钉".button_pressed=计划.节点["空节点"].全局图钉.has(str(物品.item_name))
