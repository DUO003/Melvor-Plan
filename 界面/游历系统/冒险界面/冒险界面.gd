extends 基类梅窗口
@onready var 内容节点: Control = %内容节点
var 冒险视口:=横版单例.冒险视口
var 冒险窗口:=横版单例.冒险窗口
var 游历地图:= preload("res://界面/游历系统/冒险界面/冒险地图.tscn")

func _ready() -> void:
	冒险加载检查()
	横版单例.重新加载地图.connect(冒险加载检查)
	#横版单例
func _exit_tree() -> void:
	横版单例.加载横版视口(内容节点,false)
func 冒险加载检查():
	if 冒险视口:
		计划.清除子节点(内容节点,冒险视口)
		if 横版单例.打开地图:
			横版单例.加载横版视口(内容节点,false)
			内容节点.add_child(游历地图.instantiate())
		else :
			横版单例.加载横版视口(内容节点,true)
	
func 窗口最大化(状态:bool)->bool:
	super(状态)
	if 状态:
		冒险窗口.size=Vector2(1900,970)
	else :
		冒险窗口.size=Vector2(1660,880)
	return true
