extends CanvasLayer

#
@export var 丰富剧情文本:String;
@export var 文本时间:float=3;
var 缓动:Tween ;

signal 创建剧情;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible=true;#默认弹出?
	print("出现这里",丰富剧情文本)
	self.创建剧情.connect(加入文本)
	self.emit_signal("创建剧情",丰富剧情文本)
	
	
	pass # Replace with function body.

func _on__Touch() -> void:#触摸点击
	print("点击到了??")
	if $丰富文本.visible_ratio<1:#快进
		缓动.stop()
		$丰富文本.visible_ratio=1
	else:#销毁
		hide()
		#queue_free()
	pass # Replace with function body.

func 加入文本(_文本):
	#func(_文本):
	visible=true;#默认弹出?
	print(_文本)
	$丰富文本.text=_文本;
	$丰富文本.visible_ratio=0
	缓动 = get_tree().create_tween()
	缓动.tween_property($丰富文本, "visible_ratio", 1, 文本时间)
	##)
	#pass
