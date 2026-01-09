extends ScrollContainer

# 重写GUI控件的输入事件处理函数，专门拦截滚轮事件
func _gui_input(event: InputEvent) -> void:
	# 判断事件是否是鼠标滚轮事件
	if event is InputEventMouseButton:
		# 接受这个事件（阻止事件继续传递给ScrollContainer的默认处理逻辑）
		accept_event()
