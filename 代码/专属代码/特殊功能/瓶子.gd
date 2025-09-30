extends Control
@export var 内容长度: int
@export var 内容数组: Array[Dictionary]
# 渐变相关变量（中文命名）
var 当前颜色: Color = Color(randf(), randf(), randf())  # 初始颜色（红色）
var 目标颜色: Color = Color(randf(), randf(), randf())  # 目标颜色（绿色）
var 过渡速度: float = 2  # 渐变速度（值越小越慢）
var 迷雾数量=0
func _ready():
	# 初始化"排序"节点的颜色
	%"排序".颜色 = 当前颜色
func _process(delta: float) -> void:
	# 每帧将当前颜色向目标颜色渐变一小步
	当前颜色 = 当前颜色.lerp(目标颜色, delta * 过渡速度)
	%"排序".颜色 = 当前颜色
	var 颜色差异: float = abs(当前颜色.r - 目标颜色.r) + abs(当前颜色.g - 目标颜色.g) +abs(当前颜色.b - 目标颜色.b)
	# 当颜色接近目标时，切换新的目标颜色（实现循环渐变效果）
	if 颜色差异 < 0.02:
		# 随机生成新的目标颜色
		目标颜色 = Color(randf(), randf(), randf())
		# 固定颜色循环示例（取消注释即可使用）
		# 目标颜色 = (目标颜色 == Color(1,0.2,0.2)) ? Color(0.2,1,0.2) : Color(1,0.2,0.2)
func 更新瓶子():
	%选中.visible=false
	%"排序".内容长度=内容长度
	%"排序".内容数组=内容数组
	迷雾()
func 选中(显示):
	%"瓶子".visible=显示
	%选中.visible=not 显示
func 迷雾(仅更新=false):
	if 仅更新:
		迷雾数量 = 内容数组.size() - 1
	else :
		if 迷雾数量>=内容数组.size():
			迷雾数量 = 内容数组.size() - 1
	%"排序".迷雾数量=迷雾数量
	if 迷雾数量>0:
		%"迷雾".visible=true
	else :
		%"迷雾".visible=false
