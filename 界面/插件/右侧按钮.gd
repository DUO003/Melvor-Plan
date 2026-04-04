extends HBoxContainer
@onready var 存档功能区: HBoxContainer = %"存档功能区"
@onready var 时间文本: Label = %存档时间文本
@onready var 存档: Button = %存档按钮
@onready var 展开按钮: Button = %展开按钮
@onready var 暂停: Button = %暂停
func _ready():
	时间文本.text="未存档"
	存档.pressed.connect(手动存档)
	计划.过去一秒.connect(更新显示)
	计划.更新_UI.connect(更新显示)
	展开界面(false)
	展开按钮.pressed.connect(切换展开界面)
	暂停.pressed.connect(显示暂停界面)
func 显示暂停界面():
	计划.显示暂停界面.emit(true)
func 切换展开界面():
	展开界面(not 存档功能区.visible)
func 展开界面(展开:bool):
	存档功能区.visible=展开
	if 展开:
		展开按钮.text=">"
	else :
		展开按钮.text="<"
func 手动存档():
	if GBIS.has_moving_item():
		GBIS.moving_item_service.安全清除移动物品()
	计划.保存存档("手动存档")
	计划.语法糖通知("手动存档成功可以安全关闭","手动存档")
	计划.emit_signal("更新_UI")
	
func 更新显示():
	if 计划.存档时间戳==-1:
		时间文本.text="未存档"
		return
	var 总秒数=Time.get_unix_time_from_system()-计划.存档时间戳
	if 总秒数>60:
		时间文本.text=计划.格式化时间(总秒数)+"前"
	elif 总秒数>3600:
		时间文本.text="大于1小时"
	elif 总秒数<1:
		时间文本.text="已保存"
	else :
		时间文本.text=计划.格式化时间(总秒数)+"秒前"
