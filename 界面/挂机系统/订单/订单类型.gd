@tool  # 关键：让脚本在编辑器内运行，实现实时预览
extends Panel
@export var 类型: String
var 订单选项: Array=[]
var 配置信息:OptionButton
var 配置文本
var 订单参数:Dictionary
func _ready() -> void:
	if not Engine.is_editor_hint():
		if 类型=="课题订单":
			订单选项=计划.数据订单("课题订单范围")
		订单参数=计划.订单参数[类型]
	更新UI()
	配置信息=$"配置选项"
	if Engine.is_editor_hint():
		订单参数={}
		配置文本=""
	else :
		配置文本=计划.数据订单(类型)
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
		custom_minimum_size.y=125
	else :
		配置信息.visible=false
		custom_minimum_size.y=60
	var 解锁:bool=true
	if not Engine.is_editor_hint():
		订单参数=计划.订单参数[类型]
		解锁=计划.数据订单("订单解锁",类型)
	if 解锁:
		$"文本".text="%s"%[类型]
	else :
		$"文本".text=类型+"未解锁"
		if 订单参数.has("条件文本"):$"文本".text=订单参数["条件文本"]
