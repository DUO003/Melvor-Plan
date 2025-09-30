extends Control
signal 加入文本;
func _ready() -> void:
	#self.加入文本.emit("增加一个测试道具*"+str(randf_range(0, 20.5)))
#
	加入文本.connect(func(文本):
		var 准备加入列表的节点=$"视图/自动排序"
		var 准备加入的子节点=load("res://模块/简易悬浮模块/悬浮富文本子节点.tscn").instantiate()	
		准备加入的子节点.get_node("富文本").size.y=32
		准备加入的子节点.get_node("富文本").bbcode_enabled=true #启动BB颜色
		准备加入的子节点.get_node("富文本").text=文本
		准备加入列表的节点.add_child(准备加入的子节点)		
		)
	
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass




func _on_清空计时器_timeout() -> void:
	

	var 节点=$"视图/自动排序"
	if 节点.get_child_count()>=2:
		var 子节点2=节点.get_child(1)
		var tween = get_tree().create_tween()
		tween.tween_property(子节点2, "modulate", Color(1,1, 1, 0.01), 1)
		
	if 节点.get_child_count()>=1:
		var 子节点=节点.get_child(0)
		子节点.queue_free()
	
		
	
	pass # Replace with function body.
