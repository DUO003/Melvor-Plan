@tool
extends ScrollContainer
const 瓶子 = preload("res://界面/插件/瓶子.tscn")
var 食材字典:Dictionary={}
var 食材上限=5
var 瓶子节点数组:Array=[]
@onready var 食材处理容器: HBoxContainer = %食材处理容器
@onready var 资源: Control = %资源

func _ready() -> void:
	if Engine.is_editor_hint():
		食材字典["白伞菇"]=3
	食材字典["白伞菇"]=3
	var 瓶子场景:梅计划_瓶子=瓶子.instantiate()
	var 随机=RandomNumberGenerator.new()
	for 食材 in 食材字典:
		var 瓶子克隆:梅计划_瓶子 = 瓶子场景.duplicate()
		随机.seed= hash(食材)
		瓶子克隆.内容长度=食材上限
		瓶子克隆.迷雾数量=0
		var 颜色:Color=Color(随机.randf(), 随机.randf(), 随机.randf())
		瓶子克隆.内容数组.clear()
		瓶子克隆.内容数组.append({颜色:食材字典[食材]})
		if not Engine.is_editor_hint():
			瓶子克隆.mouse_entered.connect(func():更新数据(食材,瓶子克隆))
			瓶子克隆.mouse_exited.connect(func():更新数据(null))
		食材处理容器.add_child(瓶子克隆)
		瓶子克隆.更新瓶子()

func 更新数据(食材,节点=null):
	if 食材字典.has(食材) and 节点:
		var 坐标=节点.global_position
		坐标.x+=节点.size.x*0.5
		资源.更新传入新值(食材,食材上限,食材字典[食材],坐标)
	else :资源.visible=false
