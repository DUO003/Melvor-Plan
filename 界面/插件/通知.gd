extends Panel
class_name 通知场景
@export var 显示时间:float=3
@export var 标签=""
var 前辈:通知场景
var 点击动作=null
var 文本:String = ""
var 鼠标位置:Vector2
signal 跟随前进(距离:float)
const 鼠标位置误差阈值:float = 10.0
var 动画进度条:float=0
var 通知位置
var 文本节点: RichTextLabel
func _ready() -> void:
	文本节点 = $文本
	文本节点.text=文本
	await get_tree().process_frame
	文本节点.set_size(文本节点.get_combined_minimum_size())
	custom_minimum_size=文本节点.size+Vector2(10,0)
	#print(custom_minimum_size,计划.文本节点宽度(文本节点))
	通知位置 = 计划.配置文件.get("通知位置", "右")# 从配置文件读取对齐方式，默认靠右
	if 通知位置=="悬浮":
		鼠标位置=get_global_mouse_position()
		if 前辈 and 前辈.鼠标位置.distance_to(鼠标位置) <= 鼠标位置误差阈值:
			var 坐标:Vector2=前辈.position
			坐标.y+=前辈.size.y
			position=坐标
			前辈.tree_exiting.connect(前辈逻辑)
			前辈.跟随前进.connect(跟随逻辑)
		else :
			global_position=鼠标位置+Vector2(20,-10)
		$"按钮".visible=false
		显示时间=计划.配置文件.get("通知显示时长",0)
		if 显示时间<=0:显示时间=3
		await get_tree().create_timer(显示时间).timeout
		var 动画=create_tween()
		动画.set_parallel()
		动画.tween_property(self,"modulate:a",0,0.25)
		await 动画.finished
		queue_free()
	else :
		match 通知位置:
			"左":size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			"中":size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			_:size_flags_horizontal = Control.SIZE_SHRINK_END
		if 点击动作==null:
			$"按钮".visible=false
			显示时间=计划.配置文件.get("通知显示时长",0)
			if 显示时间<=0:显示时间=3
			await get_tree().create_timer(显示时间).timeout
			var 动画=create_tween()
			动画.set_parallel()
			动画.tween_property(self,"modulate:a",0,0.25)
			动画.tween_property(self,"custom_minimum_size:y",0,0.25)
			await 动画.finished
			queue_free()
		else :
			计划.删除强调通知.connect(删除强调通知)
			$"按钮".visible=true
			$"按钮".pressed.connect(func():
				if 点击动作 is Callable:
					点击动作.call()
				queue_free())
func _process(时间):
	if 通知位置=="悬浮":
		position.y+=时间*-20
func 前辈逻辑():
	if 前辈:
		跟随逻辑(前辈.size.y)
func 跟随逻辑(距离:float):
	position.y-=距离
	跟随前进.emit(距离)
func 删除强调通知(通知):
	if 通知=="" or 通知==标签:
		queue_free()
