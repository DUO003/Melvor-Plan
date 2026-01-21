extends VBoxContainer
@export var 商品数组:Array[梅商品数据包]=[]
@export var 每次购买量:int=1
@export var 启用药水出售:bool=false
@onready var 按钮1: Button = $辅助按钮区/按钮区/按钮1
@onready var 按钮2: Button = $辅助按钮区/按钮区/按钮2
@onready var 按钮3: Button = $辅助按钮区/按钮区/按钮3
@onready var 标签: Label = $辅助按钮区/按钮区/标签
@onready var 按钮4: Button = $辅助按钮区/按钮区/按钮4
@onready var 按钮5: Button = $辅助按钮区/按钮区/按钮5
@onready var 按钮6: Button = $辅助按钮区/按钮区/按钮6
@onready var 多商店容器: VBoxContainer = %多商店容器
var 商品卡:梅商品卡片 = preload("res://界面/插件/物品辅助/商品卡.tscn").instantiate()
var 商品卡的数组:Array[梅商品卡片]=[]
var 商店数组:Array[GridContainer]=[]
var 商店容器:Dictionary[String,GridContainer]={}
func _ready() -> void:
	按钮1.pressed.connect(购买量.bind(1))
	按钮2.pressed.connect(购买量.bind(5))
	按钮3.pressed.connect(购买量.bind(10))
	按钮4.pressed.connect(增加购买量.bind(1))
	按钮5.pressed.connect(增加购买量.bind(-1))
	按钮6.pressed.connect(购买量乘以.bind(2.0))
	更新额外商品()
	计划.显示后执行(重新生成,self)
	计划.更新_UI.connect(更新文本标签)
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
	if 商品卡的数组.size()==商品数组.size():
		for 商品卡场景 in 商品卡的数组:
			商品卡场景.购买数量=每次购买量
			商品卡场景.更新界面()
	else :重新生成()
	标签.text="每次购买%d"%每次购买量
func 重新生成():
	计划.清除子节点(多商店容器)
	文本标签字典={}
	await get_tree().process_frame
	var 卡片尺寸:Vector2=商品卡.尺寸
	var 格子:int=int(size.x/(卡片尺寸.x-10))
	print("格子%d,尺寸%d,卡片%d"%[格子,size.x,卡片尺寸.x])
	for 商品数据 in 商品数组:
		var 网格容器:GridContainer=返回商店(格子,商品数据)
		var 商品卡场景=商品卡.duplicate()
		商品卡场景.商品=克隆商品数据(商品数据)
		网格容器.add_child(商品卡场景)
		商品卡的数组.append(商品卡场景)
	更新数量()
	更新文本标签()
var 文本标签字典:Dictionary[Label,String]
func 返回商店(商店格子:int,商品数据:梅商品数据包)->GridContainer:
	var 商店名称:String=商品数据.商店名称
	var 网格容器:GridContainer
	if 商店容器.has(商店名称):网格容器=商店容器[商店名称]
	else :
		var 文本标签:Label=Label.new()
		多商店容器.add_child(文本标签)
		文本标签字典[文本标签]=商店名称
		网格容器=GridContainer.new()
		多商店容器.add_child(网格容器)
		商店容器[商店名称]=网格容器
	网格容器.columns=max(1,商店格子)
	网格容器.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	网格容器.size_flags_vertical=Control.SIZE_EXPAND_FILL
	网格容器.add_theme_constant_override("h_separation", -10)
	网格容器.add_theme_constant_override("v_separation", -10)
	return 网格容器
func 更新文本标签():
	for 文本标签 in 文本标签字典:
		var 类型=文本标签字典[文本标签]
		if 类型=="炼金药水":
			文本标签.text="%s(已通过炼金解锁%d种药水)\r贤者点数:%d"%[类型,额外商品数据.get("炼金药水",0),计划.手工.查看资源("贤者点数")]
		else :
			文本标签.text=类型
func 克隆商品数据(商品数据:梅商品数据包):
	var 克隆商品的数据:梅商品数据包=商品数据.duplicate(true)
	var 物品名称=克隆商品的数据.商品名
	if 计划.表格.蓝图标签检查(物品名称,"催化"):
		var 催化精通等级=计划.手工.数据炼金催化剂(物品名称,"等级")
		克隆商品的数据.商品数量+=int(0.1*催化精通等级)
	return 克隆商品的数据
var 额外商品数据:Dictionary={}
func 更新额外商品():
	var 炼金力:float=计划.装备.炼金力
	if 启用药水出售:
		var 药水字典:Dictionary=计划.手工.读取炼金解锁药水()
		var 药水数组:Array=药水字典.keys()
		药水数组.sort()
		var 数据包:梅商品数据包=梅商品数据包.new()
		数据包.商品数量=1
		数据包.代币类型="点数"
		数据包.代币="贤者点数"
		数据包.商店名称="炼金药水"
		额外商品数据["炼金药水"]=药水数组.size()
		var 最大限购:int=int(0.2*炼金力+10)
		for 药水 in 药水数组:
			var 克隆数据:梅商品数据包=数据包.duplicate()
			克隆数据.商品名=药水
			克隆数据.费用=int(计划.表格.蓝图数据(药水,"价值")*0.1)
			克隆数据.限购=max(0,min(最大限购,药水字典[药水]+4)-计划.梅存档["挂机"]["标准商店"].get(药水,0))
			商品数组.append(克隆数据)
