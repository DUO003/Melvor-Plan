@tool
extends InventoryView
func _ready() -> void:
	var 可用材料数组=初始化.语法糖获取标签组(["炼金","催化"])
	可拿取类型=可用材料数组
	super._ready()#运行上级节点的方法
