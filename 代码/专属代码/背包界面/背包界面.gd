extends Control
var 金币=初始化.梅存档["金币"]
var 物品=null
var 属性文本="多003\n游历 LV:0		熟练:0/100\n"
var 战力文本=""
func _ready():
	%物品栏选项卡.set_tab_title(0, "物品栏")
	初始化.connect("更新_UI", Callable(self, "_更新_UI"))
	初始化.更新_背包物品信息.connect(_背包物品信息)
	_更新_UI()
	%"无选中".visible=true
	%"选中".visible=false
	%"随身商店".visibility_changed.connect(func(): if %"随身商店".visible: %"物品栏".visible = true)
	%"装备".visibility_changed.connect(func(): if %"装备".visible: %"装备栏".visible = true)
	%"物品".visibility_changed.connect(func(): if %"物品".visible: %"物品栏".visible = true)
	战力文本=初始化.玩家单例.战力文本更新()
	%"玩家属性".text=属性文本+战力文本
	GBIS.connect("sig_slot_item_unequipped", Callable(func(_1,_2):
		战力文本=初始化.玩家单例.战力文本更新()
		%"玩家属性".text=属性文本+战力文本
		))
	GBIS.connect("sig_slot_item_equipped", Callable(func(_1,_2):
		战力文本=初始化.玩家单例.战力文本更新()
		%"玩家属性".text=属性文本+战力文本
		))
	战力文本=初始化.玩家单例.战力文本更新()
	%"使用".pressed.connect(func(): 引擎.屏幕.滚动提示("使用功能未开发完成敬请期待","背包信息"))
	%"丢弃".pressed.connect(func(): %"删除确认弹窗".visible = true)
	%"分享".pressed.connect(func():分享物品())
	%"删除确认弹窗".confirmed.connect(func():删除物品())
	#%"玩家".mouse_entered.connect(func(): %"玩家属性".text=战力文本)
	#%"玩家".mouse_exited.connect(func():%"玩家属性".text=属性文本)
func 分享物品():
	if not 物品==null:
		var 文本 = %"物品提示".文本预处理(物品,"背包")
		DisplayServer.clipboard_set(文本)   # 核心操作：将文本写入剪贴板
		引擎.屏幕.滚动提示("物品信息已粘贴到剪切板","背包信息")
	else :
		引擎.屏幕.滚动提示("错误物品异常","背包信息")


func 删除物品():
	if not 物品==null:
		GBIS.inventory_service.remove_item_by_data("背包", 物品)
		物品=null
		%"无选中".visible=true
		%"选中".visible=false
	pass
func _更新_UI():
	金币=初始化.梅存档["金币"]
	if 金币>=0:
		%"金币节点".visible=true
	else :
		%"金币节点".visible=false
	%"金币文本".text="金币:"+str(金币)
func _背包物品信息(传入物品:标准物品):
	物品=传入物品
	%"无选中".visible=false
	%"选中".visible=true
	%"物品详情文本".text=物品.item_name+"\n数量:"+str(物品.current_amount)+"\n堆叠上限:"+str(物品.stack_size)+"\n"+物品.简介
	%"物品详情名称".text=物品.item_name
	%"物品详情贴图".texture=物品.icon
	print("收到物品更新：", 物品.简介)
