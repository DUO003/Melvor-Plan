@tool
extends Panel
class_name 梅商品卡片
@export var 商品:梅商品数据包
@export var 购买数量:int=1:
	set(值):
		if 商品:
			if 商品.限购==-1:购买数量 = 值
			elif 值<=商品.限购:购买数量 = 值
			else :购买数量 = 商品.限购
		else :
			购买数量 = 值
@export var 尺寸:Vector2=Vector2(160,220):
	set(值):
		尺寸 = 值# 赋值时执行
		custom_minimum_size=尺寸
		size=尺寸
@onready var 图片: TextureRect = $图片
@onready var 价格: RichTextLabel = $价格
@onready var 文本: Label = $文本
@onready var 点击判断区: Control = $点击判断区
func _ready() -> void:
	custom_minimum_size=尺寸
	if 商品:
		更新界面()
		点击判断区.gui_input.connect(gui点击逻辑)
		点击判断区.mouse_entered.connect(接触反馈.bind(true))
		点击判断区.mouse_exited.connect(接触反馈.bind(false))
		接触反馈(false)
func 更新界面():
	if 购买数量*商品.商品数量>1:
		$"图片/数量".text="*%d"%(购买数量*商品.商品数量)
	else :
		$"图片/数量".text=""
	图片.texture=计划.表格.道具贴图(商品.商品名)
	价格.text="%s\r%d[img=40x40]%s[/img]"%[商品.商品名,商品.费用*购买数量,计划.表格.道具贴图(商品.代币).resource_path]
func 接触反馈(启用:bool):
	if 启用:
		if 商品.限购==-1:
			文本.text="点击购买"
		else :
			文本.text="剩余:%d"%商品.限购
	else :
		if 商品.限购==-1:
			文本.text="商品"
		else :
			文本.text="限购%d"%商品.限购
func gui点击逻辑(按键):
	if 按键 is InputEventMouseButton and 按键.pressed:
		更新界面()
		if 按键.button_index == MOUSE_BUTTON_LEFT:
			购买逻辑()
func 购买逻辑():
	if not 商品.限购==-1 and 购买数量>商品.限购:
		计划.语法糖通知("超过限购","商品卡通知")
		return
	var 背包内代币
	match 商品.代币类型:
		"点数":背包内代币=计划.手工.查看资源(商品.代币)
		"物品",_:背包内代币=计划.检查背包物品数量(商品.代币)
	if 背包内代币>=商品.费用*购买数量:
		if 计划.表格.蓝图标签检查(商品.商品名,"催化"):
			计划.steam.解锁成就("催化剂兑换")
		match 商品.代币类型:
			"点数":背包内代币=计划.手工.获得资源(商品.代币,-购买数量*商品.费用)
			"物品",_:计划.语法糖消耗物品(商品.代币,购买数量*商品.费用)
		计划.获得物品语法糖(商品.商品名,购买数量*商品.商品数量)
		计划.语法糖通知("获取%s*%d,共计%d,消耗%s*%d"%[商品.商品名,购买数量*商品.商品数量,
			计划.检查背包物品数量(商品.商品名),商品.代币,购买数量*商品.费用])
		var 标准商店:Dictionary=计划.梅存档["挂机"]["标准商店"]
		标准商店[商品.商品名]=标准商店.get(商品.商品名,0)+购买数量
		if not 商品.限购==-1:
			if 商品.限购>=0 and 购买数量>商品.限购:
				购买数量=商品.限购
			商品.限购-=购买数量
		更新界面()
		接触反馈(true)
		计划.更新_UI.emit()
	else :
		计划.语法糖通知("代币不足","商品卡")
