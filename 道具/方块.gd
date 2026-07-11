extends StackableData
class_name 物品方块
var 瓦片集:int
var 瓦片列:int
var 瓦片排:int
var 瓦片功能:String
var 功能参数:String
var 简介:String
var 瓦片尺寸:Vector2i
var 瓦片集对应字典:Dictionary[int,Texture2D]={
	0:preload("res://素材/MIT素材/黄色森林.png"),
	1:preload("res://素材/自制/图标/瓦片集.png"),
	2:preload("res://素材/综合/瓦片集.png"),
	3:preload("res://素材/综合/地块集合.png"),
	4:preload("res://素材/游戏素材/瓦片集/村子家具.png"),
	}
func 更新属性()->bool:
	var 方块数据:Dictionary=查询方块数据(item_name)
	if 方块数据.成功:
		堆叠上限=5
		简介=方块数据["简介"]
		columns=方块数据["列"]
		rows=方块数据["排"]
		瓦片集=方块数据["瓦片集"]
		瓦片列=方块数据["瓦片列"]
		瓦片排=方块数据["瓦片排"]
		瓦片功能=方块数据["功能"]
		功能参数=方块数据["功能参数"]
		瓦片尺寸=方块数据["瓦片尺寸"]
		var 源纹理: = 瓦片集对应字典[瓦片集]#根据瓦片集序号获取对应的源纹理
		if 源纹理 != null and 瓦片尺寸 != Vector2i.ZERO:
			var 瓦片位置X = (瓦片列) * 瓦片尺寸.x
			var 瓦片位置Y = (瓦片排) * 瓦片尺寸.y
			var 瓦片区域 = Rect2(瓦片位置X, 瓦片位置Y, 瓦片尺寸.x*columns, 瓦片尺寸.y*rows)
			icon = 截取图片(源纹理,瓦片区域)
		return true
	else :
		print("错误,未获取成功方块数据")
		return false
#封装方块数据查询逻辑的函数
func 查询方块数据(方块名称: String) -> Dictionary:
	var 结果 = {
		"成功": false,
		"堆叠上限": 5,       # int默认值
		"简介": "",          # String默认值
		"列": 0,             # int默认值
		"排": 0,             # int默认值
		"瓦片集": 0,         # int默认值
		"瓦片列": 0,         # int默认值
		"瓦片排": 0,         # int默认值
		"功能": "",          # String默认值
		"功能参数": "",      # String默认值
		"瓦片尺寸": Vector2i(0, 0)}  # Vector2i默认值
	var 方块字典 = 计划.表格.方块字典
	if 方块字典.has(方块名称):# 读取数据，找不到对应键时使用默认值
		结果["成功"] = true# 标记获取成功
		var 方块数据: Dictionary = 方块字典[方块名称]
		结果["简介"] = 方块数据.get("简介", 结果["简介"])
		结果["列"] = 方块数据.get("列", 结果["列"])
		结果["排"] = 方块数据.get("排", 结果["排"])
		结果["瓦片集"] = 方块数据.get("瓦片集", 结果["瓦片集"])
		结果["瓦片列"] = 方块数据.get("瓦片列", 结果["瓦片列"])
		结果["瓦片排"] = 方块数据.get("瓦片排", 结果["瓦片排"])
		结果["功能"] = 方块数据.get("功能", 结果["功能"])
		结果["功能参数"] = 方块数据.get("功能参数", 结果["功能参数"])
		var 尺寸数值:int = 方块数据.get("瓦片尺寸", 0)
		结果["瓦片尺寸"] = Vector2i(尺寸数值, 尺寸数值)
	return 结果
func 拷贝方法():#所有继承方法如果希望被正确拷贝都需要重写
	return 物品方块.new(1,item_name)
func 截取图片(源纹理:Texture2D,瓦片区域:Rect2)->Texture2D:
	var 纹理 = AtlasTexture.new()
	纹理.atlas = 源纹理
	纹理.region = 瓦片区域
	return 纹理
