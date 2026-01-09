extends Node
class_name steam插件
func 初始化():
	var 初始化状态 = Steam.steamInitEx(4181740, true)
	print("Steam初始化状态：", 初始化状态)
func 当前成就(成就标识):
	return Steam.getAchievement(成就标识)
func 完成成就(成就标识):
	Steam.setAchievement(成就标识)
	Steam.storeStats()
func 连接检查()->bool:
	return Steam.isSteamRunning()
func 清空成就(成就标识):
	return Steam.clearAchievement(成就标识)
func 同步服务器():
	Steam.storeStats()# 同步到Steam服务器
func 清空所有成就():
	Steam.resetAllStats(true)
