extends Panel

@export var 显示时间:float=3
@export var 标签=""
var 文本 = ""
func _ready() -> void:
	$"文本".text=文本
	await get_tree().process_frame
	$"文本".set_size($"文本".get_combined_minimum_size())
	custom_minimum_size=$"文本".size+Vector2(10,-5)
	var 对齐 = 计划.配置文件.get("通知位置", "右")# 从配置文件读取对齐方式，默认靠右
	match 对齐:
		"左":# 与左侧对齐（等价于不设置标志，值为0）
			size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		"中":# 在可用空间中心对齐（值为4）
			size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_:# 与右侧对齐（值为8）
			size_flags_horizontal = Control.SIZE_SHRINK_END
	await get_tree().create_timer(显示时间).timeout
	var tween=create_tween()
	tween.set_parallel()
	tween.tween_property(self,"modulate:a",0,0.5)
	tween.tween_property(self,"custom_minimum_size:y",0,0.5)
	await tween.finished
	queue_free()
