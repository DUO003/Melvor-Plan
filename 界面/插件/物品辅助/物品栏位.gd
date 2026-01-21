extends Control
##替代背包插件功能
class_name 梅物品栏位
@export var 字体:Font
@export var 字号:int
@export var 字色:Color
@export var 物品:ItemData
@export var 大小:Vector2
@export var 间隔:int
@export var 样式:StyleBox
var 默认字体:Font
var 显示物品=true
@warning_ignore("shadowed_variable")
func _init(样式:StyleBox=null,格子尺寸:int=10,字体:Font=默认字体,字号:int=30,字色:Color=Color(0,0,0),间隔:int=3)->void:
	self.字体 = 字体
	self.字号 = 字号
	self.字色 = 字色
	self.大小 = Vector2(格子尺寸,格子尺寸)
	self.间隔 = 间隔
	self.样式 = 样式
	custom_minimum_size=大小
	#add_theme_stylebox_override("panel", 样式)
func _ready() -> void:
	计划.更新_图钉.connect(更新判断)
	GBIS.更新移动物品.connect(更新鼠标物品)
	mouse_entered.connect(显示简介)
	mouse_exited.connect(隐藏简介)
func 更新判断(物品名:String):
	if 物品 and 物品.item_name==物品名:
		queue_redraw()
func 显示简介():
	计划.全局悬浮提示.emit(返回格子物品简介,self,30)
func 隐藏简介():
	计划.全局悬浮提示.emit(func():return "",self)
func 返回格子物品简介()->String:
	if 显示物品 and 物品:
		return 物品.返回简介("")
	return ""
func 更新鼠标物品():
	if not GBIS.has_moving_item():
		显示物品=true
		queue_redraw()
func _gui_input(按键信号: InputEvent):
	if 按键信号 is InputEventMouseButton and 按键信号.pressed:
		if 按键信号.button_index == MOUSE_BUTTON_LEFT:
			if not GBIS.has_moving_item():
				拿起物品()
func 拿起物品():
	GBIS.moving_item_service.move_item_by_data(物品, Vector2i.ZERO, int(大小.x))
	显示物品=false
	queue_redraw()
func _draw():
	var 矩形:Rect2=Rect2(Vector2(0,0),大小)
	draw_style_box(样式,矩形)
	if 物品 and 显示物品:
		var 物品贴图:Texture2D=物品.icon
		draw_texture_rect(物品贴图, 矩形, false)
		if 物品 is StackableData and 物品.current_amount>1:
			var 文本:String=str(物品.current_amount)
			var 宽度:Vector2 = 字体.get_string_size(文本, HORIZONTAL_ALIGNMENT_RIGHT, -1,字号)
			var 起点:Vector2 = Vector2(矩形.size.x-宽度.x-间隔,矩形.size.y-字体.get_descent(字号)-间隔)
			# 绘制堆叠数量文本：使用指定字体、位置、文本内容、对齐、限制宽度、指定字号 颜色
			矩形=Rect2(Vector2(大小.x-宽度.x-2*间隔,大小.y-宽度.y-间隔),宽度+Vector2(2*间隔,间隔))
			draw_style_box(样式,矩形)
			draw_string(字体, 起点, 文本, HORIZONTAL_ALIGNMENT_RIGHT, -1, 字号, 字色)
