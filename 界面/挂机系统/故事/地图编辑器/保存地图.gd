@tool  # 启用编辑器内预览
extends TileMapLayer
class_name 可保存瓦片地图
@export var 地图资源: TileMapPattern
@export var 图案起点坐标: Vector2i
@export var 启用保存:bool=false:
	set(值):
		if 值:
			启用保存 = false
			保存地图()

func 保存地图()-> void:
	var 所有使用的单元格 = get_used_cells()
	if 所有使用的单元格.is_empty():
		图案起点坐标 = Vector2i(0, 0)
		地图资源 = null  # 用null标识空地图
	else :
		var 最小X:int = 所有使用的单元格[0].x
		var 最小Y:int = 所有使用的单元格[0].y
		for 图块 in 所有使用的单元格:
			if 图块.x < 最小X:最小X = 图块.x
			if 图块.y < 最小Y:最小Y = 图块.y
		图案起点坐标 = Vector2i(最小X, 最小Y)
		地图资源 = get_pattern(所有使用的单元格)
	print("保存成功地图")
