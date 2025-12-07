@tool
extends InventoryView
func _ready() -> void:
	if not Engine.is_editor_hint():
		var 可用材料数组=计划.语法糖获取标签组(["炼金","催化","特殊催化"])
		可拿取类型=可用材料数组
	else :
		可拿取类型=[]
	super._ready()#运行上级节点的方法
