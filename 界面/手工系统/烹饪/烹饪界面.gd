extends 基类梅窗口
@onready var 料理卡片容器: HBoxContainer = %料理卡片容器
var 料理卡片 = preload("res://界面/手工系统/烹饪/料理卡片.tscn").instantiate()
@onready var 操作区: TabContainer = %操作区
@onready var 食材标签: TabContainer = %食材标签

func _ready() -> void:
	super._ready()
	计划.清除子节点(料理卡片容器)
	var 菜谱数组=计划.获取配方("料理")
	for 菜名 in 菜谱数组:
		var 菜谱=料理卡片.duplicate()
		菜谱.料理名称=菜名
		料理卡片容器.add_child(菜谱)
