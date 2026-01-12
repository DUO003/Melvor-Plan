extends Panel
class_name 梅悬浮提示
##最大宽度
var 宽度上限=800
var 屏幕尺寸:Vector2
var 节点:Node 
@onready var 富文本: RichTextLabel = %文本
func _ready() -> void:
	visible=false
	屏幕尺寸=计划.游戏分辨率
	计划.全局悬浮提示.connect(悬浮提示)
func 悬浮提示(文本方法:Callable,节点实例:Node,默认字体:int=40):
	var 文本=文本方法.call()
	if not 文本=="" or 节点实例==节点:
		更新文本(文本,默认字体)
		节点=节点实例
func 更新文本(文本内容="",默认字体:int=40):
	if 文本内容=="":
		visible=false
		return
	富文本.add_theme_font_size_override("normal_font_size",默认字体)
	富文本.add_theme_constant_override("paragraph_separation",int(默认字体*-0.5))
	富文本.add_theme_constant_override("line_separation",int(默认字体*-0.1))
	global_position = get_global_mouse_position() + Vector2(10, 10)
	富文本.text=文本内容
	富文本.autowrap_mode=TextServer.AUTOWRAP_OFF
	富文本.size=Vector2(50, 50)
	富文本.custom_minimum_size=Vector2(50, 50)
	var 范围=富文本.get_combined_minimum_size()
	if 范围.x>宽度上限:
		富文本.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		富文本.custom_minimum_size=Vector2(宽度上限, 50)
	富文本.size=富文本.get_minimum_size()
	#await get_tree().process_frame
	#await get_tree().process_frame
	富文本.size=富文本.get_minimum_size()
	size = 富文本.size + Vector2(16, 16)
	富文本.position=Vector2(8, 8)
	visible=true
func _process(_delta: float) -> void:
	if visible:
		global_position = get_global_mouse_position() + Vector2(10, 10)
		限制屏幕范围()

func 限制屏幕范围():
	if global_position.x+size.x>屏幕尺寸.x:
		global_position.x=屏幕尺寸.x-size.x
	elif global_position.x<0:
		global_position.x=0
	if global_position.y+size.y>屏幕尺寸.y:
		global_position.y=屏幕尺寸.y-size.y
	elif global_position.y<0:
		global_position.y=0
