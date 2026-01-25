extends Resource
class_name 梅队列数据
var 子类型:Array=[梅炼金数据,梅烹饪数据]
var 队列版本号:int=1
@export var 版本号:int=1
@export var 创建版本号:int=1
@export var 创建游戏版本号:String=""
#作为队列加入时会复制资源
@export var 队列中:bool=false
@export var 队列时间戳:float=-1
@export var 队列数量:int=0
@export var 队列完成:int=0
func _init(创建参数=null) -> void:
	if not 创建参数==null:
		创建游戏版本号=ProjectSettings.get_setting("application/config/version", "")
		创建版本号=队列版本号
		版本号=队列版本号
		队列配置(0)
		
func 检查队列完成():
	var 当前时间:float = Time.get_unix_time_from_system()
	if 队列中 and 队列数量>=1:
		var 队列耗时:float=耗时计算方法()
		if 队列耗时<=0:
			return
		var 时间差:float = 当前时间 - 队列时间戳
		var 可完成次数:int = min(int(时间差*1.0 / 队列耗时), 队列数量)# 计算可完成的次数
		队列数量-=可完成次数
		队列完成+=可完成次数
		队列时间戳+=可完成次数 * 队列耗时
func 队列配置(执行次数:int=0):
	if 执行次数>=1:
		队列中=true
		队列时间戳=Time.get_unix_time_from_system()
		队列数量=执行次数
		队列完成=0
	else :
		队列中=false
		队列时间戳=-1
		队列数量=0
		队列完成=0
func 耗时计算方法():
	return 0
func 领取奖励():
	print("必须重写")
	breakpoint#断点
func 放弃任务():
	print("必须重写")
	breakpoint#断点
func 是否可放弃任务()->bool:
	return false
