extends VBoxContainer
@onready var 刷新计时: Label = %刷新计时
@onready var 体力刷新: Button = %体力刷新
func _ready() -> void:
	计划.过去一秒.connect(更新计时器)
	体力刷新.pressed.connect(商店刷新)
	更新计时器()
func 更新计时器():
	var 缓存时间戳=int(计划.梅存档["挂机"]["随身商店"].get("时间戳", Time.get_unix_time_from_system()))
	var 剩余秒数=计划.获取剩余秒数(缓存时间戳)
	刷新计时.text="商店刷新%s
手动刷新20体力"%计划.格式化时间(剩余秒数)
func 商店刷新():
	if 计划.体力门票(20):
		计划.商店刷新()
		计划.更新_UI.emit()
