extends Node
class_name 梅地图
@warning_ignore("unused_signal")
##当玩家进入可交互目标位置时又交互目标发出
signal 更新_交互(增加:bool,内容:String,节点:Node,强制:bool)
var 交互字典:Dictionary={}
func _ready() -> void:
	更新_交互.connect(交互保存)
func 交互保存(增加:bool,内容:String,节点:Node,_强制:bool):
	if 增加:
		交互字典[节点]=内容
	else :
		交互字典.erase(节点)
