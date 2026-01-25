extends Resource
class_name 梅商品数据包
##可以买什么
@export var 商品名:String=""
##可以买什么
@export var 商品数量:int=1
##更新商品数量
var 方法标志位:bool=false
@export var 商品数量方法:Callable
##消耗什么代币作为费用
@export_enum("物品","点数") var 代币类型:String="物品"
##消耗什么代币作为费用
@export var 代币:String=""
##数量
@export var 费用:int=1
##限购商品需要存档,每日刷新
@export var 限购:int=-1
##该商品会出现在那个商店分区里
@export var 商店名称:String="其他"
func 更新商品数量():
	if 方法标志位:
		商品数量方法.call()
