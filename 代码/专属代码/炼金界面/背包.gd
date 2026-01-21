@tool
extends InventoryView
@onready var 根节点: FoldableContainer = $"../../.."

func _ready() -> void:
	if not Engine.is_editor_hint():
		可拿取类型=计划.语法糖获取标签组(根节点.白名单)
	else :
		可拿取类型=[]
	super._ready()#运行上级节点的方法
