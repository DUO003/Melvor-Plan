extends VBoxContainer
@export var 商品数组:Array[梅商品数据包]=[]
var 商品卡 = preload("res://界面/插件/物品辅助/商品卡.tscn").instantiate()
@onready var 商店容器: HBoxContainer = %商店容器

func _ready() -> void:
	计划.清除子节点(商店容器)
	for 商品数据 in 商品数组:
		var 商品卡场景=商品卡.duplicate()
		商品卡场景.商品=商品数据
		商店容器.add_child(商品卡场景)
