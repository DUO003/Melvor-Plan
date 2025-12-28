extends Panel
class_name 梅商品卡片
@export var 商品:梅商品数据包
@export var 购买数量:int=1
@onready var 图片: TextureRect = $图片
@onready var 价格: RichTextLabel = $价格

func _ready() -> void:
	更新界面()
	gui_input.connect(gui点击逻辑)
func 更新界面():
	图片.texture=计划.表格.道具贴图(商品.商品名)
	价格.text="%s\r%d[img=60x60]%s[/img]"%[商品.商品名,商品.费用*购买数量,计划.表格.道具贴图(商品.代币).resource_path]
	
func gui点击逻辑(按键):
	if 按键 is InputEventMouseButton and 按键.pressed:
		更新界面()
		if 按键.button_index == MOUSE_BUTTON_LEFT:
			购买逻辑()
func 购买逻辑():
	var 背包内代币=计划.检查背包物品数量(商品.代币)
	if 背包内代币>=商品.费用*购买数量:
		计划.语法糖消耗物品(商品.代币,购买数量*商品.费用)
		计划.获得物品语法糖(商品.商品名,购买数量*商品.商品数量)
		计划.更新_UI.emit()
