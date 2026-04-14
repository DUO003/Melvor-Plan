extends StackableData
class_name 标准物品
var 物品类型目录:Array=[物品方块,物品装备,物品宝石]
## 梅尔沃计划定义属性,决定部分抽取道具的随机池
var 标签: PackedStringArray = []
## 显示的名称
var 显示名称:String:
	get:
		翻译更新检查()
		return 显示名称
## 梅尔沃计划定义属性,决定鼠标指向物品的提示
var 简介: String = "暂无简介":
	get:
		翻译更新检查()
		return 显示名称
var 当前语言:String="未赋值"
## 梅尔沃计划定义属性,决定道具商店直接出售价格,回收价格需要参考表格.
@export var 价值: int = 0
## 梅尔沃计划定义属性,决定道具商店内保存数量购买时可能不止一个但只计数-1,为0时删除-1为无限.
@export var 商店剩余数量: int = 0
##锁定的物品不会被计算剩余数量和使用.也不能被拿起.合并.
@export var 锁定: bool = false
##用于烹饪等玩法,标签不会保存,默认值为空
var 特殊标签:String=""

var 阶级:int=1
##假设消耗为0后是否从背包移除,本属性不使用
var 是否销毁=true
##已字典形式保存方法,可以被物品的 属性["使用"]访问解析
var 物品使用映射:Dictionary = {
	"标准示例":(func(_字典):# 示例：使用1个治疗药水（成功，消耗1个）
		if self.数量 >= 1:
			print("使用治疗药水，恢复生命值")
			return 1  # 消耗1个
		else:
			print("治疗药水数量不足，无法使用")
		return -1),  # 失败
	"礼盒":(func(字典):
		if self.数量 >= 1:
			if 计划.节点有效性检查("主容器窗口"):
				计划.节点["主容器窗口"].便利摄像机效果()
			var 在线数据: Dictionary=计划.梅存档["挂机"]["在线时间"]
			var 礼包次数=在线数据.get("开启次数",0)
			if 礼包次数<5:
				var 在线时间=在线数据.get("今日累计",0)
				if not 在线时间 >(礼包次数+1)*3.60:
					计划.语法糖通知("今天已开启次数:"+str(礼包次数)+"/5","物品使用")
					计划.语法糖通知("下次开启需要:"+str((礼包次数+1)*360-在线时间)+"秒")
					return 0
				var 礼盒=字典["礼盒"]
				var 通知奖励=[]
				var 礼盒类型=字典.get("礼盒类型","挂机")
				var 礼盒阶级=ceili(max(1,计划.数据系统(礼盒类型)) / 10.0)
				#print(礼盒类型,阶级)
				for 内容 in 礼盒:
					通知奖励+=抽取奖励(内容,礼盒阶级)
				计划.语法糖奖励显示(通知奖励,"礼包",1)
				计划.语法糖通知("今天已开启次数:"+str(礼包次数+1)+"/5","物品使用")
				在线数据["开启次数"]=礼包次数+1
				return 1
			else :
				计划.语法糖通知("今天使用已超过上限","物品使用")
			return 0
		return -1),  # 失败
	"资源":(func(_字典):
		if self.数量 >= 1:
			计划.手工.获得资源(self.item_name,self.数量,false)
			return self.数量
		else:
			print("不足，无法使用")
		return -1),  # 失败
	"金币":(func(_字典):
		if self.数量 >= 1:
			计划.梅存档["金币"]+=self.数量
			return self.数量
		else:
			print("不足，无法使用")
		return -1),  # 失败
	"体力":(func(_字典):
		if self.数量 >= 1:
			var 获得量=计划.获得体力(self.数量,true)
			return 获得量
		else:
			print("不足，无法使用")
		return -1),  # 失败,  # 失败
	"药水":(func(_字典):
		if not 计划.BUFF.BUFF配置字典.has(self.item_name):return -1#没有药水的BUFF状态
		if self.数量 >= 1:
			if 计划.BUFF.创建BUFF(self.item_name,"使用药水",1.0):
				计划.语法糖通知(self.item_name+"使用成功")
				return 1
			return 0#BUFF层数已满或受到其他限制
		else:
			print("不足，无法使用")
		return -1),  # 失败
	"精通代币":(func(字典):
		if self.数量 >= 1:
			if not 字典.has("系统"):return -1#如果没有系统键
			var 系统=字典["系统"]
			if not 计划.梅存档[系统].has("精通"):
				计划.梅存档[系统]["精通"]=0
			var 精通值=计划.数据精通上限(系统)*0.01
			计划.梅存档["手工"]["精通"]+=精通值
			计划.更新_UI.emit()
			计划.语法糖通知(self.item_name+"使用成功")
			return 1
		else:
			print("不足，无法使用")
		return -1),  # 失败
	}

func 更新属性():
	if super.更新属性():
		标签=计划.表格.缓存蓝图标签[item_name]
		阶级=int(表格数据[蓝图表头["阶级"]])
		当前语言=计划.表格.当前使用语言
		显示名称=计划.表格.翻译名称(item_name)
		简介=计划.表格.翻译简介(item_name)
		更新堆叠()
func 拷贝方法():#所有继承方法如果希望被正确拷贝都需要重写
	return 标准物品.new(1,item_name)
## 物品被使用时调用,自行处理销毁逻辑与变量外观
func 使用物品(背包) -> String:# 中间函数：处理物品使用流程
	print("尝试使用物品",self.item_name)
	var 表格字典:Dictionary=计划.表格.获取表格字典(计划.表格.创世蓝图,-1,self.item_name)
	if not "属性" in 表格字典:
		print("属性错误")
		return "属性错误"
	var 字典:Dictionary=计划.表格.获取属性(self.item_name,null,{})
	if not "使用" in 字典 or not 字典["使用"] in 物品使用映射:# 步骤2：检查字典中是否有对应处理方法
		计划.语法糖通知("该物品没有使用方法","物品使用")
		return "缺少方法"
	print("使用成功")
	var 使用数量 = 物品使用映射[字典["使用"]].call(字典)# 步骤3：执行对应使用方法，获取使用数量
	if 使用数量 == -1:
		print("条件错误")
		return "条件错误"
	else:
		if 使用数量 > 0:# 使用成功，根据返回值扣除数量（使用数量 >=0）
			self.数量-=使用数量
			if self.数量<=0:
				GBIS.inventory_service.remove_item_by_data(背包, self)
		计划.更新_UI.emit()
		GBIS.sig_inv_refresh.emit()
		计划.保存存档("使用背包内道具")
		return "成功"

## 消耗方法，需重写，返回消耗数量（>=0）
func 获取消耗量() -> int:
	push_warning("[Override this function] consumable item [%s] has been consumed" % item_name)
	print("消耗测试:",item_name)
	return 1
func 抽取奖励(内容,阶段):
	var 筛选数组=[]
	var 通知奖励=[]
	if 内容[0] is Array:
		筛选数组=计划.语法糖获取标签组(内容[0],int(阶段))
	else :
		筛选数组=[内容[0]]
	if 筛选数组.size()>=1:
		var 抽取次数=int(内容[1])
		var 最低=int(内容[2])
		var 最高=int(内容[3])
		var 步进=int(内容[4])
		for x in 抽取次数:
			var 物品名称=筛选数组[randi()% 筛选数组.size()]
			通知奖励+=[计划.语法糖获得物品(物品名称,随机数量(最低,最高,步进))]
		#print("抽奖结果",筛选数组,内容,阶段)
	else :
		print("错误:抽奖结果为空",内容,阶段)
	return 通知奖励
	
func 随机数量(最低: int, 最高: int, 步进: int) -> int:
	var 最大倍数 = floori((最高 - 最低)*1.0 / 步进)
	var 随机倍数 = randi() % (最大倍数 + 1)
	return clampi(最低 + 随机倍数 * 步进, 最低, 最高)
func 文本预处理()->String:
	return item_name+"\n数量:"+str(数量)+"\n堆叠上限:"+科学计数(堆叠上限)+"\n"+简介
func 科学计数(数值, 小数位数: int = 2,免转换范围:int=10000) -> String:
	return 计划.科学计数(数值,小数位数,免转换范围)
func 返回简介(背包名:String,参数:Dictionary={})->String:
	var 简介文本:String=super.返回简介(背包名,参数)
	if GBIS.shop_names.has(背包名):
		简介文本+="\n每次购买数量:"+str(数量)
		简介文本+="\n购买费用:"+str(价值)
		简介文本+="\n单价:%.0f"%(价值*1.0/数量)
		简介文本+="\n剩余购买次数:"+str(商店剩余数量)
	else :
		简介文本+="(阶级:%s)\n标签:<%s>\n简介:%s"%[计划.罗马数字(阶级),",".join(标签),简介]
	return 简介文本
func 更新堆叠():
	var 基础堆叠=计划.表格.蓝图数据(item_name,"堆叠")
	var 额外堆叠=计划.表格.获取额外堆叠上限(item_name)
	堆叠上限=基础堆叠+额外堆叠
func 翻译更新检查():
	if not 当前语言==计划.表格.当前使用语言:
		更新属性()
	return
