extends Panel
class_name 队列卡片
#var 领取事件:Callable
#var 取消事件:Callable
var 序号=0
var 队列数据:梅队列数据
##使用回调节点需要在场景定义对应界面更新方法
var 回调节点:Control=null
##接收参数,梅队列数据
var 界面更新方法:Callable
func _ready() -> void:
	if not 队列数据:
		%"物品贴图".texture=null
		print("队列卡片数据加载失败")
		return
	if 队列数据 is 梅炼金数据:
		var 贴图名称=队列数据.催化剂
		%"物品贴图".texture=计划.表格.道具贴图(贴图名称)
		%"玩法图片".texture=preload("res://素材/豆包AI素材/炼金台.png")
		print("炼金数据已加载")
	elif 队列数据 is 梅烹饪数据:#未完成
		%"物品贴图".texture=计划.表格.道具贴图(队列数据.烹饪菜谱)
		%"玩法图片".texture=preload("res://素材/豆包AI素材/图标/铁锅.png")
	计划.过去一秒.connect(更新UI事件)
	%"配方编号".text=str(序号+1)+"#号配方"
	%"领取".pressed.connect(领取奖励)
	if 队列数据.是否可放弃任务():
		%"取消".pressed.connect(放弃任务)
	else :
		%"取消".visible=false
	更新UI事件()
func 领取奖励():
	队列数据.领取奖励.call()
	界面更新方法.call(队列数据)
func 放弃任务():
	if 回调节点:
		回调节点.取消制作弹窗(队列数据.放弃任务)
		界面更新方法.call()
	else :
		队列数据.放弃任务.call()
func 更新UI事件():
	var 时间戳=队列数据.队列时间戳
	var 当前时间=Time.get_unix_time_from_system()
	var 剩余时间=队列数据.队列数量*队列数据.耗时计算方法()
	var 总时间: String=str(int(剩余时间+时间戳-当前时间))if 剩余时间>0 else "完成"
	var 剩余: String=str(队列数据.队列数量)
	var 完成: String=str(队列数据.队列完成)
	if 队列数据.队列数量>0:
		%"进度条".max_value=队列数据.耗时计算方法()
		%"进度条".value=当前时间-时间戳
	else :
		%"进度条".max_value=1
		%"进度条".value=1
	%"信息".text ="剩余:%s
完成:%s
总时间:%s"% [剩余, 完成, 总时间]
