extends Resource
class_name 任务资源
@export var 任务名称:String=""
##完成的任务不会存储,而是加载时重新生成
@export var 任务完成:bool=false
##未推进的任务不会被储存
@export var 任务数据:Array=[]
@export var 任务状态:bool=false
@export var 存储数据:Dictionary={}
@export var 任务类型:String="主线"
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
var 消耗次数:bool=true
var 任务本地:Dictionary
##不同窗口的任务显示筛选依据,一个任务可以有多个来源
var 循环来源:Array[String]=[]
func _init(名称:String="",循环数据:Dictionary={}) -> void:
	if not 名称=="":
		任务名称=名称
	if not 循环数据=={}:
		存储数据=循环数据
func 初始化(打包:任务打包资源):
	打包数据=打包
	if not 存储数据.is_empty():
		当前任务数据=存储数据
	任务类型=当前任务数据.get("来源","循环")
	任务描述=当前任务数据.get("任务描述",[]) as Array
	进度描述=当前任务数据.get("进度描述","") as String
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
			奖励方法=领取奖励字典.bind(缓存奖励方法)
	if not 任务完成 and 当前任务数据.has("检查逻辑"):
		var 检查逻辑=当前任务数据.检查逻辑
		if 检查逻辑 is Callable:
			检查逻辑.call()
	if 任务类型=="成就":消耗次数=false
	else :消耗次数=true
func 领取奖励字典(奖励字典:Dictionary):
	for 奖励 in 奖励字典:
		if ["挂机","手工","木料","矿城","游历","职业","召唤"].has(奖励):
			计划.快速熟练精通_系统升级(奖励,奖励字典[奖励])
		else :
			计划.获得物品语法糖(奖励,奖励字典[奖励])
			计划.语法糖通知("获得%s*%d"%[奖励,奖励字典[奖励]])
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
		打包数据.进行中任务.erase(self)
		计划.任务.当前任务数据.erase(self)
		计划.任务.任务全局.erase(self)
		计划.任务.生成循环任务()
		计划.任务.任务全局更新(false)
