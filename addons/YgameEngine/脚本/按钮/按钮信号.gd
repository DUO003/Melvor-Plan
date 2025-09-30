@tool #用于提前显示挂载音效挂到IDE的东西，不然看不到
extends Node
#region 用于按钮的事件逻辑，丢入按钮脚本下，然后去按钮回调统一处理
@export var 点击音效:AudioStream=引擎.按钮.点击音效
@export var 焦点音效:AudioStream=引擎.按钮.焦点音效
#endregion
@export var 切换场景:PackedScene
func _ready() -> void:
	#region 按下播放音乐
	self.button_down.connect(func ():
		引擎.按钮.按下事件.emit(self)
		if 点击音效!=null:
			引擎.场景.播放音效(点击音效)
		)
	#endregion
	#region 焦点进入播放音乐
	self.mouse_entered.connect(func():
		if 焦点音效!=null:
			引擎.场景.播放音效(焦点音效)
		)
#endregion


	
