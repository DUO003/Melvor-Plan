extends ColorRect

@onready var 文本标签: Label = %提示文本
var 位置偏移X=0
func _ready() -> void:
	hide()
	GBIS.sig_item_focused.connect(func(物品: ItemData, 容器名称: String):
		show()
		更新文本(物品, 容器名称)
		print("焦点物品信号",物品))
	初始化.购买物品.connect(func(物品: ItemData, 容器名称: String):
		更新文本(物品, 容器名称)
		print("购买物品信号",物品))
	GBIS.sig_item_focus_lost.connect(func(_物品: ItemData): hide())
func 更新文本(物品: ItemData, 容器名称: String):
	文本标签.text=文本预处理(物品,容器名称)
	# 更新尺寸
	文本标签.update_minimum_size()
	文本标签.set_size(文本标签.get_combined_minimum_size())
	size = 文本标签.size + Vector2(16, 16)
	# 2. 计算视口右边界和X轴最大偏移值
	var 视口矩形 = get_viewport_rect()
	var 视口右边界 = 视口矩形.position.x + 视口矩形.size.x
	var 节点宽度 = size.x
	位置偏移X = 视口右边界 - 节点宽度  # 赋值X轴最大偏移值
	print("更新物品简介")
func _process(_delta: float) -> void:
	var 目标全局位置: Vector2 = get_global_mouse_position() + Vector2(5, 5)
	if 目标全局位置.x > 位置偏移X:
		目标全局位置.x = 位置偏移X
	global_position = 目标全局位置
func 文本预处理(物品: ItemData, 容器名称: String):
	var 文本=物品.item_name
	if 容器名称=="装备" or GBIS.opened_equipment_slots.has(容器名称):
		#文本=初始化.预生成文本(装备序号,true)
		文本 = str(物品.蓝图名称) + "\n"
		# 添加分类、类型、职业信息（文本类属性直接显示）
		文本 += str(物品.分类) + "类的" + str(物品.类型) + "\n职业:" + str(物品.职业) + "\n"
		# 处理耐久和耐久上限（合并显示，只要有一个非0就显示）
		if 物品.耐久 > 0 or 物品.耐久上限 > 0:
			文本 += "耐久: " + str(物品.耐久) + "/" + str(物品.耐久上限) + "\n"
		# 处理其他数值属性（非0才显示）
		if 物品.血量 > 0:
			文本 += "血量: " + str(物品.血量) + "\n"
		if 物品.攻击 > 0:
			文本 += "攻击: " + str(物品.攻击) + "\n"
		if 物品.魔法 > 0:
			文本 += "魔法: " + str(物品.魔法) + "\n"
		# 第二组属性（非0才显示）
		if 物品.回血 > 0:
			文本 += "回血: " + str(物品.回血) + "\n"
		if 物品.回蓝 > 0:
			文本 += "回蓝: " + str(物品.回蓝) + "\n"
		if 物品.闪避 > 0:
			文本 += "闪避: " + str(物品.闪避) + "\n"
		if 物品.暴击 > 0:
			文本 += "暴击: " + str(物品.暴击) + "\n"
		文本 = 文本.rstrip("\n")
	else :
		if GBIS.shop_names.has(容器名称):
			文本 = "[商店]"+物品.item_name
			if 物品 is 标准物品:
				文本 +="剩余:"+str(物品.商店剩余数量)
				文本 += "\n售价:"+str(物品.价值)+"\n简介:"
		if not 物品.get("简介"):
			文本+="\r%s" % ["简介错误"]
		else:
			文本+="\r%s" % [物品.简介]
	return 文本
