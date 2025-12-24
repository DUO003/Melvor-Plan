@tool  # 关键：让脚本在编辑器内运行，实现实时预览
extends Panel
@export var 类型: String
var 订单选项: Array=[]
var 增长需求: int=200
var 配置信息:OptionButton
var 配置文本
var 订单参数:Dictionary
func _ready() -> void:
	if not Engine.is_editor_hint():
		if 类型=="课题订单":
			订单选项=计划.数据订单("课题订单范围")
		订单参数=计划.订单参数[类型]
	更新UI()
	$"扩容".pressed.connect(升级订单容量)
	配置信息=$"配置选项"
	if Engine.is_editor_hint():
		订单参数={}
		配置文本=""
	else :
		配置文本=计划.数据订单(类型)
		增长需求=订单参数["增长需求"]
	if 订单选项.size()>=1:
		配置信息.clear()
		for 内容 in 订单选项:
			配置信息.add_item(str(内容))
		if not Engine.is_editor_hint():
			配置信息.item_selected.connect(func(选中索引: int):
				计划.数据订单(类型,配置信息.get_item_text(选中索引)))
func 更新UI():
	配置信息=$"配置选项"#OptionButton
	if 订单选项.size()>=1:#与节点内的一致,本地数组会在_ready()赋值给节点
		配置信息.visible=true
		for i in range(配置信息.get_item_count()):
			if 配置文本 == 配置信息.get_item_text(i):
				配置信息.selected=i
		custom_minimum_size.y=170
	else :
		配置信息.visible=false
		custom_minimum_size.y=100
	var 数量:int=0
	var 容量:int=10
	var 价格:String="扩容费用"+str(增长需求)
	var 解锁:bool=true
	if not Engine.is_editor_hint():
		订单参数=计划.订单参数[类型]
		数量=计划.读取数据订单("订单数量",类型)
		容量=计划.读取数据订单("订单上限",类型)
		价格="扩容费用"+str(升级订单价格())
		var 订单上限=计划.读取数据订单("订单上限",类型)
		if 订单上限>=订单参数["容量上限"]:
			价格="已经达到上限"
		解锁=计划.订单解锁(类型)
	if 解锁:
		$"扩容".text="扩容"
		$"文本".text="%s%d/%d
%s"%[类型,数量,容量,价格]
	else :
		$"扩容".text="解锁"
		$"文本".text=类型+"未解锁\r"
		if 订单参数.has("条件文本"):$"文本".text+=订单参数["条件文本"]
func 升级订单价格()->int:
	var 订单上限=计划.读取数据订单("订单上限",类型)
	return int((订单上限+1)*增长需求)
func 升级订单容量():
	if 计划.订单解锁(类型):
		var 订单上限=计划.读取数据订单("订单上限",类型)
		if 订单上限>=订单参数["容量上限"]:
			计划.语法糖通知("扩容超出上限","订单提示")
			return
		if 计划.语法糖金币消费(升级订单价格()):
			计划.数据订单("订单上限",1,类型)
			更新UI()
			计划.更新_UI.emit()
			计划.保存存档("订单扩容 类型:"+str(类型))
		else :
			计划.语法糖通知("金币不足","订单提示")
	else :
		计划.数据订单("订单解锁",类型)
		更新UI()
