extends Label
var 零点时间戳:int=计划.获取零点时间戳()
func _ready() -> void:
	#print("计时:",计划.格式化时间(int(零点时间戳-Time.get_unix_time_from_system()),2))
	计划.过去一秒.connect(更新时间)
	更新时间()
func 更新时间():
	var 在线数据:Dictionary=计划.梅存档["挂机"]["在线时间"]
	var 礼包次数:int=int(在线数据.get("开启次数",0))
	var 在线时间:int=int(在线数据.get("今日累计",0))
	var 零点秒数:int=int(零点时间戳-Time.get_unix_time_from_system())
	text="今天重制倒计时:%s\r礼包开启次数%d/%d\r已在线时间:%s"%[
		计划.格式化时间(零点秒数,2),礼包次数,5,计划.格式化时间(在线时间)]
