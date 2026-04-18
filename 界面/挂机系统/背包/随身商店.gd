extends VBoxContainer
@onready var 刷新计时: Label = %刷新计时
@onready var 体力刷新: Button = %体力刷新
@onready var 扩容费用: Label = %扩容费用
@onready var 扩容: Button = %扩容
@onready var 商店_容器: ShopView = %商店
func _ready() -> void:
	计划.过去一秒.connect(更新计时器)
	体力刷新.pressed.connect(商店刷新)
	更新计时器()
	扩容.pressed.connect(扩容商店)
	扩容提示更新()
func 扩容提示更新():
	var 列数:int=商店_容器.container_rows
	var 消耗数量:int=(列数*160)
	if 列数>=3:
		扩容费用.text="<版本最大值>"
	else :
		扩容费用.text=tr("<扩容提示>")%[消耗数量,计划.表格.翻译名称("绿色电路板")]
func 扩容商店():
	var 背包数量=计划.检查背包物品数量("绿色电路板")
	var 列数:int=商店_容器.container_rows
	if 列数>=3:
		计划.语法糖通知(tr("<扩容失败上限>"))
		return
	var 消耗数量:int=(列数*160)
	if not 背包数量>=消耗数量:
		计划.语法糖通知(tr("<扩容失败材料>")%[tr("随身商店"),计划.表格.翻译名称("绿色电路板")])
		return
	计划.语法糖消耗物品("绿色电路板",消耗数量)
	var 背包数据:Dictionary=计划.梅存档.挂机.背包数据
	if not 背包数据.has("随身商店"):
		背包数据["随身商店"]={}
	背包数据["随身商店"].行数=商店_容器.container_rows+1
	计划.语法糖通知("%s扩容成功"%tr("随身商店"))
	计划.切换场景("背包界面",true)
func 更新计时器():
	var 缓存时间戳=int(计划.梅存档["挂机"]["随身商店"].get("时间戳", Time.get_unix_time_from_system()))
	var 剩余秒数=计划.获取剩余秒数(缓存时间戳)
	var 内容数组:Array=[
		tr("<刷新商店计时>")%[计划.格式化时间(剩余秒数)],
		tr("<手动刷新商店>")%[20]]
	刷新计时.text="\r".join(内容数组)
func 商店刷新():
	if 计划.体力门票(20):
		计划.商店刷新()
		计划.更新_UI.emit()
