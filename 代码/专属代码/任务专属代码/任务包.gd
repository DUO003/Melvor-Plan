extends Resource
class_name 任务打包资源
##包含循环任务.
@export var 进行中任务:Array[任务资源]=[]
##仅储存名称
@export var 已完成任务:Array[String]=[]
##仅储存类型+任务积分
@export var 已完成循环任务:Dictionary[String,int]={}
