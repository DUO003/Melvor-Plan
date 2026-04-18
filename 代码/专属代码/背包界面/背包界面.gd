extends 基类梅窗口
var 金币=计划.梅存档["金币"]
var 物品:ItemData=null
var 背包="背包"
var 上次查看:={}
@onready var 物品栏选项卡: TabContainer = %物品栏选项卡
@onready var 状态区: TabContainer = %状态区
@onready var 背包_容器: InventoryView = %背包
@onready var 背包扩容费用: Label = %背包扩容费用
@onready var 扩容按钮: Button = %扩容
@onready var 背包栏: ScrollContainer = %背包栏
@onready var 装备栏: ScrollContainer = %装备栏
@onready var 方块背包栏: ScrollContainer = %方块背包栏
@onready var 装备槽: Control = %装备槽
@onready var 物品简介: MarginContainer = %物品简介
@onready var 随身商店: VBoxContainer = %随身商店
@onready var 悬浮提示: 梅悬浮提示 = %悬浮提示
@onready var 背包功能区: HBoxContainer = %背包功能区
@onready var 金币贴图: TextureRect = %金币贴图
@onready var 金币文本: Label = %金币文本
@onready var 使用: Button = %使用
@onready var 丢弃: Button = %丢弃
@onready var 分享: Button = %分享
@onready var 整理: Button = %整理
func _ready():
	super._ready()
	计划.connect("更新_UI", Callable(self, "_更新_UI"))
	计划.更新_背包物品信息.connect(_背包物品信息)
	_更新_UI()
	GBIS.sig_slot_item_unequipped.connect(func(_1,_2):装备槽.更新属性())
	GBIS.sig_slot_item_equipped.connect(func(_1,_2):装备槽.更新属性())
	#GBIS.sig_item_focused.connect(func(物品实例:ItemData,背包名):#当鼠标获得物品焦点信号
		#上次查看["物品实例"]=物品实例
		#上次查看["背包名"]=背包名
		#var 数据:梅提示数据=梅提示数据.new()
		#数据.通用解析(物品实例,{"背包名":背包名})
		#计划.数据包提示.emit(数据))
	#GBIS.sig_item_focus_lost.connect(func(物品实例:ItemData):解除提示占用(物品实例))#当鼠标失去物品焦点信号
	计划.购买物品.connect(func(物品实例:ItemData,_背包名):#购买物品后需要刷新显示
		if 上次查看.has("物品实例")and 上次查看["物品实例"] is ItemData and 物品实例==上次查看["物品实例"]:
			if 物品实例 is 标准物品 and 物品实例.商店剩余数量<=0:#如果购买完最后一个物品就不显示了
				解除提示占用()
				return
			%"悬浮提示".更新文本(上次查看["物品实例"].返回简介(上次查看["背包名"])))
	使用.pressed.connect(使用物品)
	丢弃.pressed.connect(func(): %"删除确认弹窗".visible = true)
	分享.pressed.connect(分享物品)
	图钉.pressed.connect(func():计划.全局图钉(物品.item_name,图钉.button_pressed))
	%"金币贴图".gui_input.connect(func(按键信号):
		if (按键信号 is InputEventMouseButton and 按键信号.pressed and
		按键信号.button_index == MOUSE_BUTTON_LEFT):
			var 按钮状态=not 计划.梅存档["挂机"]["全局图钉"].has("金币")
			计划.全局图钉("金币",按钮状态))
	%"删除确认弹窗".confirmed.connect(删除物品)
	%"整理".pressed.connect(整理物品)
	更新扩容费用提示()
	扩容按钮.pressed.connect(扩容背包)
	物品栏选项卡.tab_changed.connect(更新整理按钮显示)
	更新整理按钮显示()
	更新物品介绍()
	额外焦点逻辑()
	await get_tree().process_frame
	call_deferred("便利性切换")
func 额外焦点逻辑():
	var 标签栏:TabBar = 物品栏选项卡.get_tab_bar()
	var 标签栏2:TabBar = 状态区.get_tab_bar()
	if not 标签栏 or not 标签栏2:
		print("错误：无法获取标签栏")
		return
	标签栏.focus_entered.connect(焦点锁定.bind(true))
	标签栏2.focus_entered.connect(焦点锁定.bind(false))
	标签栏.mouse_entered.connect(焦点锁定.bind(true))
	标签栏2.mouse_entered.connect(焦点锁定.bind(false))
	
func 焦点锁定(状态:bool):
	var 物品组状态:FocusBehaviorRecursive=FOCUS_BEHAVIOR_ENABLED if 状态 else FOCUS_BEHAVIOR_DISABLED
	var 信息组状态:FocusBehaviorRecursive=FOCUS_BEHAVIOR_DISABLED if 状态 else FOCUS_BEHAVIOR_ENABLED
	背包栏.focus_behavior_recursive=物品组状态
	装备栏.focus_behavior_recursive=物品组状态
	方块背包栏.focus_behavior_recursive=物品组状态
	装备槽.focus_behavior_recursive=信息组状态
	随身商店.focus_behavior_recursive=信息组状态
	物品简介.focus_behavior_recursive=信息组状态
	print("切换焦点组")
func 更新整理按钮显示(标签:int=物品栏选项卡.current_tab):
	整理.visible=标签==0
func 翻译更新检查():
	if 物品:
		_背包物品信息(物品,背包)
	随身商店.扩容提示更新()
	_更新_UI()
	更新扩容费用提示()
func 更新扩容费用提示():
	var 列数:int=背包_容器.container_rows
	var 消耗数量:int=((列数-8)*160)
	var 挂机阶级=计划.数据系统("挂机","阶级")
	if 列数>=15+挂机阶级*2:
		if 挂机阶级==20:
			背包扩容费用.text="<版本最大值>"
		else :
			var 需求等级=int(1 + (列数 - 15) / 2.0) * 5
			背包扩容费用.text=tr("<扩容等级不足>")%[需求等级,tr("挂机")]
	else :
		背包扩容费用.text=tr("<扩容提示>")%[消耗数量,计划.表格.翻译名称("绿色电路板")]
	
func 扩容背包():
	var 背包数量=计划.检查背包物品数量("绿色电路板")
	var 列数:int=背包_容器.container_rows
	var 挂机阶级=计划.数据系统("挂机","阶级")
	if 列数>=15+挂机阶级*2:
		计划.语法糖通知(tr("<扩容失败上限>"),"背包提示")
		return
	var 消耗数量:int=((列数-8)*160)
	if not 背包数量>=消耗数量:
		计划.语法糖通知(tr("<扩容失败材料>")%[tr("背包"),计划.表格.翻译名称("绿色电路板")],"背包提示")
		return
	计划.语法糖消耗物品("绿色电路板",消耗数量)
	var 背包数据:Dictionary=计划.梅存档.挂机.背包数据
	if not 背包数据.has("背包"):
		背包数据["背包"]={}
	背包数据["背包"].行数=背包_容器.container_rows+1
	计划.语法糖通知(tr("<扩容成功>")%[tr("背包")])
	计划.切换场景("背包界面",true)
func 便利性切换():
	随身商店.visibility_changed.connect(func():if 随身商店.visible:切换物品栏(0))
	装备槽.visibility_changed.connect(func():if 装备槽.visible:切换物品栏(1))
	物品简介.visibility_changed.connect(func():if 物品简介.visible:切换物品栏(0))
func 切换物品栏(物品栏:int):
	物品栏选项卡.current_tab=物品栏
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
				if 物品==null or 物品.数量<=0:
					物品=null
					更新物品介绍()
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
		更新物品介绍()
	pass
func _更新_UI():
	金币=计划.梅存档["金币"]
	if 金币>=0:
		金币贴图.visible=true
		金币文本.text="%s:%d"%[计划.表格.翻译名称("金币"),金币]
	else :
		金币贴图.visible=false
		金币文本.text=""
func _背包物品信息(传入物品:ItemData,背包名称):
	背包=背包名称
	物品=传入物品
	更新物品介绍()
@onready var 物品详情贴图: TextureRect = %物品详情贴图
@onready var 物品详情名称: Label = %物品详情名称
@onready var 物品详情文本: RichTextLabel = %物品详情文本
@onready var 图钉: CheckButton = %图钉
@onready var 按钮区: VBoxContainer = %按钮区
func 更新物品介绍():
	if 物品:
		if 物品 is 标准物品:
			物品详情文本.text=物品.文本预处理()
			状态区.current_tab=0
			使用.visible=物品.物品类型可用性检查()
		else :
			物品详情文本.text=物品.返回简介(背包)
			使用.visible=false
		物品详情名称.text=物品.item_name
		物品详情贴图.texture=物品.icon
		if 主容器窗口:
			图钉.button_pressed=主容器窗口.全局图钉.has(str(物品.item_name))
		else :
			图钉.button_pressed=false
			print("[错误]背包界面找不到主窗口")
		按钮区.visible=true
		
	else :
		物品详情名称.text="未选中"
		物品详情贴图.texture=null
		物品详情文本.text="点击选择检查物品"
		按钮区.visible=false
