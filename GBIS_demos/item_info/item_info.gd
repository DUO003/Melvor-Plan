extends ColorRect

@onready var 文本标签: Label = %提示文本

func _ready() -> void:
	hide()
	GBIS.sig_item_focused.connect(func(item_data: ItemData, container_name: String): 
		show()
		var 文本=""
		if GBIS.shop_names.has(container_name):
			文本 = "[商店]"
		if not item_data.get("简介"):
			文本+="%s\r%s" % [item_data.item_name,"简介错误"]
		else:
			文本+="%s\r%s" % [item_data.item_name,item_data.简介]
		文本标签.text=文本
		# 更新尺寸
		文本标签.update_minimum_size()
		文本标签.set_size(文本标签.get_combined_minimum_size())
		size = 文本标签.size + Vector2(16, 16)
		)
	GBIS.sig_item_focus_lost.connect(func(_item_data: ItemData): hide())

func _process(_delta: float) -> void:
	position = get_global_mouse_position() + Vector2(5, 5)
