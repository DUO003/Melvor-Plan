extends Panel
class_name 炼金队列卡片
var 领取事件:Callable
var 取消事件:Callable
var 炼金哈希=""
var 序号=0

var 队列炼金:Array
var 炼金结果
var 缓存队列结果
func _ready() -> void:
	队列炼金=计划.手工.队列炼金()
	if 队列炼金.size()>=序号:
		缓存队列结果=队列炼金[序号]
	else :
		print("错误:配方队列不存在")
		queue_free()
		return
	if 炼金哈希=="":
		%"药水".texture=null
	else :
		var 贴图名称=计划.手工.数据炼金配方(炼金哈希,"催化剂")
		%"药水".texture=计划.表格.道具贴图(贴图名称)
	%"配方编号".text=str(序号+1)+"#号配方"
	%"领取".pressed.connect(func():领取事件.call())
	%"取消".pressed.connect(func():取消事件.call())
	计划.手工.更新_炼金卡片.connect(更新UI事件)
	更新UI事件()
func 更新UI事件():
	队列炼金=计划.手工.队列炼金()
	if 队列炼金.size()>=序号:
		缓存队列结果=队列炼金[序号]
	else :
		print("错误:配方队列不存在")
		queue_free()
		return
	var 时间戳=缓存队列结果["时间戳"]
	var 当前时间=Time.get_unix_time_from_system()
	var 剩余时间=缓存队列结果["剩余"]*缓存队列结果["用时"]
	var 总时间: String=str(int(剩余时间+时间戳-当前时间))if 剩余时间>0 else "完成"
	var 剩余: String=str(缓存队列结果["剩余"])
	var 完成: String=str(缓存队列结果["完成"])
	%"进度条".max_value=缓存队列结果["用时"]
	%"进度条".value=当前时间-时间戳
	%"信息".text ="剩余:%s
完成:%s
总时间:%s"% [剩余, 完成, 总时间]
