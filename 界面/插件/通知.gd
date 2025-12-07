extends Panel
class_name 通知场景
@export var 显示时间:float=3
@export var 标签=""
var 点击动作=null
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
	if 点击动作==null:
		$"按钮".visible=false
		await get_tree().create_timer(显示时间).timeout
		var tween=create_tween()
		tween.set_parallel()
		tween.tween_property(self,"modulate:a",0,0.5)
		tween.tween_property(self,"custom_minimum_size:y",0,0.5)
		await tween.finished
		queue_free()
	else :
		计划.删除强调通知.connect(删除强调通知)
		$"按钮".visible=true
		$"按钮".pressed.connect(func():
			if 点击动作 is Callable:
				点击动作.call()
			queue_free())
func 删除强调通知(通知):
	if 通知=="" or 通知==标签:
		queue_free()
