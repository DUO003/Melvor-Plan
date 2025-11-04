extends Control

@export var 边框厚度 = 10:
	set(值):
		边框厚度 = 值
		# 当边框厚度改变时，自动更新所有矩形
		更新所有矩形()

var 矩形尺寸:Vector2=Vector2(340,240)
var 矩形中心点:Array[Vector2]=[
	Vector2(112,240),
	Vector2(8,360),
	Vector2(192,584),
	Vector2(152,496),
	Vector2(488,584),
	Vector2(264,320),
	Vector2(432,384),
	Vector2(488,200),] # 数组，内部保存每个矩形节点的position

#func _ready():
	#更新所有矩形()
func 更新所有矩形():
	# 确保有足够的中心点数据
	if 矩形中心点 == null or 矩形中心点.size() < 8:
		print("错误：矩形中心点数据不足")
		return
	
	# 遍历所有矩形节点（1到8）
	for i in range(1, 9):
		var 矩形节点名称 = "矩形节点" + str(i)
		var 矩形节点 = get_node(矩形节点名称)
		
		if 矩形节点 == null:
			print("错误：找不到节点 ", 矩形节点名称)
			continue
		
		# 设置矩形节点的尺寸和位置
		矩形节点.size = 矩形尺寸
		矩形节点.position = 矩形中心点[i-1] # 数组索引从0开始
		
		# 获取背景色节点
		var 背景色节点 = 矩形节点.get_node("背景色")
		if 背景色节点 == null:
			print("错误：在", 矩形节点名称, "中找不到背景色节点")
			continue
		
		# 设置背景色的尺寸和位置
		背景色节点.size = 矩形尺寸 - Vector2(边框厚度 * 2, 边框厚度 * 2)
		背景色节点.position = Vector2(边框厚度, 边框厚度)
		
		# 可选：设置边框节点（如果存在）
		var 边框节点 = 矩形节点.get_node("边框")
		if 边框节点:
			边框节点.size = 矩形尺寸
			边框节点.position = Vector2.ZERO
	%"身体".queue_redraw()
