extends Control

@export var 着色器: ShaderMaterial  # 关联遮罩ShaderMaterial
var 矩形数组: Array[Rect2]=[]
func _ready():
	# 示例：定义遮罩矩形（x, y, width, height）
	获取矩形数组()
	更新着色器(矩形数组)# 传递矩形数据和容器尺寸到Shader
	#设置所有子节点使用父材质(%"玩家")
func 获取矩形数组():
	矩形数组 = []
	# 遍历当前节点的所有直接子节点
	var 偏移值 = %"颜色框组".position
	for 子节点 in %"颜色框组".get_children():
		# 检查子节点是否为Control类型（包括继承自Control的节点）
		if 子节点 is Control:
			# 获取子节点的位置（全局坐标）和大小
			var 位置 = 子节点.position+ 偏移值
			var 大小 = 子节点.size
			# 创建Rect2并添加到数组（Rect2参数：x, y, width, height）
			var 矩形=Rect2(位置.x, 位置.y, 大小.x, 大小.y)
			矩形数组.append(矩形)
			print("矩形",矩形)
	print("偏移值",偏移值)

# 更新遮罩矩形数组
func 更新着色器(数组: Array=矩形数组,):
	if not 着色器:# 检查材质是否赋值
		print("错误：着色器未赋值！请在编辑器中关联ShaderMaterial")
		return
	var shader = 着色器.get_shader()
	if not shader:# 检查材质关联的Shader是否正确
		print("错误：着色器未关联任何Shader！")
		return
	# 1. 传递容器自身尺寸（用于UV转像素坐标）
	着色器.set_shader_parameter("u_container_size", size)
	# 2. 传递矩形数据
	var 矩形数量 = min(数组.size(), 32)
	var V4矩形数组=[]
	for i in range(0, 矩形数量):
		# 检查数组元素是否为Rect2类型
		var rect = 数组[i]
		if not rect is Rect2:
			print("警告：矩形", i, "不是Rect2类型，跳过！")
			continue
		# 转换为Vector4并传递
		var V4矩形 = Vector4(rect.position.x, rect.position.y, rect.size.x, rect.size.y)
		V4矩形数组+=[V4矩形]
	着色器.set_shader_parameter("u_rects", V4矩形数组)
	着色器.set_shader_parameter("u_rect_count", 矩形数量)# 传递实际矩形数量
# 当容器尺寸变化时，同步更新Shader中的尺寸参数
func _on_resized():
	if 着色器:
		着色器.set_shader_parameter("u_container_size", size)
# 递归设置所有子节点（包括嵌套子节点）的use_parent_material为true（忽略无此属性的节点）
func 设置所有子节点使用父材质(节点: Node, 启用: bool = true) -> void:
	for 子节点 in 节点.get_children():# 遍历当前节点的直接子节点
		if "use_parent_material" in 子节点:# 检查子节点是否有use_parent_material属性
			子节点.use_parent_material = 启用# 设置属性
		设置所有子节点使用父材质(子节点, 启用)# 递归处理子节点的子节点（深度遍历所有层级）
#func _process(_delta: float) -> void:
	#$TextureRect.position = get_global_mouse_position()
