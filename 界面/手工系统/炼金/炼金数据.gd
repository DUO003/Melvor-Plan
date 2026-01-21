extends 梅队列数据
class_name 梅炼金数据
var 炼金版本号:int=1
@export var 配方字典:Dictionary
@export var 药水序列:Array=[]
@export var 药水数量:Array=[]
@export var 药水成功:Array=[]
@export var 炼金点数:Array=[]
@export var 炼金数量:int=0
@export var 属性总值:int=0
var 权重数据:Dictionary
##每次游戏仅更新一次
var 耗时:float=-1:
	get:
		if 耗时==-1:
			if 催化剂=="":return 0
			var 阶级=计划.表格.蓝图数据(催化剂,"阶级")
			耗时=100+阶级*10
		return 耗时*0.05
func 耗时计算方法():
	return 耗时
var 催化剂:String:
	get:
		if 配方字典.has("催化剂"):return 配方字典["催化剂"]
		return ""
##从1计数,最大4
func 返回材料(序号:int)->Dictionary:
	var 材料数据:Dictionary={"名称":null,"数量":0}
	if 配方字典 and 配方字典.has_all(["材料名称","材料数量"]) and 配方字典["材料名称"].size()==配方字典["材料数量"].size():
		if 序号>0 and 序号<=4 and 序号<=配方字典["材料名称"].size():
			材料数据.名称=配方字典["材料名称"][序号-1]
			材料数据.数量=配方字典["材料数量"][序号-1]
	return 材料数据
func _init(创建参数=null) -> void:
	super._init(创建参数)
	var 配方=创建参数
	if 配方 is Dictionary:
		配方字典=配方
##配方首次读取时进行
func 检查配方更新()->bool:
	var 药水长度:int=药水序列.size()
	if 药水长度>=1:
		var 检查失败:bool=false
		if 药水数量.size()!=药水长度:检查失败=true
		if 药水成功.size()!=药水长度:检查失败=true
		if 炼金点数.size()!=药水长度:检查失败=true
		if 检查失败:
			if 配方格式检查():
				print("发现配方错误,尝试修复配方")
				更新药水数量()
				return true
			else :
				print("发现配方错误,无法修复")
				return false
		return true
	if 计算配方():
		print("发现配方为空,修复成功")
		return true
	print("配方错误,修复失败")
	return false
func 领取奖励():
	if not 队列中:#资源只有在检查通过后才会标记队列中
		print("错误,不再队列中")
		放弃任务()
		return
	if 队列完成<1:
		计划.语法糖通知("暂无奖励","炼金提示")
		return
	var 药水长度:int=药水序列.size()
	var 统计奖励:Array=[]
	var 催化精通=耗时*队列完成
	if 队列完成>=药水长度:
		var 完成数量:int=int(队列完成/float(药水长度))
		for i in 完成数量:
			统计奖励.append(领取单次(完成数量,药水长度))
		队列完成-=药水长度*完成数量
	if 队列完成>=1:
		for i in 队列完成:
			统计奖励.append(领取单次(1,药水长度))
		队列完成=0
	if 队列数量==0 and 队列完成==0:
		队列配置(0)
		计划.手工.队列炼金(self,0)
	计划.手工.数据炼金催化剂(催化剂,"精通",催化精通)
	计划.语法糖通知("%s催化剂精通+%d"%[催化剂,催化精通],"催化剂精通")
	计划.语法糖奖励显示(统计奖励,"获得药水",1)
	计划.更新_UI.emit()
	计划.保存存档("领取炼金奖励")
	计划.steam.解锁成就("初试炼金")
func 扣除材料(数量)->bool:
	if 材料数量检查(数量):
		扣除炼金材料(数量)
		return true
	return false
func 是否可放弃任务()->bool:
	return true
func 放弃任务():
	if 队列数量>=1:
		扣除炼金材料(int(min(0,1-队列数量)))
	计划.手工.队列炼金(self,0)
func 材料数量检查(数量:int=1)->bool:
	for i in 配方字典["材料名称"].size():
		var 物品名称=配方字典["材料名称"][i]
		var 背包内数量=计划.检查背包物品数量(物品名称)
		var 需求数量=配方字典["材料数量"][i]*数量
		if 需求数量>背包内数量:
			计划.语法糖通知("材料:"+物品名称+"数量不足","炼金窗口")
			return false#数量不足
	if 数量>计划.检查背包物品数量(配方字典["催化剂"]):
		计划.语法糖通知("催化剂:"+配方字典["催化剂"]+"数量不足","炼金窗口")
		return false#数量不足
	return true
func 扣除炼金材料(数量:int=1):
	if 数量 == 0:
		return# 数量为0时直接返回，不执行任何操作
	for i in range(配方字典["材料名称"].size()):
		var 物品名称 = 配方字典["材料名称"][i]
		var 变动数量 = 配方字典["材料数量"][i] * 数量
		if 变动数量 > 0:# 正数调用消耗，负数取绝对值调用获得
			计划.语法糖消耗物品(物品名称, 变动数量)
		elif 变动数量 < 0:
			计划.语法糖获得物品(物品名称, -变动数量)
	var 催化剂名称 = 配方字典["催化剂"]# 2. 处理催化剂（正数扣除，负数获得）
	if 数量 > 0:
		计划.语法糖消耗物品(催化剂名称, 数量)
	elif 数量 < 0:
		计划.语法糖获得物品(催化剂名称, -数量)
##如果药水数量为0替换显示为贤者点数
func 领取单次(完成数量:int,药水长度:int=药水序列.size()):
	var 数量=查询药水(炼金数量,"数量",药水长度)*完成数量
	var 名称=查询药水(炼金数量,"名称",药水长度)
	炼金数量+=1
	return 计划.语法糖获得物品(名称,数量,"点数" if 名称=="贤者点数" else "标准物品")
func 查询药水(序号:int,返回:String="名称",药水长度:int=药水序列.size()):
	var 序列号=序号%药水长度
	if 药水成功[序列号]:
		match 返回:
			"数量":return 药水数量[序列号]
			"名称":return 药水序列[序列号]
	else :
		match 返回:
			"数量":
				var 炼金力:float=计划.装备.炼金力
				var 数量:float=炼金点数[序列号]
				if 数量>炼金力:
					var 差值:float=数量-炼金力
					数量=(差值**0.75)+炼金力
				return int(数量)
			"名称":return "贤者点数"
func 版本更新():
	if 版本号<炼金版本号:
		pass
func 配方格式检查(生成通知:bool=false)->bool:
	if not ("材料名称" in 配方字典 and "材料数量" in 配方字典 and "催化剂" in 配方字典):# 1. 检查字典必备键是否存在
		if 生成通知:计划.语法糖通知("添加失败:配方损坏","炼金窗口")
		return false # 字典格式错误
	var 材料名称类型合法 = 配方字典["材料名称"] is Array
	var 材料数量类型合法 = 配方字典["材料数量"] is Array
	var 催化剂类型合法 = 配方字典["催化剂"] is String and 配方字典["催化剂"] != ""
	if not (材料名称类型合法 and 材料数量类型合法 and 催化剂类型合法):# 2. 检查各字段数据类型
		if 生成通知:
			if not 催化剂类型合法:计划.语法糖通知("添加失败:缺少催化剂","炼金窗口")
			else:计划.语法糖通知("添加失败:配方损坏","炼金窗口")
		return false # 数据类型错误
	var 数组长度匹配 = 配方字典["材料名称"].size() == 配方字典["材料数量"].size()
	var 材料数量达标 = 配方字典["材料名称"].size() >= 3
	if not (数组长度匹配 and 材料数量达标):# 3. 检查材料数组长度匹配且最少3种材料
		if 生成通知:
			if not 材料数量达标:
				计划.语法糖通知("添加失败:至少放入3种炼金材料","炼金窗口")
			else:
				计划.语法糖通知("添加失败:配方损坏","炼金窗口")
		return false # 配方错误
	var 已记录的材料名:Array=[]
	for 材料名 in 配方字典["材料名称"]:
		if 材料名 == "":#检查材料名称非空
			if 生成通知:
				计划.语法糖通知("添加失败:材料名称不能为空","炼金窗口")
			return false
		if 材料名 in 已记录的材料名:#检查材料名称重复
			if 生成通知:
				计划.语法糖通知("添加失败:材料名称重复","炼金窗口")
			return false
		已记录的材料名.append(材料名)
	return true# 所有检查通过
##计算炼金配方,返回是否成功
func 计算配方(检查结果:bool=配方格式检查())->bool:
	if not 检查结果:return false
	var 抽取次数:int=20
	var 属性总和字典 = 计算配方点数()
	if 权重数据=={}:
		权重数据=计算药水权重(属性总和字典)
	var 项目列表: Array = 权重数据["项目列表"]
	var 权重列表: Array = 权重数据["权重列表"]
	var 随机 = RandomNumberGenerator.new()
	随机.seed = 哈希配方(配方字典)
	药水序列=[]
	if 项目列表.size() > 0 and 抽取次数 > 0:# 5. 权重抽取+数量计算核心逻辑
		var 权重数组 = PackedFloat32Array(权重列表)
		for i in range(抽取次数):#抽取药水
			var 随机索引 = 随机.rand_weighted(权重数组)
			if 随机索引 < 0 or 随机索引 >= 项目列表.size():continue # 极端情况跳过
			药水序列.append(项目列表[随机索引])#加入结果字典
	更新药水数量(属性总和字典)
	return true
func 更新药水数量(属性总和字典 = 计算配方点数()):
	var 随机 = RandomNumberGenerator.new()
	随机.seed = 哈希配方(配方字典)
	药水数量=[]
	药水成功=[]
	炼金点数=[]
	属性总值 = int(属性总和字典["任意"]+属性总和字典["其他"])
	for 选中药水 in 药水序列:
		var 药水数量配置 = 计划.表格.获取属性(选中药水, "药水数量", [])#计算该药水的数量
		var 最终数量:int= 1 # 默认数量
		var 运气=随机.randf()
		if 药水数量配置.size() >= 2: # 配置有效：[阈值,最大数量]
			var 每X点属性 = max(药水数量配置[0], 1) # 避免除以0
			var 属性次数:int = int((属性总值*运气)**0.85 / 每X点属性)
			if 属性次数<=0 or 运气<=0.5:
				最终数量 = 1
				药水成功.append(false)
			else :
				var 基础最大数量 = 药水数量配置[1]
				var 随机数量 = 随机.randi_range(0, 属性次数)
				最终数量 = clamp(随机数量, 1, 基础最大数量)
				药水成功.append(true)
			#print(选中药水,药水数量配置,属性次数)
		else:
			最终数量 = 1
			药水成功.append(true)
		炼金点数.append(属性总值**0.75*运气)
		药水数量.append(最终数量)
func 计算药水权重(属性总和字典):
	var 催化剂等阶= 计划.表格.蓝图数据(催化剂,"阶级")
	var 阶级数组:Array=[]
	for i in range(催化剂等阶):
		阶级数组.append(str(i+1))
	var 药水类物品 = 计划.手工.筛选符合条件蓝图({"标签":["药水"],"阶级":阶级数组},true)# 2. 筛选药水类物品并生成项目/权重列表
	var 项目列表: Array = []
	var 权重列表: Array = []
	for 药水 in 药水类物品:
		var 权重:float = 0
		var 药水倾向 = 计划.表格.获取属性(药水,"药水倾向",[])
		for i in (药水倾向.size()/3):
			var 目标=药水倾向[i*3]
			if 目标 == 催化剂:
				目标 = "任意"
			var 属性值=属性总和字典.get(目标, 0)
			if  属性值>= 药水倾向[i*3+1] or 属性值<=0:
				权重 += 药水倾向[i*3+2]
			else :
				权重 += 药水倾向[i*3+2]*(药水倾向[i*3+1]/属性值)
		if 权重 > 0:
			项目列表.append(药水)
			权重列表.append(权重)
	var 炼金药水 = 计划.表格.获取属性(催化剂,"炼金药水",[])
	var 装备药水 = null# 装备药水名称（比如"圣坚药水"）
	if 炼金药水.size()>=3:# 判断是否满足装备药水解锁条件
		装备药水 = 炼金药水[0]
		var 药水权重=属性总和字典.get(炼金药水[1], 0)
		if 药水权重>=炼金药水[2]:
			项目列表.append(装备药水)
			权重列表.append(min(药水权重+5,炼金药水[2]*2))  # 给装备药水设置权重随属性递增额外+5,但不超过两倍
		else :
			项目列表.append(装备药水)
			权重列表.append(炼金药水[2])  # 给装备药水设置权重至少
	return {"权重列表":权重列表,"项目列表":项目列表}
func 计算配方点数():
	var 目标属性列表 = ["创造", "勇气", "奇异", "洞察", "复苏", "齿轮"]
	var 材料名称列表 = 配方字典.get("材料名称", [])# 从配方中提取材料名称和数量
	var 材料数量列表 = 配方字典.get("材料数量", [])
	var 属性总和字典 = {"任意":0,"其他":0}
	var 材料属性字典 = {}
	for 材料名称 in 材料名称列表:
		var 材料字典 = 计划.表格.获取属性(材料名称, "炼金属性",{})
		材料属性字典[材料名称]=材料字典
	for 属性 in 目标属性列表:
		属性总和字典[属性] = 0
		for i in 材料名称列表.size():
			var 目标属性=材料属性字典[材料名称列表[i]].get(属性,0)
			if i>=3:
				属性总和字典["其他"]+=目标属性*材料数量列表[i]
			else :
				属性总和字典[属性]+=目标属性*材料数量列表[i]
				属性总和字典["任意"]+=目标属性*材料数量列表[i]
	return 属性总和字典
func 哈希配方(配方: Dictionary) -> int:
	var 材料名称数组 = 配方.get("材料名称", [])
	var 材料数量数组 = 配方.get("材料数量", [])
	var 材料组合列表: Array = []
	for i in range(min(3,材料名称数组.size())):
		var 材料名 = 材料名称数组[i]
		var 数量 = 0
		if not i>=材料数量数组.size():
			数量 = 材料数量数组[i]
		材料组合列表.append(材料名 + str(数量))
	材料组合列表.append(配方.get("催化剂", ""))
	材料组合列表.sort()
	var 组合字符串:String = "||".join(材料组合列表)
	return 组合字符串.hash()
func 更新附加材料(材料名称,数量):
	if not 材料名称==null and 配方格式检查():#这一步封装各种格式检查
		if 配方字典["材料名称"].size() >= 4:
			配方字典["材料名称"]=配方字典["材料名称"].slice(0, 3)
			配方字典["材料数量"]=配方字典["材料数量"].slice(0, 3)
		配方字典["材料名称"].append(材料名称)
		配方字典["材料数量"].append(数量)
		更新药水数量()
func 返回解锁数组()->Array:
	var 解锁药水:Array=[]
	if 药水序列.size()>=1 and 药水成功.size()==药水序列.size():
		for 序号 in 药水序列.size():
			if 药水成功[序号] and 序号<炼金数量:
				解锁药水.append(药水序列[序号])
	return 解锁药水
func 返回解锁字典()->Dictionary:
	var 解锁药水:Array=返回解锁数组()
	var 解锁字典:Dictionary={}
	var 队列长度:int=药水序列.size()
	var 循环数量:int=int(float(炼金数量)/队列长度)
	var 序号:int=0
	for 药水 in 解锁药水:
		if 序号>=(炼金数量%队列长度):解锁字典[药水]=循环数量
		else :解锁字典[药水]=循环数量+1
		序号+=1
	return 解锁字典
## 检查当前配方是否可移动（供UI/移动函数复用）
func 检查配方移动(后移: bool) -> bool:
	var 配方数组 = 计划.手工.读取炼金配方列表()
	if 配方数组.is_empty():return false
	var 目标索引 = 配方数组.find(self)
	if 目标索引 == -1:return false
	if 后移:return 目标索引 < 配方数组.size() - 1
	return 目标索引 > 0
## 移动配方
func 移动配方(后移: bool) -> bool:
	if not 检查配方移动(后移):return false
	var 配方数组 = 计划.手工.读取炼金配方列表()
	var 目标索引 = 配方数组.find(self)
	if 后移:配方数组.swap(目标索引, 目标索引 + 1)
	else:配方数组.swap(目标索引, 目标索引 - 1)
	计划.更新_UI.emit()
	return true
