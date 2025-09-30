extends Node
class_name 引擎图片

func 从偏移裁剪图片(图片地址,_x,_y,_sx,_sy):
	var 图片=load(图片地址)
	var 裁剪图片=图片.get_image()
	var _rect=Rect2i(int(_x),int(_y),int(_sx),int(_sy))
	裁剪图片=裁剪图片.get_region(_rect)#进行裁剪
	#读取裁剪图片的纹理
	var texture = ImageTexture.new() 
	texture.set_image(裁剪图片)
	return texture

# 图片缓存字典，键为完整路径，值为加载的纹理
var 缓存图片 = {}
# 加载图片（带缓存）
# 返回：加载成功的纹理，失败返回 null
func 加载图片(图片路径: String) -> Texture2D:
	# 检查缓存，存在则直接返回
	if 图片路径 in 缓存图片:
		return 缓存图片[图片路径]
	# 缓存不存在，加载图片
	var 纹理 = load(图片路径)
	# 加载成功则存入缓存
	if 纹理:
		缓存图片[图片路径] = 纹理
	else:
		print("图片加载失败：", 图片路径)	
	return 纹理
