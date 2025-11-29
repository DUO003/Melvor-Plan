extends Control
var 金币=计划.梅存档["金币"]
var 物品:标准物品=null
var 背包="背包"
var 属性文本="多003\n游历 LV:0		熟练:0/100\n"
var 战力文本=""
func _ready():
	%物品栏选项卡.set_tab_title(0, "物品栏")
	计划.connect("更新_UI", Callable(self, "_更新_UI"))
	计划.更新_背包物品信息.connect(_背包物品信息)
	_更新_UI()
	%"无选中".visible=true
	%"选中".visible=false
	%"随身商店".visibility_changed.connect(func(): if %"随身商店".visible: %"物品栏".visible = true)
	%"装备".visibility_changed.connect(func(): if %"装备".visible: %"装备栏".visible = true)
	%"物品".visibility_changed.connect(func(): if %"物品".visible: %"物品栏".visible = true)
	战力文本=计划.游历.战力文本更新()
	%"玩家属性".text=属性文本+战力文本
	GBIS.connect("sig_slot_item_unequipped", Callable(func(_1,_2):
		战力文本=计划.游历.战力文本更新()
		%"玩家属性".text=属性文本+战力文本
		))
	GBIS.connect("sig_slot_item_equipped", Callable(func(_1,_2):
		战力文本=计划.游历.战力文本更新()
		%"玩家属性".text=属性文本+战力文本
		))
	战力文本=计划.游历.战力文本更新()
	%"使用".pressed.connect(func(): 使用物品())
	%"丢弃".pressed.connect(func(): %"删除确认弹窗".visible = true)
	%"分享".pressed.connect(func():分享物品())
	%"图钉".pressed.connect(func():计划.全局图钉(物品.item_name,%"图钉".button_pressed))
	%"金币贴图".gui_input.connect(func(按键信号):
		if (按键信号 is InputEventMouseButton and 按键信号.pressed and
		按键信号.button_index == MOUSE_BUTTON_LEFT):
			var 按钮状态=not 计划.梅存档["挂机"]["全局图钉"].has("金币")
			计划.全局图钉("金币",按钮状态))
	%"删除确认弹窗".confirmed.connect(func():删除物品())
	#%"玩家".mouse_entered.connect(func(): %"玩家属性".text=战力文本)
	#%"玩家".mouse_exited.connect(func():%"玩家属性".text=属性文本)
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
	if not 物品==null:
		var 文本 = 物品.文本预处理()
		DisplayServer.clipboard_set(文本)   # 核心操作：将文本写入剪贴板
		计划.语法糖通知("物品信息已粘贴到剪切板","背包信息")
	else :
		计划.语法糖通知("错误物品异常","背包信息")
func 删除物品():
	if not 物品==null:
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
func _背包物品信息(传入物品:标准物品,背包名称):
	物品=传入物品
	背包=背包名称
	%"无选中".visible=false
	%"选中".visible=true
	%"物品详情文本".text=物品.文本预处理()
	%"物品详情名称".text=物品.item_name
	%"物品详情贴图".texture=物品.icon
	if 计划.节点.has("空节点"):
		%"图钉".button_pressed=计划.节点["空节点"].全局图钉.has(str(物品.item_name))
	print("收到物品更新：", 物品.简介)
