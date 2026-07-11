extends Panel
class_name 梅回合制目标
@onready var 图片: TextureRect = $图片
var 实体引用:梅回合制实体
var 当前进度:float=0
var 基础速度:float=0.5
##实体更新调整的排序,先根据阵营 玩家>怪物,然后是通过位置进行排序
var 出手优先级:int=1
var 随机速度倍率:float=1
var 贴图:Texture
func _ready() -> void:
	图片.texture=贴图
