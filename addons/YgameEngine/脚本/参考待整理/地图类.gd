extends Node
class_name 引擎地图类
static func 取玩家当前所在地图():
	return Engine.get_main_loop().root.get_node("游戏地图")
	
static func 取玩家当前所在地图的怪物数量()->int:
	var 玩家当前地图:Node2D=取玩家当前所在地图()
	return 玩家当前地图.get_node("怪物区").get_child_count()
	
static func 取地图可导航坐标(坐标:Vector2,格数=3) -> Vector2:
	var 地形=取玩家当前所在地图().get_node("游戏地形")
	#还需要取地图的偏移
	var 地图坐标:Vector2=地形.position
	#格数：不取当前地图格子，取左右两边的格数
	#获取图库 需要对怪物坐标转换
	var 获取设置的地图的图块大小=地形.tile_set.tile_size
	#取怪物所在的格子位置 -地图，算出所在网格
	var 计算坐标:Vector2
	计算坐标=坐标-地图坐标
	var 网格坐标:Vector2=Vector2(计算坐标.x / 获取设置的地图的图块大小.x,计算坐标.y / 获取设置的地图的图块大小.y).floor()
	var 取左右距离:Vector2
	for i in range(-格数,格数):
		if i!=0:
			var 获取图块数据;
			
			if 地形.get_cell_tile_data(0,Vector2i(网格坐标.x+i,网格坐标.y))!=null:
				#第一层没问题优先用这个
				获取图块数据=地形.get_cell_tile_data(0,Vector2i(网格坐标.x+i,网格坐标.y))
			elif 地形.get_cell_tile_data(1,Vector2i(网格坐标.x+i,网格坐标.y))!=null:
				#不行就用第二层的
				获取图块数据=地形.get_cell_tile_data(1,Vector2i(网格坐标.x+i,网格坐标.y))
			
			#调试输出.打印(获取图块数据,"获取所在第0层[地形]图块数据:")
			if 获取图块数据!=null:
				var 获取导航多边形数据=获取图块数据.get_navigation_polygon(0) #导航0层
				
				if 获取导航多边形数据!=null:#判断有导航即可
					var 获取导航顶点=获取导航多边形数据.get_outline(0) #第0个的导航
					var _计算 = 获取导航顶点[2].x-获取导航顶点[0].x
					if i<0:
						取左右距离.x -= abs(_计算)
					if i>0:
						取左右距离.y += abs(_计算)
	return 取左右距离	
	pass
