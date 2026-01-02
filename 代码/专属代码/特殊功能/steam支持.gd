extends Node
class_name 梅steam

# 嵌套格式的成就字典：键=成就名称，值=子字典（包含标识、解锁状态）
var 成就字典 = {
	"完成任务": {
		"成就标识": "CJ0001",
		"解锁状态": false
	}
}
var 启用标示=ProjectSettings.get_setting("global/steam_enabled")#后续导出时另外实现切换
func _ready() -> void:
	if 启用标示:
		var 初始化状态 = Steam.steamInitEx(4181740, true)
		print("Steam初始化状态：", 初始化状态)
	else :
		print("单机逻辑")

func 读取成就存档(存档数据: Dictionary) -> void:
	for 成就名称 in 成就字典:
		var 成就=存档数据.get(成就名称,{})
		if 成就 is Dictionary:
			成就字典[成就名称]["解锁状态"]=成就.get("解锁状态",false)
		else :
			成就字典[成就名称]["解锁状态"]=false

# 根据【成就名称】获取Steam上的成就状态
func 检查成就(成就名称: String) -> bool:
	if not 成就字典.has(成就名称):
		print("错误：未找到【", 成就名称, "】对应的成就配置")
		return false
	var 成就标识 = 成就字典[成就名称]["成就标识"]
	if 启用标示:
		var 当前成就: Dictionary = Steam.getAchievement(成就标识)
		if 当前成就['ret']:
			成就字典[成就名称]["解锁状态"] = 当前成就['achieved']
		else:
			print("警告：获取【", 成就名称, "】失败，标识：", 成就标识)
			return false
	return 成就字典[成就名称]["解锁状态"]
		
# 根据【成就名称】解锁对应成就
func 解锁成就(成就名称: String) -> void:
	# 校验成就名称是否存在
	if not 成就字典.has(成就名称):
		print("错误：未找到【", 成就名称, "】对应的成就配置")
		return
	if 启用标示:
		# 提取成就标识和当前解锁状态
		var 成就标识 = 成就字典[成就名称]["成就标识"]
		# 仅当成就未解锁时执行解锁操作
		if not 检查成就(成就名称):
			# 调用Steam接口解锁成就
			var 解锁结果 = Steam.setAchievement(成就标识)
			if 解锁结果:
				成就字典[成就名称]["解锁状态"] = true
				Steam.storeStats()# 同步数据到Steam服务器
				计划.语法糖通知("【%s】解锁成功，已同步到Steam"%成就名称,"成就"+成就名称)
	else :
		成就字典[成就名称]["解锁状态"] = true
		计划.语法糖通知("完成成就%s"%成就名称,"成就"+成就名称)
func 清空单个成就(成就名称: String) -> void:
	if not 成就字典.has(成就名称):
		print("错误：未找到【", 成就名称, "】对应的成就配置")
		return
	if 启用标示:
		# 校验Steam连接状态
		if not Steam.isSteamRunning():
			print("警告：Steam未连接，无法清空成就")
			return
		var 成就标识 = 成就字典[成就名称]["成就标识"]
		# 调用Steam接口清空单个成就
		var 清空结果 = Steam.clearAchievement(成就标识)
		if 清空结果:
			Steam.storeStats()# 同步到Steam服务器
			成就字典[成就名称]["解锁状态"] = false
			print("【", 成就名称, "】成就进度已清空，同步完成")
		else:
			print("错误：清空【", 成就名称, "】失败（可能是成就未解锁/接口调用失败）")
	else :
		成就字典[成就名称]["解锁状态"] = false	

# ========== 新增：测试专用 - 清空所有成就 ==========
func 清空所有成就() -> void:
	for 成就名称 in 成就字典:
		成就字典[成就名称]["解锁状态"] = false
	if 启用标示:# 调用Steam接口重置所有成就（true=包含成就，false=仅统计数据）
		if not Steam.isSteamRunning():# 校验Steam连接状态
			print("警告：Steam未连接，无法清空成就")
			return
		var 清空结果 = Steam.resetAllStats(true)
		if 清空结果:
			# 同步到Steam服务器
			Steam.storeStats()
			# 批量更新本地成就字典
			print("所有成就进度已清空，本地字典同步完成")
		else:
			print("错误：清空所有成就失败（可能是无成就可清空/接口权限不足）")
