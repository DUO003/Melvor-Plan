extends 基类梅窗口
@onready var 料理卡片容器: HBoxContainer = %料理卡片容器
var 料理卡片 = preload("res://界面/手工系统/烹饪/料理卡片.tscn").instantiate()
@onready var 操作区: TabContainer = %操作区
@onready var 食材标签: TabContainer = %食材标签
@onready var 启用自动制作: CheckButton = %启用自动制作
@onready var 制作数量: SpinBox = %制作数量

func _ready() -> void:
	super._ready()
	计划.清除子节点(料理卡片容器)
	var 菜谱数组=计划.获取配方("料理")
	制作数量.value_changed.connect(func(_更新值):
		if not 启用自动制作.button_pressed:
			启用自动制作.button_pressed=true)
	#计划.手工.检查并更新队列("烹饪")#由于克隆位于子节点,为保证有效执行这段代码被复制到子节点执行
	计划.过去一秒.connect(func():计划.手工.检查并更新队列("烹饪"))
	for 菜名 in 菜谱数组:
		var 菜谱=料理卡片.duplicate()
		菜谱.料理名称=菜名
		菜谱.启用自动制作节点=启用自动制作
		菜谱.制作数量节点=制作数量
		启用自动制作.pressed.connect(菜谱.更新标签)
		制作数量.value_changed.connect(func(_更新值):菜谱.更新标签())
		料理卡片容器.add_child(菜谱)
