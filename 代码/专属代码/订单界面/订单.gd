extends Control
class_name 订单
@export_group("外部传入入参数")
@export var 订单号:int=0
@export_group("自动识别参数")
@export var 物品名称:String="铁锭"
@export var 单价:int=100
@export var 订单量:int=20
@export var 时限:int=-1
@export var 额外概率: float=0.20
@export var 额外数量倍率: float=0.5
@export var 额外物品:String="蓝图纸"
@export_group("固定文本")
@export_multiline var 固定文本:String="[font_size=30]金币合计:[/font_size]{金币数量}[img=40x40]res://素材/游戏素材/货币/without background/2.png[/img]
[font_size=30]{额外奖励概率}%概率:[/font_size]{额外奖励数量}[img=40x40]{额外奖励图片}[/img]"
var 固定条件=[["{金币数量}",func():return 单价*订单量],
["{额外奖励概率}",func():return clampi(int(额外概率*100),0,100)],
["{额外奖励数量}",func():return ceili(额外数量倍率*订单量)],
["{额外奖励图片}",func():return 梅表格.获取表格信息(梅表格.装备蓝图,额外物品,"icon")]]
var 装饰词数组=["优质","完美","完美"]
func _ready() -> void:
	全面更新()
func 全面更新():
	$"名称单价".text=物品名称+"\n单价:"+str(单价)+"$"
	$"装饰文本".text=装饰词数组[randi() % 装饰词数组.size()]
	if 时限==-1:
		$"倒计时".visible=false
	else :
		$"倒计时".visible=true
		$"倒计时".text=初始化.格式化时间(时限)
		
	报酬处理()
func 报酬处理():
	var 文本=固定文本
	for 条件 in 固定条件:
		文本=文本.replace(条件[0], str(条件[1].call()))
	$"报酬".text=文本
