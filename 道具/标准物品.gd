extends StackableData
class_name 标准物品

## 梅尔沃计划定义属性,决定部分抽取道具的随机池
@export var 标签: Array = ["物品"]
## 梅尔沃计划定义属性,决定鼠标指向物品的提示
@export var 简介: String = "暂无简介"
## 梅尔沃计划定义属性,决定道具商店直接出售价格,回收价格需要参考表格.
@export var 价值: int = 0
## 梅尔沃计划定义属性,决定道具商店内保存数量购买时可能不止一个但只计数-1,为0时删除-1为无限.
@export var 商店剩余数量: int = 0
##锁定的物品不会被计算剩余数量和使用.也不能被拿起.合并.
@export var 锁定: bool = false
##假设消耗为0后是否从背包移除,本属性不使用
var 是否销毁=true
##已字典形式保存方法,可以被物品的 属性["使用"]访问解析
var 物品使用映射 = {
	"标准示例":(func(_字典):# 示例：使用1个治疗药水（成功，消耗1个）
		if self.current_amount >= 1:
			print("使用治疗药水，恢复生命值")
			return 1  # 消耗1个
		else:
			print("治疗药水数量不足，无法使用")
		return -1),  # 失败
	"礼盒":(func(字典):
		if self.current_amount >= 1:
			if 初始化.节点有效性检查("空节点"):
				初始化.节点["空节点"].便利摄像机效果()
			var 挂机数据: Dictionary=初始化.梅存档["挂机"]
			var 开启次数=挂机数据.get("开启次数",0)
			if 开启次数<5:
				var 在线时间=挂机数据.get("在线时间",{}).get("今日累计",0)
				if not 在线时间 >(开启次数+1)*360:
					引擎.屏幕.滚动提示("今天已开启次数:"+str(开启次数)+"/5","物品使用")
					引擎.屏幕.滚动提示("下次开启需要:"+str((开启次数+1)*360-在线时间)+"秒")
					return 0
				var 礼盒=字典["礼盒"]
				for 内容 in 礼盒:
					抽取奖励(内容)
				引擎.屏幕.滚动提示("今天已开启次数:"+str(开启次数)+"/5","物品使用")
				初始化.梅存档["挂机"]["开启次数"]=开启次数+1
				return 1
			else :
				引擎.屏幕.滚动提示("今天使用已超过上限","物品使用")
			return 0
		return -1),  # 失败
	"资源":(func(_字典):
		if self.current_amount >= 1:
			初始化.获得资源(self.item_name,self.current_amount,false)
			return self.current_amount
		else:
			print("不足，无法使用")
		return -1),  # 失败
	"金币":(func(_字典):
		if self.current_amount >= 1:
			初始化.梅存档["金币"]+=self.current_amount
			return self.current_amount
		else:
			print("不足，无法使用")
		return -1),  # 失败
	}
## 物品被使用时调用,自行处理销毁逻辑与变量外观
func 使用物品(背包) -> String:# 中间函数：处理物品使用流程
	var 表格字典:Dictionary=梅表格.获取表格字典(梅表格.装备蓝图,-1,self.item_name)
	if not "属性" in 表格字典:
		return "属性错误"
	var 属性=表格字典["属性"]#来自最新版本的信息
	var 字典={}
	var json = JSON.new()
	var 解析 = json.parse(属性)
	if 解析 == OK:
		字典 = json.data
	else :
		return "JS错误"
	if not "使用" in 字典 or 字典["使用"] not in 物品使用映射:# 步骤2：检查字典中是否有对应处理方法
		return "方法错误"
	var 使用数量 = 物品使用映射[字典["使用"]].call(字典)# 步骤3：执行对应使用方法，获取使用数量
	if 使用数量 == -1:
		return "条件错误"
	else:
		if 使用数量 > 0:# 使用成功，根据返回值扣除数量（使用数量 >=0）
			self.current_amount-=使用数量
			if self.current_amount<=0:
				GBIS.inventory_service.remove_item_by_data(背包, self)
		初始化.emit_signal("更新_UI")
		初始化.保存存档("使用背包内道具")
		return "成功"
func 物品点击(背包) -> bool:#物品被点击时调用,返回不销毁
	初始化.emit_signal("更新_背包物品信息", self,背包)
	return false
## 消耗方法，需重写，返回消耗数量（>=0）
func 获取消耗量() -> int:
	push_warning("[Override this function] consumable item [%s] has been consumed" % item_name)
	print("消耗测试:",item_name)
	return 1
func 抽取奖励(内容):
	var 筛选数组=[]
	var 通知奖励=[]
	if 内容[0] is Array:
		筛选数组=初始化.语法糖获取标签组(内容[0])
	else :
		筛选数组=[内容[0]]
	if 筛选数组.size()>=1:
		var 抽取次数=int(内容[1])
		var 最低=int(内容[2])
		var 最高=int(内容[3])
		var 步进=int(内容[4])
		for x in 抽取次数:
			var 物品名称=筛选数组[randi()% 筛选数组.size()]
			通知奖励+=[初始化.语法糖获得物品(物品名称,随机数量(最低,最高,步进))]
	if 初始化.节点有效性检查("奖励悬浮面板"):
		var 节点:奖励悬浮面板=初始化.节点["奖励悬浮面板"]
		节点.语法糖传入数组(通知奖励)
func 随机数量(最低: int, 最高: int, 步进: int) -> int:
	var 最大倍数 = floori((最高 - 最低)*1.0 / 步进)
	var 随机倍数 = randi() % (最大倍数 + 1)
	return clampi(最低 + 随机倍数 * 步进, 最低, 最高)
