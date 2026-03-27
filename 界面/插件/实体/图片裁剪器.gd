extends Sprite2D

@export var 纹理节点: TextureRect

func _ready() -> void:
	visible = false
	# 仅保留核心裁剪逻辑：纹理存在、目标节点存在
	if texture and 纹理节点:
		纹理节点.texture = 截取图片(texture, region_rect)
func 截取图片(源纹理:Texture2D,瓦片区域:Rect2)->Texture2D:
	var 纹理 = AtlasTexture.new()
	纹理.atlas = 源纹理
	纹理.region = 瓦片区域
	return 纹理
