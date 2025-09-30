extends Node
class_name 引擎时间


"""
预存一个2024年1月1号0点0分的时间戳
"""
const 时间戳:=1704038400 #储存了一个2024年1月1号的0点0分的时间戳
func 获取预设的时间戳():
	return 时间戳
	
func 获取预设到现在所经历的秒数():
		return 取当前时间戳()-获取预设的时间戳()
	
func 获取到现在所经历的天数():
	return int(floor(获取预设到现在所经历的秒数()/86400))#604800#2592000
	
# 取下次签到的本地日期时间字符串（格式：YYYY-MM-DDThh:mm:ss）
func 获取下一次签到的时间字符串():
	# 计算从预设时间到现在的总秒数
	var 经历的秒数 = 获取预设到现在所经历的秒数()
	# 向上取整到完整天数（1天=86400秒）
	var 完整天数 = ceil(经历的秒数 / 86400)
	# 计算下次签到的时间戳（预设时间 + 完整天数×86400秒）
	var 下次签到时间戳 = 获取预设的时间戳() + 完整天数 * 86400
	# 转换为本地时区的日期时间字符串
	return 从时间戳取本地日期时间字符串(下次签到时间戳)
	
## 取当前电脑的时间戳,10位数,秒,浮点数
func 取当前时间戳():
	return Time.get_unix_time_from_system()

# 获取时区偏移量（分钟，UTC+8返回480）
func 取时区偏移量() -> int:
	return Time.get_time_zone_from_system().bias	
# 获取当前系统日期字符串（格式：YYYY-MM-DD）
func 取当前日期字符串() -> String:
	return Time.get_date_string_from_system()
# 获取当前系统日期时间字符串（格式：YYYY-MM-DDThh:mm:ss）
func 取当前日期时间字符串() -> String:
	return Time.get_datetime_string_from_system()

# 从时间戳转换为本地时区的日期时间字符串
func 从时间戳取本地日期时间字符串(时间戳: float) -> String:
	var 偏移量_秒 = 取时区偏移量() * 60  # 转换为秒
	return Time.get_datetime_string_from_unix_time(时间戳 + 偏移量_秒)
