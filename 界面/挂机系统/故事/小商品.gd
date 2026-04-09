extends HBoxContainer
class_name 梅商品条
@export var 商品:梅商品数据包
@onready var 图片: TextureRect = $商品贴图
@onready var 价格描述: RichTextLabel = $价格描述
@onready var 制作: Button = %"制作"
var 当前商品:=""
func _ready() -> void:
	visible=false
	制作.pressed.connect(购买逻辑)
func 更新界面(商品名=当前商品):
	if 商品名=="":
		return
	当前商品=商品名
	var 字典:Dictionary=计划.表格.方块字典[商品名]
	var 费用=字典.点数
	var 代币=字典.点数类
	var 点数:梅点数=计划.点数
	商品.商品名=商品名
	商品.费用=费用
	商品.代币=代币
	visible=true
	var 新方块=物品方块.new(1,商品.商品名)
	图片.texture=新方块.icon
	价格描述.text="%s方块\n费用%d[img=40x40]%s[/img]点数\n当前点数:%d\n%s"%[
		商品.商品名,商品.费用,计划.表格.道具贴图(商品.代币).resource_path,点数.查看点数(商品.代币),新方块.简介]
func 购买逻辑():
	商品.购买逻辑(1)
	横版单例.获取背包消息()
	更新界面()
