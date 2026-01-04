extends Panel
class_name 队列卡片
var 工作模式:String="炼金"
var 领取事件:Callable
var 取消事件:Callable
var 关闭取消事件:bool=false
var 配方=""
var 序号=0

var 队列数据:Array
var 炼金结果
var 缓存队列结果
func _ready() -> void:
	获取数据()
	if 配方=="":
		%"物品贴图".texture=null
	else :
		if 工作模式=="炼金":
			var 贴图名称=计划.手工.数据炼金配方(配方,"催化剂")
			%"物品贴图".texture=计划.表格.道具贴图(贴图名称)
			%"玩法图片".texture=preload("res://素材/豆包AI素材/炼金台.png")
		elif 工作模式=="烹饪":
			%"物品贴图".texture=计划.表格.道具贴图(配方)
			%"玩法图片".texture=preload("res://素材/豆包AI素材/图标/铁锅.png")
	计划.过去一秒.connect(更新UI事件)
	%"配方编号".text=str(序号+1)+"#号配方"
	%"领取".pressed.connect(func():领取事件.call())
	if 关闭取消事件:
		%"取消".visible=false
	else :
		%"取消".pressed.connect(func():取消事件.call())
	更新UI事件()
func 获取数据():
	if 工作模式=="炼金":
		队列数据=计划.手工.队列炼金()
	elif 工作模式=="烹饪":
		队列数据=计划.手工.队列烹饪()
	if 队列数据.size()>序号:
		缓存队列结果=队列数据[序号]
		配方=缓存队列结果["配方"]
	else :
		print("错误:配方队列不存在")
		queue_free()
		return
	
func 更新UI事件():
	获取数据()
	var 时间戳=缓存队列结果["时间戳"]
	var 当前时间=Time.get_unix_time_from_system()
	var 剩余时间=缓存队列结果["剩余"]*缓存队列结果["用时"]
	var 总时间: String=str(int(剩余时间+时间戳-当前时间))if 剩余时间>0 else "完成"
	var 剩余: String=str(缓存队列结果["剩余"])
	var 完成: String=str(缓存队列结果["完成"])
	if 缓存队列结果["剩余"]>0:
		%"进度条".max_value=缓存队列结果["用时"]
		%"进度条".value=当前时间-时间戳
	else :
		%"进度条".max_value=1
		%"进度条".value=1
	%"信息".text ="剩余:%s
完成:%s
总时间:%s"% [剩余, 完成, 总时间]
