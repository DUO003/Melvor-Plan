extends HBoxContainer
@export var 物品名称="测试文本"
func _ready() -> void:
	%"物品名称".text=物品名称
	%"物品名称".update_minimum_size()# 更新尺寸
	%"物品名称".set_size(%"物品名称".get_combined_minimum_size())
	更新UI()
	var 图片路径 = 计划.表格.获取表格信息(计划.表格.创世蓝图,物品名称,"icon")
	if 图片路径 != "":
		%"贴图".texture=load(图片路径)
	$"图片背景/点击".pressed.connect(func():
		计划.全局图钉(物品名称,false))
	计划.connect("更新_UI",func():更新UI())
	计划.更新_图钉.connect(更新图钉)
func 更新图钉(更新物品=物品名称):
	if 更新物品==物品名称:
		更新UI()
func 更新UI():
	if 物品名称=="金币":
		%"物品数量".text=str(计划.梅存档["金币"])
	else :
		%"物品数量".text=str(计划.检查背包物品数量(物品名称))
	%"物品数量".update_minimum_size()# 更新尺寸
	%"物品数量".set_size(%"物品数量".get_combined_minimum_size())
	var 最大X尺寸=max(%"物品名称".size.x,%"物品数量".size.x)
	$"物品信息".custom_minimum_size=Vector2(最大X尺寸, 80)
	$"物品信息".size=$"物品信息".custom_minimum_size
	#position=Vector2(0,0)
	#custom_minimum_size=size
