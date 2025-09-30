@tool  # 启用编辑器内预览
extends Sprite2D

# 导出变量：设置固定目标尺寸（像素）
@export var 目标宽度: int:
	set(值):
		目标宽度=值
		应用纹理(texture)
@export var 目标高度: int:
	set(值):
		目标高度=值
		应用纹理(texture)

# 从文件路径加载纹理并适配尺寸
func 从路径加载纹理(纹理路径: String) -> void:
	print("尝试从路径加载纹理：", 纹理路径)
	var 纹理 = load(纹理路径)
	if not 纹理:
		print("❌ 纹理加载失败：", 纹理路径)
		return
	应用纹理(纹理)

# 直接使用已加载的纹理并适配尺寸
func 应用纹理(纹理: Texture2D) -> void:
	# 检查纹理是否有效
	if not 纹理:
		print("❌ 传入的纹理无效")
		return
	
	# 检查纹理尺寸是否有效
	var 纹理宽度 = 纹理.get_width()
	var 纹理高度 = 纹理.get_height()
	if 纹理宽度 <= 0 or 纹理高度 <= 0:
		print("❌ 纹理尺寸无效：宽=", 纹理宽度, " 高=", 纹理高度)
		return
	
	# 调试信息
	#print("✅ 应用纹理成功，原始尺寸：", 纹理宽度, "x", 纹理高度)
	
	# 设置纹理
	self.texture = 纹理
	
	# 计算缩放比例
	var 缩放X: float = 目标宽度 / float(纹理宽度)
	var 缩放Y: float = 目标高度 / float(纹理高度)
	var 最小缩放: float = min(缩放X, 缩放Y)
	
	# 处理极端情况
	if 最小缩放 <= 0:
		print("⚠️ 缩放值异常，重置为1.0")
		最小缩放 = 1.0
	
	# 应用缩放
	self.scale = Vector2(缩放X, 缩放Y)
	#print("最终应用缩放：", self.scale)
