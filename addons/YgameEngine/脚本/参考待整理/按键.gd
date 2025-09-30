extends Node
class_name 引擎按键

static func 确定按下回车键(event:InputEvent)->bool:
	if event is InputEventKey:
		if event.keycode==4194305:
			return true
	return false 

static func 判断是鼠标类型(event)->bool:
	return event is InputEventMouse

static func 判断是左键鼠标及触摸按下(event)->bool:
	if event.is_pressed():
		if event is InputEventScreenTouch:
			return true
		elif event is InputEventMouseButton:
			if event.button_index==1:
				return true
		
	return false
		
##回调按键，判断是否是鼠标或者触屏
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouse:
		#if 按钮按下:
			#print(event.position)
			#if 鼠标坐标==null:
				#鼠标坐标=event.position#记录初始坐标
			#else:
				#print("移动坐标:",event.position-鼠标坐标)
				#窗口.设置坐标(窗口.获取坐标()+event.position-鼠标坐标)
				#
