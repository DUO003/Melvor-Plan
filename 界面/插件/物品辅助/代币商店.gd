extends VBoxContainer
class_name 梅代币商店
var 商品数组:Array[梅商品数据包]=[]
@export var 商品数组数据:Array[梅商品数据包]=[]
@export var 每次购买量:int=1
@export var 启用药水出售:bool=false
@export var 启用图纸出售:bool=false
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
var 商店格子:int
func 重新生成():
	计划.清除子节点(多商店容器)
	文本标签字典={}
	商店容器={}
	商品卡的数组=[]
	await get_tree().process_frame
	var 卡片尺寸:Vector2=商品卡.尺寸
	商店格子=int(size.x/(卡片尺寸.x-10))
	更新商品()
func 更新商品():
	var 已添加内容:Dictionary[梅商品数据包,bool]={}
	#print("商品卡的数组",商品卡的数组)
	for 商品卡场景 in 商品卡的数组:
		已添加内容[商品卡场景.商品]=true
	for 商品数据 in 商品数组:
		if not 已添加内容.has(商品数据):
			var 网格容器:GridContainer=返回商店(商品数据)
			var 商品卡场景=商品卡.duplicate()
			商品卡场景.商品=更新商品数据(商品数据)
			网格容器.add_child(商品卡场景)
			商品卡的数组.append(商品卡场景)
	更新数量()
	更新文本标签()
	#print("商品卡的数组",商品卡的数组)
	#print("已添加内容",已添加内容)
	#print("商品数组",商品数组)
var 文本标签字典:Dictionary[Label,String]
func 返回商店(商品数据:梅商品数据包)->GridContainer:
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
		网格容器.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		网格容器.size_flags_vertical=Control.SIZE_EXPAND_FILL
		网格容器.add_theme_constant_override("h_separation", -10)
		网格容器.add_theme_constant_override("v_separation", -10)
	网格容器.columns=max(1,商店格子)
	return 网格容器
func 更新文本标签():
	
	for 文本标签 in 文本标签字典:
		var 类型=文本标签字典[文本标签]
		if 额外商品数据.has(类型):
			var 额外数据=额外商品数据[类型].内容
			var 点数类型=额外商品数据[类型].点数
			文本标签.text="%s%s\r%s:%d"%[类型,额外数据,点数类型,计划.点数.查看点数(点数类型)]
		else :文本标签.text=类型
func 更新商品数据(商品数据:梅商品数据包):
	if 计划.表格.蓝图标签检查(商品数据.商品名,"催化"):
		商品数据.商品数量方法=催化类商品数量.bind(商品数据)
		商品数据.方法标志位=true
	商品数据.更新商品数量()
	return 商品数据
func 催化类商品数量(商品数据:梅商品数据包):
	var 催化精通等级=计划.手工.数据炼金催化剂(商品数据.商品名,"等级")
	商品数据.商品数量=5+int(0.1*催化精通等级)
var 额外商品数据:Dictionary={}
var 商品数据资源:Dictionary[String,梅商品数据包]={}
func 更新额外商品():
	商品数组=商品数组数据.duplicate()
	if 启用药水出售:
		var 药水字典:Dictionary=计划.手工.读取炼金解锁药水()
		var 药水数组:Array=药水字典.keys()
		药水数组.sort()
		var 数据包:梅商品数据包=梅商品数据包.new()
		数据包.商品数量=1
		数据包.代币类型="点数"
		数据包.代币="贤者点数"
		数据包.商店名称="炼金药水"
		var 添加成功:int=0
		for 药水 in 药水数组:
			if not 计划.表格.蓝图标签检查(药水,["装备药水","失败品","收藏品"]):
				var 克隆数据:梅商品数据包
				if 商品数据资源.has(药水):
					克隆数据=商品数据资源[药水]
				else :
					克隆数据=数据包.duplicate()
				克隆数据.商品名=药水
				克隆数据.费用=int(计划.表格.蓝图数据(药水,"价值")*0.1)
				克隆数据.限购=max(0,药水字典[药水]-计划.梅存档["挂机"]["标准商店"].get(药水,0))
				商品数组.append(克隆数据)
				商品数据资源[药水]=克隆数据
				添加成功+=1
		额外商品数据["炼金药水"]={"内容":"(通过炼金解锁%d种药水,能购买%d种)"%[药水数组.size(),添加成功],"点数":"贤者点数"}
	if 启用图纸出售:
		var 数据包:梅商品数据包=梅商品数据包.new()
		数据包.商品数量=1
		数据包.代币类型="点数"
		数据包.代币="蓝图纸"
		数据包.限购=-1
		var 研究方向:Array=计划.手工.数据灵感("研究方向")
		var 最大:int=1
		for 方向 in 研究方向:
			数据包.商店名称=方向
			var 蓝图数组:Array=计划.获取配方(方向,1,最大)
			print("<%s>数组:"%方向,蓝图数组)
			var 添加成功:int=0
			for 蓝图 in 蓝图数组:
				var 克隆数据:梅商品数据包
				if 商品数据资源.has(蓝图):
					克隆数据=商品数据资源[蓝图]
				else :
					克隆数据=数据包.duplicate()
				克隆数据.商品名=蓝图
				克隆数据.费用=int(计划.表格.蓝图数据(蓝图,"价值")*1.2**(计划.表格.蓝图数据(蓝图,"阶级")-1))
				if 克隆数据.限购==0 or 计划.手工.数据合成配方(蓝图,"解锁"):
					克隆数据.限购=0
					添加成功+=1
				else :克隆数据.限购=1
				商品数组.append(克隆数据)
				商品数据资源[蓝图]=克隆数据
				
			额外商品数据[方向]={"内容":"(%s图纸研究解锁进度 %d/%d)"%[方向,添加成功,蓝图数组.size()],"点数":"蓝图纸"}
