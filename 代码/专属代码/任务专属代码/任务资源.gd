extends Resource
class_name 任务资源
@export var 任务名称:String=""
##完成的任务不会存储,而是加载时重新生成
@export var 任务完成:bool=false
##未推进的任务不会被储存
@export var 任务数据:Array=[]
##任务是否领取,影响推进任务的计算
@export var 任务状态:bool=false
@export var 存储数据:Dictionary={}
@export var 任务类型:String="主线"
##循环任务计时结束后刷新
@export var 时限: float = -1
##记录暂时时距离刷新剩余时间
@export var 剩余时间: float = -1
##初始化时传入
var 打包数据:任务打包资源
##初始化时获取当前任务数据,主线任务从任务字典读取,循环任务保存在资源内.
var 当前任务数据:Dictionary={}
var 前置条件:Array=[]
var 前置任务:Array=[]
var 奖励方法:Callable
var 奖励回传参数:bool=false
var 功能按钮:Array=[]
var 任务描述:Array=[]
var 循环任务:int=-1
var 进度描述:String=""
var 显示任务:String=""
var 消耗次数:bool=true
var 任务本地:Dictionary
var 奖励字典:Dictionary={}
##不同窗口的任务显示筛选依据,一个任务可以有多个来源
var 循环来源:Array[String]=[]
var 经验类奖励列表: Array = ["挂机","手工","木料","矿城","游历","职业","召唤"]
func _init(名称:String="",循环数据:Dictionary={}) -> void:
	if not 名称=="":
		任务名称=名称
	if not 循环数据=={}:
		存储数据=循环数据
		时限=Time.get_unix_time_from_system()+600+randi() % 600
func 初始化(打包:任务打包资源):
	打包数据=打包
	if not 存储数据.is_empty():
		当前任务数据=存储数据
	任务类型=当前任务数据.get("来源","循环")
	任务描述=当前任务数据.get("任务描述",[]) as Array
	进度描述=当前任务数据.get("进度描述","") as String
	显示任务=当前任务数据.get("显示任务","") as String
	功能按钮=当前任务数据.get("功能按钮",[]) as Array
	前置任务=当前任务数据.get("前置任务",[]) as Array
	前置条件=当前任务数据.get("前置条件",[]) as Array
	循环任务=当前任务数据.get("循环任务",-1) as int
	if not 任务完成 and 当前任务数据.has("奖励方法"):
		var 缓存奖励方法=当前任务数据["奖励方法"]
		if 缓存奖励方法 is Callable:
			奖励方法=缓存奖励方法
			奖励回传参数=false
		elif 缓存奖励方法 is Array and 缓存奖励方法.size()>=1 and 缓存奖励方法[0] is Callable:
			奖励方法=缓存奖励方法[0]
			奖励回传参数=true
		elif 缓存奖励方法 is Dictionary:
			奖励回传参数=false
			奖励字典=缓存奖励方法
			奖励方法=领取奖励字典
	if not 任务完成 and 当前任务数据.has("检查逻辑"):
		var 检查逻辑=当前任务数据.检查逻辑
		if 检查逻辑 is Callable:
			检查逻辑.call()
	if 任务类型=="成就":消耗次数=false
	else :消耗次数=true
func 领取奖励字典():
	for 奖励 in 奖励字典:
		if 经验类奖励列表.has(奖励):
			计划.快速熟练精通_系统升级(奖励,奖励字典[奖励])
		else :
			计划.获得物品语法糖(奖励,奖励字典[奖励])
			计划.语法糖通知("获得%s*%d"%[奖励,奖励字典[奖励]])
# 生成符合BBC语法的奖励展示文本（核心方法）
func 返回奖励文本() -> String:
	if 奖励字典.is_empty():#奖励字典是本地变量
		return ""
	# 存储每个奖励的文本片段
	var 奖励文本数组: Array = []
	# 遍历奖励字典，逐个构建文本片段
	for 奖励名称 in 奖励字典:
		var 奖励数量: int = 奖励字典[奖励名称]
		var 图片路径: String = ""
		if 奖励名称 in 经验类奖励列表:#处理图片路径：经验类奖励用"熟练"的贴图，其他用自身名称
			图片路径 = 计划.表格.道具贴图("熟练").resource_path
		else:
			图片路径 = 计划.表格.道具贴图(奖励名称).resource_path
		#构建BBC语法的文本片段（格式：[img]路径[/img]奖励名称*数量）
		var 单个奖励文本: String = "[img=40x40]%s[/img]%s*%d" % [图片路径, 奖励名称, 奖励数量]
		奖励文本数组.append(单个奖励文本)
	if 任务类型=="循环":
		var 奖励数量: int = 打包数据.循环任务难度
		var 奖励名称: String="任务点数"
		var 图片路径: String = 计划.表格.道具贴图("任务").resource_path
		var 单个奖励文本: String = "[img=40x40]%s[/img]%s*%d" % [图片路径, 奖励名称, 奖励数量]
		奖励文本数组.append(单个奖励文本)
	return " , ".join(奖励文本数组)
func 任务完成逻辑(回传参数=[]):
	if 任务完成:
		print("错误,%s任务领取奖励逻辑被重复执行"%任务名称)
		return
	任务完成=true
	if 奖励回传参数:
		奖励方法.call(回传参数)
	else :
		奖励方法.call()
	if 任务类型=="循环":
		打包数据.已完成循环任务+=+1
		计划.点数.增加点数("任务",打包数据.循环任务难度)
		刷新任务(0)
	else :
		打包数据.已完成任务.append(任务名称)
		计划.任务.任务全局更新(false)
	计划.保存存档("任务完成")
func 任务目标检查()->bool:
	return 未完成前置任务数组().size()==0
func 未完成前置任务数组()->Array:
	var 任务完成数组=打包数据.已完成任务
	var 未完成任务:Array=[]
	for 任务名 in 前置任务:
		if not 任务完成数组.has(任务名):
			未完成任务.append(任务名)
	return 未完成任务
func 刷新任务(体力:int=0):
	if 体力==0 or 计划.体力门票(体力):
		删除任务方法()
		计划.任务.生成循环任务()
		计划.更新_UI.emit()
func 删除任务方法():
	打包数据.进行中任务.erase(self)
	计划.任务.当前任务数据.erase(self)
	计划.任务.任务全局.erase(self)
	
func 显示检查()->bool:
	if 显示任务=="":return false
	if 计划.任务.唯一任务字典.has(显示任务):
		var 任务的数据:任务资源=计划.任务.唯一任务字典[显示任务]
		return not 任务的数据.任务完成
	print("错误,%s找不到<%s>任务"%[任务名称,显示任务])
	return true
## 核心暂停控制方法：传入布尔值控制暂停/恢复
func 设置暂停状态() -> void:
	if 任务状态:
		if not 时限==-1:
			var 当前时间戳 = Time.get_unix_time_from_system()
			剩余时间 = max(0.0, 时限 - 当前时间戳)
			时限 = -1
	else:
		if 剩余时间>0:
			时限 = Time.get_unix_time_from_system() + 剩余时间
			剩余时间 = -1
