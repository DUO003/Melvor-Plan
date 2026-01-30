extends Node#废弃合并到物品内
#class_name 梅物品
# 物品使用处理字典（键：物品名称，值：匿名方法）
# 匿名方法返回值：>=0 表示使用成功（返回值为消耗数量，0则不扣除）；-1 表示使用失败
var 物品使用映射 = {
	"标准示例":(func(物品):# 示例：使用1个治疗药水（成功，消耗1个）
		if 物品.数量 >= 1:
			print("使用治疗药水，恢复生命值")
			return 1  # 消耗1个
		else:
			print("治疗药水数量不足，无法使用")
		return -1),  # 失败
	"礼盒":(func(物品,字典):
		if 物品.数量 >= 1:
			var 礼盒=字典["礼盒"]
			for 内容 in 礼盒:
				抽取奖励(内容)
			return 1
		return -1),  # 失败
	}
func 抽取奖励(内容):
	var 筛选数组=[]
	var 通知奖励=[]
	if 内容[0] is Array:
		print("获得标签")
	else :
		筛选数组=[内容[0]]
	if 筛选数组.size()>=0:
		var 抽取次数=int(内容[1])
		var 最低=int(内容[2])
		var 最高=int(内容[3])
		var 步进=int(内容[4])
		for x in 抽取次数:
			var 物品名称=筛选数组[randi()%筛选数组.size()]
			通知奖励+=[计划.语法糖获得物品(物品名称,随机数量(最低,最高,步进))]
	if 计划.节点有效性检查("奖励悬浮面板"):
		计划.节点["奖励悬浮面板"].物品数组+=通知奖励
func 随机数量(最低: int, 最高: int, 步进: int) -> int:
	var 最大倍数 = floori((最高 - 最低)*1.0 / 步进)
	var 随机倍数 = randi() % (最大倍数 + 1)
	return clampi(最低 + 随机倍数 * 步进, 最低, 最高)
# 中间函数：处理物品使用流程
func 使用物品(物品) -> String:
	if not 物品 is 标准物品:# 步骤1：检查物品类型是否为"标准物品"
		print("错误：物品[", 物品.item_name, "]不是标准物品，无法使用")
		return "类型错误"
	var 类型物品:标准物品=物品
	var 表格字典:Dictionary=计划.表格.获取表格字典(计划.表格.创世蓝图,-1,类型物品.item_name)
	if not "属性" in 表格字典:
		return "属性错误"
	var 属性=表格字典["属性"]
	var 字典={}
	var json = JSON.new()
	var 解析 = json.parse(属性)
	if 解析 == OK:
		字典 = json.data
	else :
		return "JS错误"
	if not "使用" in 字典 or 字典["使用"] not in 物品使用映射:# 步骤2：检查字典中是否有对应处理方法
		return "方法错误"
	var 使用数量 = 物品使用映射[字典["使用"]].call(类型物品,字典)# 步骤3：执行对应使用方法，获取使用数量
	if 使用数量 == -1:
		return "条件错误"
	else:
		if 使用数量 > 0:# 使用成功，根据返回值扣除数量（使用数量 >=0）
			类型物品.数量-=使用数量
			pass
		return "成功"
