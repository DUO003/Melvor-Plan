extends VBoxContainer
@onready var 商品贴图: TextureRect = %商品贴图
@onready var 商品图标: GridContainer = %商品图标
@onready var 小商品: 梅商品条 = %小商品
#func _ready() -> void:
	#更新商品信息()
func 更新商品信息(建筑:String):
	visible=true
	小商品.visible=false
	var 方块字典=计划.表格.方块字典
	计划.清除子节点(商品图标)
	for 方块名 in 方块字典:
		var 字典:Dictionary=方块字典[方块名]
		if 字典.has_all(["点数","点数类","解锁建筑"]) and 字典.解锁建筑==建筑:
			var 克隆贴图:TextureRect=商品贴图.duplicate()
			var 方块:物品方块=物品方块.new(1,方块名)
			克隆贴图.texture=方块.icon
			克隆贴图.custom_minimum_size=Vector2(75,75)
			克隆贴图.gui_input.connect(按钮逻辑.bind(方块名))
			商品图标.add_child(克隆贴图)
func 按钮逻辑(按键,方块名):
	if 按键 is InputEventMouseButton and 按键.pressed:
		if 按键.button_index == MOUSE_BUTTON_LEFT:
			小商品.更新界面(方块名)
