extends ReferenceRect

##测试一下
#测试一下
signal 点击;

func _gui_input(event: InputEvent) -> void:
	print("出发?2")
	if !event is InputEventScreenTouch:
		print("拦截了")
		return
	if event.is_pressed():
		emit_signal("点击");
		#print("触摸点击了:",event);
	pass # Replace with function body.
