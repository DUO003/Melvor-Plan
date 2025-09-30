@tool
extends StyleBox
class_name 嵌套数组样式

@export var 样式数组:Array[StyleBox]:
	set(值):
		样式数组=值
		for c in 样式数组:
			if c==null:continue
			if not c.changed.is_connected(emit_changed):
				c.changed.connect(emit_changed)
		emit_changed()
func _draw(目标画布:RID,矩形:Rect2)->void:
	for 样式 in 样式数组:
		if 样式:
			样式.draw(目标画布,矩形)
