extends VBoxContainer
@export var 商品数组:Array[梅商品数据包]=[]
@export var 每次购买量:int=1
var 商品卡 = preload("res://界面/插件/物品辅助/商品卡.tscn").instantiate()
@onready var 商店容器: HBoxContainer = %商店容器
var 商品卡的数组:Array[梅商品卡片]=[]
@onready var 按钮1: Button = $辅助按钮区/按钮区/按钮1
@onready var 按钮2: Button = $辅助按钮区/按钮区/按钮2
@onready var 按钮3: Button = $辅助按钮区/按钮区/按钮3
@onready var 标签: Label = $辅助按钮区/按钮区/标签
@onready var 按钮4: Button = $辅助按钮区/按钮区/按钮4
@onready var 按钮5: Button = $辅助按钮区/按钮区/按钮5
@onready var 按钮6: Button = $辅助按钮区/按钮区/按钮6
func _ready() -> void:
	重新生成()
	按钮1.pressed.connect(购买量.bind(1))
	按钮2.pressed.connect(购买量.bind(5))
	按钮3.pressed.connect(购买量.bind(10))
	按钮4.pressed.connect(增加购买量.bind(1))
	按钮5.pressed.connect(增加购买量.bind(-1))
	按钮6.pressed.connect(购买量乘以.bind(2.0))
	更新数量()
func 购买量乘以(乘以:float):
	增加购买量(int(每次购买量*(乘以-1.0)))
func 增加购买量(增加:int=1):
	每次购买量+=增加
	if 每次购买量>=1000:
		每次购买量=1000
	if 每次购买量<=0:
		每次购买量=1
	更新数量()
func 购买量(改为:int=1):
	每次购买量=改为
	更新数量()
func 更新数量():
	var 序号=0
	if 商品卡的数组.size()==商品数组.size():
		for 商品卡场景 in 商品卡的数组:
			商品卡场景.商品=克隆商品数据(商品数组[序号])
			商品卡场景.购买数量=每次购买量
			商品卡场景.更新界面()
			序号+=1
	else :重新生成()
	标签.text="每次购买%d"%每次购买量
func 重新生成():
	计划.清除子节点(商店容器)
	for 商品数据 in 商品数组:
		var 商品卡场景=商品卡.duplicate()
		商品卡场景.商品=克隆商品数据(商品数据)
		商店容器.add_child(商品卡场景)
		商品卡的数组.append(商品卡场景)
func 克隆商品数据(商品数据:梅商品数据包):
	var 克隆商品的数据:梅商品数据包=商品数据.duplicate(true)
	var 物品名称=克隆商品的数据.商品名
	if 计划.表格.蓝图标签检查(物品名称,"催化"):
		var 催化精通等级=计划.手工.数据炼金催化剂(物品名称,"等级")
		克隆商品的数据.商品数量+=int(0.1*催化精通等级)
	return 克隆商品的数据
