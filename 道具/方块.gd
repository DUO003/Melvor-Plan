extends StackableData
class_name 物品方块
var 瓦片集:int
var 瓦片列:int
var 瓦片排:int
var 瓦片功能:String
var 功能参数:String
var 瓦片集对应字典:Dictionary[int,Texture2D]={
	0:preload("res://素材/MIT素材/黄色森林.png"),
	1:preload("res://素材/自制/图标/瓦片集.png"),
	2:preload("res://素材/综合/瓦片集.png"),
	4:preload("res://素材/游戏素材/瓦片集/村子家具.png"),
	}
func 更新属性():
	var 方块字典=计划.表格.方块字典
	if 方块字典.has(item_name):
		var 方块数据:Dictionary=方块字典[item_name]
		var 瓦片资源:TileSet=load("res://代码/地图集/地图.tres")
		stack_size=64
		columns=方块数据["列"]
		rows=方块数据["排"]
		瓦片集=方块数据["瓦片集"]
		瓦片列=方块数据["瓦片列"]
		瓦片排=方块数据["瓦片排"]
		瓦片功能="解锁窗口"
		功能参数=方块数据["解锁窗口"]
		if 瓦片资源 != null:
			# 1. 根据瓦片集序号获取对应的源纹理（大图）
			var 源纹理: = 瓦片集对应字典[瓦片集]
			# 2. 获取单个瓦片的尺寸（宽高）
			var 瓦片尺寸 = 瓦片资源.get_tile_size()
			
			if 源纹理 != null and 瓦片尺寸 != Vector2i.ZERO:
				# 3. 计算瓦片在源纹理中的位置（行列从1开始则减1，根据你的配置表调整）
				# 公式：X = 列数 * 瓦片宽度，Y = 行数 * 瓦片高度
				var 瓦片位置X = (瓦片列) * 瓦片尺寸.x  # 若配置表列从0开始，去掉-1
				var 瓦片位置Y = (瓦片排) * 瓦片尺寸.y  # 若配置表行从0开始，去掉-1
				# 4. 定义瓦片的矩形区域（位置+尺寸）
				var 瓦片区域 = Rect2(瓦片位置X, 瓦片位置Y, 瓦片尺寸.x*columns, 瓦片尺寸.y*rows)
				# 5. 创建AtlasTexture（裁剪出单个瓦片）
				var 单个瓦片纹理 = AtlasTexture.new()
				单个瓦片纹理.atlas = 源纹理
				单个瓦片纹理.region = 瓦片区域
				# 6. 赋值给icon，背包即可显示
				icon = 单个瓦片纹理
