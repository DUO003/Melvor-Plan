extends Panel
class_name 梅语言选择菜单
@onready var 多语言: OptionButton = $语言下拉菜单
@onready var 可用性警告: Label = $可用性警告
func _ready() -> void:
	可用性警告.visible=false
	多语言.clear()
	for 功能名称 in 计划.表格.语言映射表:
		多语言.add_item(功能名称)
	多语言.item_selected.connect(_当语言切换时)
	外部更新选中(计划.表格.当前使用语言)
# 自定义函数：语言切换触发的逻辑（中文函数名）
func _当语言切换时(选中索引: int):
	var 语言名:String = 多语言.get_item_text(选中索引)
	计划.表格.翻译切换(语言名)
	计划.更新_UI.emit()
	可用性警告.visible=true
func 外部更新选中(选择语言:String):
	# 遍历所有选项，查找匹配的文本
	for i in 多语言.get_item_count():
		if 多语言.get_item_text(i) == 选择语言:
			多语言.selected = i
			return
	多语言.selected = -1
