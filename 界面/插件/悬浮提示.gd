extends Panel
##最大宽度
var 宽度上限=800
var 屏幕尺寸:Vector2
func _ready() -> void:
	visible=false
	屏幕尺寸=计划.游戏分辨率
func 更新文本(文本内容=""):
	global_position = get_global_mouse_position() + Vector2(10, 10)
	%"文本".text=文本内容
	%"文本".autowrap_mode=TextServer.AUTOWRAP_OFF
	%"文本".size=Vector2(50, 50)
	%"文本".custom_minimum_size=Vector2(50, 50)
	var 范围=%"文本".get_combined_minimum_size()
	if 范围.x>宽度上限:
		%"文本".autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		%"文本".custom_minimum_size=Vector2(宽度上限, 50)
	%"文本".size=%"文本".get_minimum_size()
	#await get_tree().process_frame
	#await get_tree().process_frame
	%"文本".size=%"文本".get_minimum_size()
	size = %"文本".size + Vector2(16, 16)
	%"文本".position=Vector2(8, 8)
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
