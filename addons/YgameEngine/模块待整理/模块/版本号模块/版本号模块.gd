extends Label
@export var _游戏名称:String="";
@export var _版本号:float=1.01;
@export var _简介:String="";

func _ready() -> void:
	
	#var 节点:Label=get_parent();
	
	if _游戏名称!="":
		DisplayServer.window_set_title("%s Ver %s" % [_游戏名称,_版本号])
		
	text="\n 版本:%s " % [_版本号];
	
	if _简介=="":return;
	text+="\n 简介:"+_简介;
	
