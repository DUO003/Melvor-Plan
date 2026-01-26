extends Button
@onready var 玩家:大地图玩家 = $"../地图容器/地图渲染层/玩家"
@onready var 地图: 大地图管理 = $"../地图容器/地图渲染层/地图"
func _ready() -> void:
	pressed.connect(点击)
func 点击():
	var 鼠标全局:Vector2 = 地图.get_global_mouse_position()
	if not 地图.返回方块ID(鼠标全局,地图.地图层)==-1:
		玩家.启用自动前进=true
		玩家.自动前进目标=鼠标全局.x
