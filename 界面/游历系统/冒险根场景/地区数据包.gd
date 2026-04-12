@tool
extends Resource
class_name 地区信息包

# 导出字段
@export var 地区名称: String = ""
@export var 地图_背景: TileMapPattern
@export var 起点_背景: Vector2i = Vector2i(0, 0)
@export var 地图_地块: TileMapPattern
@export var 起点_地块: Vector2i = Vector2i(0, 0)
@export var 地块配置: Dictionary[Vector2i, 地图信息包] = {}
@export var 限制范围:Rect2=Rect2(0,0,100,100)
var 默认配置:地图信息包=地图信息包.new()
# ====================== 核心初始化方法 ======================
func 初始化(	_地图_背景: TileMapPattern,_起点_背景: Vector2i,
			_地图_地块: TileMapPattern,_起点_地块: Vector2i):
	# 赋值传入的参数
	地图_背景 = _地图_背景
	起点_背景 = _起点_背景
	地图_地块 = _地图_地块
	起点_地块 = _起点_地块
# 自动加载地块非空单元格到 地块配置 字典（键：坐标，值：空）
func 自动加载地块配置(瓦片地图:可保存瓦片地图) -> void:
	if not 地图_地块:# 没有地块图案直接退出
		return
	var 所有使用的单元格: Array[Vector2i] = 地图_地块.get_used_cells()
	for 单元格 in 所有使用的单元格:
		var 真实坐标: Vector2i = 起点_地块 + 单元格
		if not 地块配置.has(真实坐标) or not 地块配置[真实坐标]:
			地块配置[真实坐标] = 默认配置.duplicate()
		var 瓦片数据 = 瓦片地图.get_cell_tile_data(真实坐标)
		if 瓦片数据.has_custom_data("地块类型"):
			var 地块类型:String=瓦片数据.get_custom_data("地块类型")
			地块配置[真实坐标].地块类型=地块类型
