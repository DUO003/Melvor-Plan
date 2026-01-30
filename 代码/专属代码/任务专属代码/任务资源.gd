extends Resource
class_name 任务资源
@export var 任务类型:String="主线"
@export var 任务名称:String=""
@export var 任务完成:bool=false
@export var 任务数据:Array=[]
@export var 任务状态:bool=false
@export var 任务目标:Dictionary={}
func _init(名称:String="",类型:String="") -> void:
	if not 名称=="":
		任务名称=名称
		任务类型=类型
func 任务完成清理():
	if 任务类型=="循环":
		pass
	else :
		任务数据=[]
		任务状态=false
func 任务完成逻辑(附加值=[]):
	任务完成=true
	if 计划.任务.任务字典.has(任务名称) and 计划.任务.任务字典[任务名称].has("奖励方法"):
		var 任务奖励=计划.任务.任务字典[任务名称]["奖励方法"]
		var 任务奖励方法:Callable=任务奖励 if 任务奖励 is Callable else 任务奖励[0]
		var 方法参数:int=0 if 任务奖励 is Callable else 任务奖励[1]#这是提前定义的参数数量,只适配了一个文本参数的情况
		if 附加值 is String and 方法参数==1:任务奖励方法.call(附加值)
		elif 方法参数==0:任务奖励方法.call()  # 执行匿名方法
		else :breakpoint#错误
	else :计划.语法糖通知("任务已完成但没有定义的奖励")
func 任务目标检查()->bool:
	return false
