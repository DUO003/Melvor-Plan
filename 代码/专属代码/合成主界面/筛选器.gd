extends TextureButton
var 按钮图片字典 = {
	"本体": "res://素材/像素/所有.png",
	"武器": "res://素材/像素/武器.png",
	"防具": "res://素材/像素/防具.png",
	"元素": "res://素材/像素/元素.png",
	"道具": "res://素材/像素/道具.png"
}
var 类型 = "长剑"
func _ready():
	@warning_ignore("unused_variable")
	var 功能 = get_meta("gn", "错误")
	var 序号 = int(get_meta("xh", 0))
	
	#print("节点加入场景，功能: ", str(功能))
	
	if 序号 >= 1:
		position.y -= 10+序号 * 85



func _筛选器() -> void:
		# 获取父节点
	var 父节点 = self.get_parent()
	if 父节点 == null:
		return  # 没有父节点则直接返回
	
	# 获取父节点下的所有子节点
	var 子节点列表 = 父节点.get_children()
	
	# 检查是否只有自己一个子节点
	if 子节点列表.size() == 1 and 子节点列表[0] == self:
		# 创建4个自身副本并设置不同的元数据
		var 类型列表 = ["武器", "防具", "元素", "道具"]
		类型列表.reverse()
		var 序号=0
		for 当前类型 in 类型列表:
			# 复制自身
			序号 += 1
			var 新节点 = self.duplicate()
			# 将克隆体大小缩小到默认大小的0.8倍
			新节点.scale = Vector2(0.8, 0.8)
			# 设置元数据
			新节点.set_meta("gn", 当前类型)
			新节点.set_meta("xh", 序号)
			# 设置按钮图片
			var 图片路径 = 按钮图片字典.get(当前类型, "")
			if 图片路径 != "":
				var 纹理 = load(图片路径)
				if 纹理 != null:
					新节点.texture_normal = 纹理
			else:
				print("无法加载图片: ", 图片路径)
			# 添加到父节点
			父节点.add_child(新节点)
			
	else:
		# 如果存在多个子节点，删除除了自己以外的所有节点
		for 子节点 in 子节点列表:
			if 子节点 != self:
				子节点.queue_free()  # 安全删除节点
		scale = Vector2(1, 1)
		position = Vector2(0, 425)
	pass # Replace with function body.
