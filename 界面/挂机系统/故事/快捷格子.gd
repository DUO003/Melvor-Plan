extends Panel
@export var 快捷键:Key=Key.KEY_0
@export var 快捷编号:int=-1
@onready var 快捷文本: Label = $快捷键
@onready var 物品数量: Label = $物品数量
@onready var 按钮: Button = $按钮
@onready var 贴图: TextureRect = $贴图
func _ready() -> void:
	var 按键数组:Array=按钮.shortcut.events
	if not 按键数组.size()==0:
		var 新按键=InputEventKey.new()
		按钮.shortcut.events.append(新按键)
		按键数组=按钮.shortcut.events
	var 按键:InputEventKey=按键数组[0]
	按键.keycode=快捷键
	快捷文本.text=OS.get_keycode_string(按键.keycode)
	按钮.pressed.connect(切换物品栏)
	计划.地图.更新_快捷键栏.connect(更新物品栏)
	更新物品栏()
func 切换物品栏():
	计划.地图.快捷栏编号=快捷编号
	计划.地图.获取背包消息()
func 更新物品栏():
	var 快捷键字典:=计划.地图.快捷键字典
	if 快捷键字典.has(快捷编号):
		var 物品:物品方块=快捷键字典[快捷编号]
		贴图.texture=物品.icon
		物品数量.text=str(物品.current_amount)
	else :
		贴图.texture=null
		物品数量.text=""
	if 快捷编号==计划.地图.快捷栏编号:
		切换边框颜色(Color(0.451, 0.329, 0.086))
	else :
		切换边框颜色(Color(0.67, 0.543, 0.288, 1.0))
func 切换边框颜色(颜色:Color):
	var 获取样式:StyleBox=get_theme_stylebox("panel").duplicate()
	获取样式.border_color=颜色
	add_theme_stylebox_override("panel",获取样式)
