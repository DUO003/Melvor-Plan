@tool
extends Resource
class_name 地图信息包
##方便快速跳转相关代码
var 跳转链接:Array=[地区信息包]
@export var 地图名称:String=""
@export_enum("沼泽地块","遗迹地块","雪地地块","山地地块","沙漠地块","森林地块","平原地块","火山地块","湖泊地块","洞穴地块",
"村子地块") var 地块类型:String="村子地块"
@export var 缩放: Vector2=Vector2(1,1)
@export var 地图_地图: TileMapPattern
@export var 起点_地图: Vector2i=Vector2i(0,0)
@export var 地图_建筑: TileMapPattern
@export var 起点_建筑: Vector2i=Vector2i(0,0)
@export var 实体:Dictionary[String,Dictionary]={}
@export_group("刷怪配置")
@export var 刷怪种子:int=-1
@export var 刷怪点配置: Array[刷怪点信息包] = []
func 可用性检查()->bool:
	if not 地图_地图:
		return false
	if not 地图_建筑:
		return false
	return true
