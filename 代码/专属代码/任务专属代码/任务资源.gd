extends Resource
class_name 任务资源
@export var 任务名称:String=""
##完成的任务不会存储,而是加载时重新生成
@export var 任务完成:bool=false
##未推进的任务不会被储存
@export var 任务数据:Array=[]
@export var 任务状态:bool=false
@export var 循环任务数据:Dictionary={}
##初始化时传入
var 打包数据:任务打包资源
##初始化时获取当前任务数据,主线任务从任务字典读取,循环任务保存在资源内.
var 当前任务数据:Dictionary={}
var 任务类型:String="主线"
var 前置条件:Array=[]
var 前置任务:Array=[]
var 奖励方法:Callable
var 奖励回传参数:bool=false
var 功能按钮:Array=[]
var 任务描述:Array=[]
var 进度描述:String=""
var 任务本地:Dictionary
func _init(名称:String="",循环数据:Dictionary={}) -> void:
	if not 名称=="":
		任务名称=名称
	if not 循环数据=={}:
		循环任务数据=循环数据
func 初始化(数据:Dictionary,打包:任务打包资源):
	打包数据=打包
	if 数据.is_empty():
		当前任务数据=循环任务数据
		任务类型="循环"
	else :
		当前任务数据=数据
		任务类型=当前任务数据.get("来源","循环")
	任务描述=当前任务数据.get("任务描述",[]) as Array
	进度描述=当前任务数据.get("进度描述","") as String
	功能按钮=当前任务数据.get("功能按钮",[]) as Array
	前置任务=当前任务数据.get("前置任务",[]) as Array
	前置条件=当前任务数据.get("前置条件",[]) as Array
	if not 任务完成 and 当前任务数据.has("奖励方法"):
		var 缓存奖励方法=当前任务数据["奖励方法"]
		if 缓存奖励方法 is Callable:
			奖励方法=缓存奖励方法
			奖励回传参数=false
		elif 缓存奖励方法 is Array and 缓存奖励方法.size()>=1 and 缓存奖励方法[0] is Callable:
			奖励方法=缓存奖励方法[0]
			奖励回传参数=true
	if not 任务完成 and 当前任务数据.has("检查逻辑"):
		var 检查逻辑=当前任务数据.检查逻辑
		if 检查逻辑 is Callable:
			检查逻辑.call()
func 任务完成清理():
	if 任务类型=="循环":
		pass
func 任务完成逻辑(回传参数=[]):
	if not 任务完成:
		任务完成=true
		if 奖励回传参数:
			奖励方法.call(回传参数)
		else :
			奖励方法.call()
func 任务目标检查()->bool:
	return 未完成前置任务数组().size()==0
func 未完成前置任务数组()->Array:
	
	var 任务完成数组=打包数据.已完成任务
	var 未完成任务:Array=[]
	for 任务名 in 前置任务:
		if not 任务完成数组.has(任务名):
			未完成任务.append(任务名)
	return 未完成任务
