@tool
extends Node
#class_name 梅计划
func 初始化存档():
	字典结构(梅存档,["挂机","木料","矿城","手工","游历","职业","召唤","配置文件"])
	if not 梅存档.has("金币"):
		梅存档["金币"]=2000
	字典结构(梅存档["挂机"],
	["体力","在线时间","背包与商店","装备栏","快速移动关系",
	"窗口","随身商店","用户信息","原罪数据","技能树","状态","队列","成就","收藏品","升级检查","标准商店","背包数据","地图"],
	["窗口禁用","窗口解锁","窗口禁用","红点存档","全局图钉","BUFF"],
	["任务进度","任务状态","订单"])
	if not 梅存档.挂机.has("点数") or not 梅存档.挂机.点数 is 梅点数:
		梅存档.挂机["点数"]=梅点数.new()
	点数=梅存档.挂机.点数
	if not 梅存档["挂机"].has("等级") or 梅存档["挂机"]["等级"]<0:
		梅存档["挂机"]["等级"]=0
	if not 梅存档["挂机"].has("精通"):
		梅存档["挂机"]["精通"]=0
	if not 梅存档["挂机"].has("熟练"):
		梅存档["挂机"]["熟练"]=0
	更新收藏品卡包配置字典()
#region 变量与信号声明
#当前版本不修改的默认值
#region 配置数据
##定义用户数据存储路径,由登录界面传递<br>[br]
##不可修改程序仅兼容/存档 文件夹
var 存档路径: String = "user://存档/"
##由登录界面传递,存档时创建的文件名称,自带后缀
var 存档名称: String = "存档"
##用于同步体力回复间隔
var 体力恢复速度: int = 60
##用于同步体力回复数量
var 恢复量: int = 1
#endregion 配置数据
##简短的功能支持模块缩写
#region 简短单例
##窗口路径资源:保存游戏内所有场景的路径
var 窗口: 梅窗口=梅窗口.new()
##打印调试信息开发阶段使用,仅调用方法
var 打印: 梅打印=梅打印.new()
##音效/声音数据支持
var 声音: 梅声音
##红点数据支持
var 红点: 梅红点
##任务数据支持
var 任务: 梅任务
##技能树数据支持
var 技能树: 梅技能树
##管理BUFF
var BUFF: 梅BUFF
##表格数据支持
var 表格: 梅表格
##装备管理器
var 地图:梅地图
##成就支持
var steam:梅steam
##装备管理器
var 装备:梅装备
##简短:系统玩法支持
##只读:游历系统相关支持
var 游历: 梅游历
##只读:手工系统相关支持
var 手工: 梅手工
#endregion 简短单例
#region 运行数据
## 用于存储玩家数据的字典
var 梅存档:Dictionary = {}
##用于各种点数的交易
var 点数:梅点数=null
## 当前场景注册提示信息显示的位置
var 提示容器:VBoxContainer
##用于显示悬浮提示
var 其他容器:Control
##当修改这个属性时,任务窗口被加载时会进设置
var 跳转设置=false
##默认为空
var 配置文件:Dictionary={}
## 缓存节点 方便跨场景调用,不保证有效,可以用节点有效性验证方法
var 节点={}
var 今日零点:int
var 商店刷新计时器: Timer = null
var 装备序号:int=0
var 存档时间戳:=-1.0
var 计时器创建次数: int = 0
var 游戏分辨率:Vector2=Vector2(1920,1080)
var 贴图字典
var 每秒计时器: Timer = null
var 每五秒计时器: Timer = null
var 零点计时器: Timer = null
#endregion 运行数据
##例如获得金币,物品
signal 更新_UI()
@warning_ignore("unused_signal")
##手动刷新图钉,可以指定图钉内容.获得/扣除 物品时自动发出
signal 更新_图钉(更新目标:String)
@warning_ignore("unused_signal")
##系统升级
signal 更新_系统升级()
@warning_ignore("unused_signal")
##例如制作队列被重新计算
signal 更新玩法()
@warning_ignore("unused_signal")
##更新按钮上的红点数字
signal 更新红点(指定更新)
@warning_ignore("unused_signal")
##更新商店()
signal 购买物品(物品: ItemData, 容器名: String)
@warning_ignore("unused_signal")
##背包内物品被检查的信号
signal 更新_背包物品信息(物品: ItemData,背包名称)
@warning_ignore("unused_signal")
##场景被打开刚加入场景的信号
signal 场景更新(当前场景:String)
@warning_ignore("unused_signal")
##背景色等
signal 场景全局样式()
@warning_ignore("unused_signal")
##强调通知的删除消耗,为""时移除所有
signal 删除强调通知(通知名:String)
@warning_ignore("unused_signal")
##用于原罪技能树
signal 技能点击信号(技能名称:String)
##计时器过去一秒
signal 过去一秒()
##计时器过去一秒
signal 通知更新()
@warning_ignore("unused_signal")
##更新悬浮提示文本,传入需文本方法,节点
signal 全局悬浮提示(文本内容:String,节点实例:Node,默认字体:int)
@warning_ignore("unused_signal")
##支持更多显示效果的悬浮提示
signal 数据包提示(数据:梅提示数据)
##部分功能需要单独处理保存
signal 全局保存()
@warning_ignore("unused_signal")
signal 显示暂停界面(状态:bool)
@warning_ignore("unused_signal")
signal 切换窗口状态()
enum 修改枚举{无,添加,删除}
#endregion
#region 节点就绪
# 节点初始化完成时自动调用
@warning_ignore("unused_private_class_variable")
var 测试=0
func _ready() -> void:
	if Engine.is_editor_hint():
		表格=附加代码("梅表格")
		return
	process_mode=Node.PROCESS_MODE_ALWAYS
	声音=附加代码("梅声音")
	表格=附加代码("梅表格")
	技能树=附加代码("梅技能树")
	steam=附加代码("梅steam")
	var BUFF贴图实例: BUFF贴图 = BUFF贴图.new()
	贴图字典=BUFF贴图实例.生成BUFF图标映射字典()
##游戏正式开始加载
func 正式加载() -> void:
	await get_tree().process_frame#等待背包内物品价值
	await get_tree().process_frame
	提示容器=null
	if 梅存档.has("配置文件"): 配置文件=梅存档["配置文件"]
	切换全屏(配置文件.get("全屏",false))
	初始化存档()
	_配置背包()
	今日零点=获取零点时间戳()
	零点计时器=创建计时器(获取零点时间戳()-Time.get_unix_time_from_system(),零点刷新,{"是否循环"=false})#1.检查门票过期,研究费用重置
	创建或更新商店刷新计时器()
	if 存档时间戳<获取零点时间戳(-86400):
		call_deferred("零点刷新")
	红点=附加代码("梅红点")
	红点.加载红点存档()
	任务=附加代码("梅任务")#加载顺序,存档之后
	BUFF=附加代码("梅BUFF")#玩法计算数据需要先加载BUFF以防错误
	BUFF.初始化BUFF()
	装备=附加代码("梅装备")
	装备.更新属性()
	手工=附加代码("梅手工")
	if 系统解锁("手工"):手工.手工系统上线()
	else :手工.初始化手工系统()
	游历=附加代码("梅游历")
	if 系统解锁("游历"):游历.游历系统上线()
	else :游历.初始化游历系统()
	任务.任务创建()
	if 地图 and 地图.冒险管理器:
		地图.冒险管理器.加载地图(地图.冒险管理器.地图信息)
	else :
		print("错误,没有加载地图成功")
	GBIS.sig_inv_refresh.emit()###GBIS三连_背包商店装备栏
	GBIS.sig_slot_refresh.emit()
	GBIS.sig_shop_refresh.emit()
	每秒计时器=计划.创建计时器(1,func():过去一秒.emit())#打开游戏界面
	每五秒计时器=计划.创建计时器(5,func():
		if not 节点有效性检查("原罪界面"):
			技能树.检查技能树队列())#打开游戏界面
	过去一秒.connect(func():
		#call_deferred("清理缓存")#如果未来缓存占用过大时需要清理
		卡路里检查()
		体力检查()# 封装计时器方法每秒 检查体力恢复
		在线时间更新())
	get_tree().change_scene_to_file("res://界面/主容器窗口.tscn")#打开游戏界面
	call_deferred("保存存档","初始化存档")
func 就绪()->bool:
	if 计划.梅存档=={}:
		return false
	return true
#endregion
#region 内部实现(通常不在其他代码使用)
func 清理缓存():
	缓存获取配方数据.clear()
func 附加代码(类型:String):
	var 资源映射 = {
		"梅窗口" :	梅窗口,
		"梅声音" :	梅声音,
		"梅红点" :	梅红点,
		"梅任务" :	梅任务,
		"梅技能树":	梅技能树,
		"梅表格" :	梅表格,
		"梅手工" :	梅手工,
		"梅游历" :	梅游历,
		"梅BUFF" :	梅BUFF,
		"梅steam":	梅steam,
		"梅装备":		梅装备}
	if not 资源映射.has(类型):
		print("加载代码错误：类型不存在 -> ", 类型)
		return null
	var 调试代码 = 资源映射[类型].new()
	调试代码.name = 类型
	add_child(调试代码)
	return 调试代码
func _配置背包() -> void:
	var 背包数据:Dictionary=计划.梅存档.挂机.背包数据
	GBIS.current_save_path = 存档路径# 设置保存路径
	GBIS.current_save_name = 存档名称# 设置存档名称
	GBIS.inventory_service.regist("背包", 9, 背包数据.get("背包",{}).get("行数",10), false, ["ANY"])
	GBIS.inventory_service.regist("装备", 8, 背包数据.get("背包",{}).get("行数",4), false, ["装备"])
	GBIS.inventory_service.regist("宝石", 12, 背包数据.get("背包",{}).get("行数",2), false, ["宝石"])
	GBIS.inventory_service.regist("随身商店", 5, 背包数据.get("背包",{}).get("行数",10), true, ["ANY"])
	GBIS.inventory_service.regist("方块背包", 18, 背包数据.get("背包",{}).get("行数",10), true, ["方块"])
# 生成唯一装备名称的工具函数
func 生成装备名(蓝图名: String) -> String:
	var 当前时间戳: int = int(Time.get_unix_time_from_system())# 1. 获取当前时间戳（浮点转整数，取整到秒，去掉小数）
	装备序号 += 1# 2. 当前序号+1
	return "%s_%d_%d" % [蓝图名, 当前时间戳, 装备序号]# 3. 组合名称：蓝图名_整数时间戳_序号
func 属性是否存在(对象: Object, 属性名: String) -> bool:# 辅助函数：检查对象是否存在指定属性
	# 获取对象所有属性列表
	var 属性列表 = 对象.get_property_list()
	for 属性 in 属性列表:
		if 属性.name == 属性名:
			return true
	return false
func 精通熟练需求(等级:int,基础=20,成长=0.05, 倍率 = 0) -> int:
	## 基础 不同系统内固定的基础不同最低20 ③手工系统=25
	## 成长 精通玩法 固定为0.07,熟练固定为0.1
	## 倍率 系统倍率5,系统内玩法为0.5
	if 等级 == 100 or 等级 < 0 or 等级 > 100:
		#push_warning("等级必须在0-99范围内")
		return -1
	var 基础值 = 基础 * ((1.0+成长)** 等级) + (基础**((倍率/(1.0+倍率))+1)) * (50 if 等级 > 50 else 等级)
	var 最终值 = 基础值 * (1.0 + (0.75 ** (等级 / 20.0)) * 倍率)
	return round(最终值)
func 调试精通(基础=25,成长=0.07, 倍率 = 0.5):
	print("调试精通")
	print("---------------------------------------------------------")
	var 总精通=0
	for 等级 in range(0, 100):
		var 精通=精通熟练需求(等级,基础,成长, 倍率)
		总精通+=精通
		var 天数 = 总精通/ 86400.0
		print("等级:%d = %d, 总精通: %d (%d)天" % [等级, 精通,总精通,天数])
func 体力检查():
	var 体力数据 = 梅存档["挂机"]["体力"]
	var 体力上限: int = 数据体力("体力上限")
	var 体力值: int = 体力数据.get("体力值", 240)
	var 时间差: int = 处理时间戳(体力数据)
	if 时间差 >= 体力恢复速度:
		@warning_ignore("integer_division")
		var 恢复次数 = 时间差 / 体力恢复速度  # 保持原除法逻辑（忽略警告）
		var 理论恢复总量 = 恢复次数 * 恢复量
		var 实际恢复量 = min(理论恢复总量, 体力上限 - 体力值)
		if 实际恢复量 > 0:
			体力值 += 实际恢复量  # 更新体力值
			体力数据["体力值"] = 体力值
		处理时间戳(体力数据,恢复次数 * 体力恢复速度)
		保存存档("体力回复")
		emit_signal("更新_UI")
	else :
		体力数据["体力值"] = 体力值
func 在线时间更新():
	# 确保字段存在（首次调用或零点清空后自动创建）
	if not 梅存档["挂机"].has("在线时间") or not 梅存档["挂机"]["在线时间"].has("今日累计"):
		梅存档["挂机"]["在线时间"] = {"今日累计": 0}       # 当日累计秒数
	var 在线数据 = 梅存档["挂机"]["在线时间"]
	var 时间差: float = 处理时间戳(在线数据)
	var 实际累加: float = max(0, min(时间差, 1.1))# 限制最大时间
	if 实际累加 > 0:  # 只累加正数（防系统时间回拨）
		在线数据["今日累计"] += 实际累加
		处理时间戳(在线数据,-1)# 更新上次记录时间为当前
		任务.任务通用(任务.进度类型.计时,实际累加,"在线")
	elif 时间差 < -5:
		处理时间戳(在线数据,-1)# 更新上次记录时间为当前
func 零点刷新():
	if 零点计时器==null or 零点计时器.is_queued_for_deletion():#创建下一天0点时间戳,+1秒防止重复执行
		创建计时器(获取零点时间戳(1)-Time.get_unix_time_from_system(),零点刷新,{"是否循环"=false})
	语法糖通知("触发零点刷新")
	print("零点刷新已触发")
	if 梅存档["手工"].has("灵感"):
		var 研究费用=手工.数据灵感("研究费用")
		手工.数据灵感("研究费用",int(研究费用*-1))
	if 梅存档["挂机"].has("在线时间"):
		梅存档["挂机"]["在线时间"]["今日累计"]=0
		梅存档["挂机"]["在线时间"]["开启次数"]=0
	var 体力数据 = 梅存档["挂机"]["体力"]
	var 门票=体力数据.get("门票",{})
	var 门票名: Array = 门票.keys()
	for i in 门票名:#门票过期逻辑(0点过期部分)
		print(获取零点时间戳(3600,门票[i]))
		if 获取零点时间戳(3600,门票[i])<=今日零点:
			门票.erase(i)
	梅存档["挂机"]["标准商店"]={}
	保存存档("零点重置副本次数")
	更新_UI.emit()
##检查后续路径是否都存在,并赋值,设置值会嵌套一层数组
func 安全验证(字典:Dictionary,路径: Array,设置值: Array=[])-> bool:
	var i=1
	for 路径名称 in 路径:
		if 字典.has(路径名称):
			if i==路径.size():
				if 设置值.size()>=1:
					var 值=设置值[0]
					if 值 is Dictionary or 值 is Array:
						字典[路径名称]=值.duplicate(true)
					else :字典[路径名称]=值
				return true
			elif 字典[路径名称] is Dictionary:
				字典=字典[路径名称]
				i+=1
			else :return false
		else :return false
	return true
func 切换全屏(条件):
	计划.配置文件["全屏"]=条件
	# 根据条件设置窗口模式（使用正确的枚举常量）
	if 条件:# 全屏模式（正确常量：WINDOW_MODE_FULLSCREEN）
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
	else:# 窗口模式（正确常量：WINDOW_MODE_WINDOWED）
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
#endregion
#region 便利引用
## 保存玩家数据到文件
func 保存存档(保存原因=""):
	if 配置文件.get("自动存档",true) or 保存原因=="手动存档":
		if 保存原因=="手动存档":
			全局保存.emit()
			await get_tree().process_frame
		梅存档["配置文件"]=配置文件
		梅存档格式.单例.存档(存档名称,梅存档)
		存档时间戳=Time.get_unix_time_from_system()
	print("存档已保存:",保存原因)
## 计算剩余倒计时秒数（确保非负）
func 获取剩余秒数(目标时间戳: int) -> int:#用于计时器,不可小于1
	return max(int(目标时间戳 - Time.get_unix_time_from_system()), 1)
##返回字符串剩余时间字符串
func 格式化时间(总秒数: int,限制:int=0) -> String:
	if 总秒数 < 0:
		return "00"  # 确保非负
	@warning_ignore("integer_division")
	var _小时: int = 总秒数 / 3600  # 1小时=3600秒
	var 剩余秒数 = 总秒数 % 3600  # 除去小时后的剩余秒数
	@warning_ignore("integer_division")
	var _分钟 = 剩余秒数 / 60  # 1分钟=60秒
	var _秒 = 剩余秒数 % 60  # 最终剩余秒数
	# 用字符串格式化补零（确保每位都是两位数）
	if _小时>=1:
		return "%02d:%02d:%02d" % [_小时, _分钟, _秒]
	elif _分钟>=1:
		if 限制>=3:
			return "%02d:%02d:%02d" % [_小时, _分钟, _秒]
		else :
			return "%02d:%02d" % [_分钟, _秒]
	if 限制>=3:
		return "%02d:%02d:%02d" % [_小时, _分钟, _秒]
	elif 限制>=2:
		return "%02d:%02d" % [_分钟, _秒]
	else :
		return "%02d"%_秒
## 返回今天累计的在线时间
func 当前在线时间() -> int:
	if not 梅存档["挂机"].has("在线时间"):
		return -1
	return 梅存档["挂机"]["在线时间"]["今日累计"]
func 创建或更新商店刷新计时器():
	var 缓存时间戳=int(梅存档["挂机"]["随身商店"].get("时间戳", Time.get_unix_time_from_system()))
	var 剩余秒数=获取剩余秒数(缓存时间戳)
	#print("商店刷新计时器剩余秒数:",剩余秒数)
	if 商店刷新计时器 == null or 商店刷新计时器.wait_time<=1:
		商店刷新计时器 = 创建计时器(剩余秒数, Callable(self, "商店刷新"),{"是否循环":false})#
	else:
		#print("计时器剩余秒数:",商店刷新计时器.wait_time)
		商店刷新计时器.wait_time = 剩余秒数
func 商店刷新():
	var 缓存零点时间戳=获取零点时间戳()
	var 缓存当前时间=Time.get_unix_time_from_system()
	if 缓存零点时间戳-缓存当前时间 > 7200:
		梅存档["挂机"]["随身商店"]["时间戳"]=int(缓存当前时间+7200)
	else :
		梅存档["挂机"]["随身商店"]["时间戳"]=int(获取零点时间戳())
	var 货物数组: Array[标准物品]=商店补货()
	GBIS.shop_service.get_container("随身商店").clear()
	GBIS.shop_service.load_goods("随身商店", 货物数组)
	GBIS.sig_inv_refresh.emit()#更新商店
	保存存档("商店刷新保存")
	创建或更新商店刷新计时器()
func 数组统计(数组: Array, 目标文本: String) -> int:
	var 计数 = 0
	for 文本 in 数组:
		if 文本 == 目标文本:
			计数 += 1
	return 计数
var 货物字典:={
		"商店补货列数": 6,
		"货物清单": {
		"蓝图纸": {
			"商店货量": 10,
			"购买数量": 16,
			"价格": 1600,
			"最大次数":1},
		"随机礼盒": {"价格": 2000},
		"铁锭": {
			"商店货量": 5,
			"购买数量": 10,
			"随机_商店货量": 10},
		"纤维": {
			"商店货量": 5,
			"购买数量": 10,
			"随机_商店货量": 10},
		"鞣革": {
			"商店货量": 5,
			"购买数量": 10,
			"随机_商店货量": 10},
		"麻布": {
			"商店货量": 5,
			"购买数量": 10,
			"随机_商店货量": 10},
		"木材": {
			"购买数量": 50,
			"随机_购买数量": 250,
			"价格": -5,
			"随机_商店货量": 5},
		"矿石": {
			"购买数量": 50,
			"随机_购买数量": 250,
			"价格": -5,
			"随机_商店货量": 5},
		"皮革": {
			"购买数量": 50,
			"随机_购买数量": 250,
			"价格": -5,
			"随机_商店货量": 5},
		"药草": {
			"购买数量": 50,
			"随机_购买数量": 250,
			"价格": -5,
			"随机_商店货量": 5},
		"绿色电路板": {
			"商店货量": 10,
			"购买数量": 30,
			"价格": 1800,
			"随机_购买数量": 40,
			"最大次数":2},
		"以太药水": {
			"商店货量": 5,
			"最大次数":1},
		"创生息壤药水": {
			"商店货量": 5,
			"最大次数":1},
		"维度稳固药水": {
			"商店货量": 5,
			"最大次数":1}
			}}
func 商店补货():
	var 背包数据:Dictionary=计划.梅存档.挂机.背包数据
	var 行数:int=2
	if 背包数据.has("随身商店"):
		行数=背包数据["随身商店"].get("行数")
	var 货物数组: Array[标准物品]=[]
	var 允许货物字典:Dictionary=货物字典.duplicate()
	允许货物字典["货物清单"]=补全物品基础属性(允许货物字典["货物清单"])
	var 补货次数:int = 行数*允许货物字典["商店补货列数"]
	for i in range(补货次数):
		var 可用货物列表 = []
		for 物品名称 in 允许货物字典["货物清单"]:
			var 物品数据 = 允许货物字典["货物清单"][物品名称]
			if not 物品数据.has("最大次数") or 物品数据["最大次数"] > 0:可用货物列表.append(物品名称)
		if 可用货物列表.size() == 0:break#错误没有可用货物
		var 选中物品名称 = 可用货物列表[randi() % 可用货物列表.size()]# 随机抽取物品
		var 商品数据:Dictionary = 允许货物字典["货物清单"][选中物品名称]
		if 商品数据.has("最大次数"):# 更新最大抽取次数
			商品数据["最大次数"] -= 1
			if 商品数据["最大次数"] == 0:允许货物字典["货物清单"].erase(选中物品名称)
		var 当前货物 = 标准物品.new(1,选中物品名称)
		if 商品数据.has("随机_商店货量"):
			当前货物.商店剩余数量 = randi_range(商品数据.get("商店货量",1),商品数据["随机_商店货量"])
		else :当前货物.商店剩余数量=商品数据.get("商店货量",1)
		if 商品数据.has("随机_购买数量"):
			当前货物.数量 = randi_range(商品数据.get("购买数量",1), 商品数据["随机_购买数量"])
		else:当前货物.数量 = 商品数据.get("购买数量",1)
		var 商品价格=商品数据.get("价格",-1)
		if 商品价格<0:商品价格=int(表格.蓝图数据(选中物品名称,"价值")*abs(商品价格)*当前货物.数量)
		if 商品数据.has("随机_价格"):
			var 价格上限=商品数据["随机_价格"]
			if 价格上限<0:价格上限=int(表格.蓝图数据(选中物品名称,"价值")*abs(价格上限)*当前货物.数量)
			当前货物.价值 = randi_range(商品价格, 价格上限)
		else:当前货物.价值 = 商品价格
		货物数组.append(当前货物)
	return 货物数组
## 补全物品基础属性
## @param 传入数据: 传入的嵌套字典（如 {"蓝图纸": {...}} 或空字典）
## @return: 补全基础键后的新字典（非必要键不修改/不补充）
func 补全物品基础属性(传入数据: Dictionary) -> Dictionary:
	var 基础属性默认值: Dictionary = {
		"商店货量": 1,   # 基础值1
		"购买数量": 1,   # 基础值1
		"价格": -1}     # 基础值-1(表示动态获取,倍率1)
	var 结果数据: Dictionary = {}# 初始化返回的新字典（避免修改原字典）
	for 物品名称: String in 传入数据:
		var 物品属性: Dictionary = 传入数据[物品名称].duplicate()
		for 基础键名: String in 基础属性默认值:# 遍历所有基础键，补全缺失的默认值
			if not 物品属性.has(基础键名):# 仅当基础键不存在时，才补默认值
				物品属性[基础键名] = 基础属性默认值[基础键名]
		结果数据[物品名称] = 物品属性
	return 结果数据
func 获得物品语法糖(物品名称, 数量=1,类型="标准物品",参数:Dictionary={}):
	var 道具:ItemData
	var 背包类型:String = "背包"
	if 类型=="装备物品":#有等级,可成长带有多种属性
		道具 = 物品装备.new(1,物品名称)
		背包类型 = "装备"
	elif 类型=="物品宝石":#拥有随机词条
		道具 = 物品宝石.new(1,物品名称)
		背包类型 = "宝石"
	elif 类型=="物品方块":#可以在家园玩法中放置
		道具 = 物品方块.new(1,物品名称)
		背包类型 = "方块背包"
	elif 类型=="点数":#普通物品提供特殊玩法转化获取,转化比例随游戏进度变化
		道具 = 标准物品.new(1,物品名称)
		道具.数量 = 数量
		道具.特殊标签="点数"
		背包类型 = "点数"
	else:
		道具 = 标准物品.new(1,物品名称)
		任务.打包数据.增加记录(物品名称,数量)
	if 道具.item_name=="金币":
		梅存档["金币"]+=数量
		道具.数量 = 数量
	elif 背包类型 == "点数":# 处理点数
		点数.增加点数(物品名称,数量)
	elif 道具 is StackableData:# 处理可堆叠物品
		var 真实数量=数量
		var 容量:int=道具.堆叠上限
		for i in ceili(数量*1.0/容量):
			var 拷贝道具=道具.拷贝方法()#等价 new()
			if 真实数量>=容量:
				拷贝道具.数量 = 容量
			else :
				拷贝道具.数量 = 真实数量
			GBIS.add_item(背包类型, 拷贝道具)
			真实数量-=容量
		道具.数量 = 数量#传递给显示
	else:# 处理不可堆叠物品
		for i in range(数量):
			GBIS.add_item(背包类型, 道具.duplicate())# 每次添加都创建新实例，避免引用同一对象
	if 参数.has("粒子") and 参数.粒子:
		语法糖粒子(物品名称,数量)
	更新_图钉.emit(物品名称)
	return 道具
##返回背包内物品数量
func 检查背包物品数量(物品名称)->int:
	var 物品列表 = GBIS.inventory_service.find_item_data_by_item_name("背包", 物品名称)
	var 鼠标物品=GBIS.moving_item_service.moving_item
	if 鼠标物品 and 鼠标物品.item_name == 物品名称:
		物品列表.append(鼠标物品)
	var 总数量 = 0
	if 物品列表.size() == 0:
		return 0# 如果没有找到物品，直接返回0
	for 单个物品 in 物品列表:# 遍历所有找到的物品
		if 单个物品 is StackableData:# 可堆叠物品
			总数量 += 单个物品.数量
		else:# 不可堆叠物品，默认数量为1
			总数量 += 1
	return 总数量
func 无功能方法():
	print("调用节点:", self.name)
func 切换场景(主场景:String="合成界面",强制:bool=false):
	if 节点有效性检查("主容器窗口"):
		if 窗口.窗口数据.has(主场景):
			var 窗口解锁数组: Array = 梅存档.挂机.窗口解锁
			if 强制 or 窗口解锁数组.has(主场景) or 窗口.窗口数据[主场景].get("解锁",false):
				节点["主容器窗口"].重载场景(主场景,强制)
			else :
				语法糖通知("需要先解锁<%s窗口>,完成任务解锁更多内容"%[窗口.窗口数据[主场景].显示名],"跳转错误")
		else :
			语法糖通知("错误,这是一个意外的参数")
	else:
		get_tree().change_scene_to_file("res://界面/空界面.tscn")
		print("主容器窗口不存在，已切换到空界面")
enum 玩法枚举 {无,暴食,合成,灵感,炼金,烹饪}
##强制更新,假设等级降低了,需要刷新与等级相关的增益时启用
func 结算升级(系统="手工",玩法:玩法枚举=玩法枚举.无,项目="null",跳过检查=false,强制更新=false)-> int:
	var 数据 = 梅存档.get(系统,{"数据错误":0})
	if 数据 == {"数据错误":0}:
		print("未找到存档数据")
		return -1
	var 升级=false
	var 等级
	var 经验值
	var 基础
	var 成长 = 0.07
	var 倍率 = 0.5
	if 系统=="挂机":
		var 突破 = 数据原罪("突破")
		var 基础值字典={0:22,1:23,2:25,3:26,4:28,5:29,6:31,7:32,8:34,9:35,
			10:37,11:38,12:40,13:41,14:43,15:44,16:46,17:47,18:49,19:50}
		if 基础值字典.has(突破):基础 = 基础值字典[突破]
		else :基础 =100
	elif 系统=="手工":基础 = 25#基础由系统类型决定.在此枚举
	else :基础 = 100
	var 系统等级=int(数据.get("等级", -1))
	if 玩法==玩法枚举.无 or 项目=="null":#为空表示系统的升级检查,否则该值传入项目名称.例如 "基础剑" 与键名相同
		等级 = 系统等级
		经验值 = int(数据.get("熟练", 0))
		成长 = 0.1
		倍率 = 5
		if 等级==-1:return -1#系统未解锁对应返回值
	else:
		match 玩法:
			玩法枚举.暴食:
				数据=数据["原罪数据"].get("暴食里程碑",{}).get(项目,{})
				if 数据.get("等级", -1)==-1:数据["等级"]=0
			玩法枚举.合成:数据=数据.get("合成配方",{}).get(项目,{})
			玩法枚举.灵感:
				数据=数据.get("灵感",{})
				if 数据.get("等级", -1)==-1:数据["等级"]=1
			玩法枚举.炼金:数据=数据.get("催化剂",{}).get(项目,{})
			玩法枚举.烹饪:数据=数据.get("烹饪菜谱",{}).get(项目,{})
			_:数据={}
		等级 = int(数据.get("等级", -1))
		经验值 = int(数据.get("精通", 0))
		#if not 跳过检查:print(玩法,":",项目,经验值)
		if 等级==-1:return -1#项目未解锁对应返回值,结算升级不可解锁项目
	if not 跳过检查:
		var 需求经验:int=0
		while true:#循环到等级为100或经验值不足,等级100时所需经验值为-1
			需求经验 = 精通熟练需求(等级,基础,成长,倍率)
			if 项目=="null":#
				if 系统=="挂机":if 等级>=(数据原罪("突破")+1)*5: break
			else:
				var 升级检查:Dictionary=梅存档[系统].get("升级检查",{})
				var 玩法文本=玩法枚举.keys()[玩法]
				var 组合名称=玩法文本+项目
				if 等级>=系统等级+5:
					if not 升级检查.has(组合名称) and 需求经验 > 0 and 经验值 >= 需求经验:
						升级检查[组合名称]=[项目,玩法文本]
					break
				else :if 升级检查.has(组合名称):升级检查.erase(组合名称)
			if 需求经验 > 0 and 经验值 >= 需求经验:
				等级 += 1
				经验值 -= 需求经验
				升级=true
			else:break
		if 项目=="null":#为空存回系统等级,反之同理
			数据["等级"]=等级
			数据["熟练"]=经验值
			if (升级 or 强制更新):系统等级后检查逻辑(系统)
		else:
			数据["等级"]=等级
			数据["精通"]=经验值
		return 需求经验
	return 精通熟练需求(等级,基础,成长,倍率)
func 系统等级后检查逻辑(系统):
	if 系统=="手工":
		手工.资源刷新()
		手工.重算资源回复()
	#系统升级后项目的等级上限会增加
	var 升级检查:Dictionary=梅存档[系统].get("升级检查",[]).duplicate()
	if 升级检查.size()>=0:
		for 项目名称 in 升级检查:
			var 项目数据=升级检查[项目名称]
			if 项目数据 is Array and 项目数据.size()>=2:
				var 玩法:玩法枚举=玩法枚举[项目数据[1]]
				结算升级(系统,玩法,项目数据[0])
				print("数据数据",项目数据)
			else :
				print("错误数据",升级检查[项目名称])
				梅存档[系统]["升级检查"].erase(项目名称)
	装备.更新属性(系统)
	更新_系统升级.emit()
	更新玩法.emit()
func 精通收益(时间戳) -> int:
	var 精通力=装备.精通力
	if 时间戳==-1:return -1#特殊情况 之前的方法内报错会传入-1,同样返回-1
	var 一阶时长:int = 60+int(pow(精通力,3/4.0))
	var 二阶时长:int = 300+int(pow(精通力,9/10.0))
	var 时间差 = max(0, 时间戳)# 计算时间差（确保不为负数）
	if 时间差 <= 一阶时长:return int(时间差)# 根据时间差计算收益
	elif 时间差 <= 二阶时长:return int(一阶时长+(时间差 - 一阶时长)/2.0)
	else:return int(一阶时长 + (二阶时长/2.0))
func 预生成文本(配方,配方解锁=false,富文本支持: Array[int]=[-1],_项目类型="合成")->String:
	var 配方名称:String
	if 配方 is int and 表格.创世蓝图.size()>配方:配方名称 = 表格.创世蓝图[配方][0]
	elif 配方 is String and 表格.蓝图字典.has(配方):配方名称=配方
	else :return""
	var 配方等级 = 手工.数据合成配方(配方名称)
	var 配方升星 = 手工.数据合成配方(配方名称,"升星")
	# 构建内容字符串
	var 材料列表 = []
	for 键 in 手工.资源字典.keys():
		if 表格.蓝图数据(配方名称,键) > 0:
			var 材料数量:float=float(表格.蓝图数据(配方名称,键))
			if 配方升星>=1:
				材料数量=材料数量*0.9
				材料列表.append(键 + "*%.1f"%材料数量)
			else :材料列表.append(键 + "*%.0f"%材料数量)
	var 制作耗时:float=float(表格.蓝图数据(配方名称,"冷却"))
	var 内容字符串 = "自动最低:"+"%.1f秒"%制作耗时 + ("\n"+"\n".join(材料列表) if 材料列表.size() > 0 else "无")
	var 属性字符串 = 获取装备属性(配方名称)
	if 配方解锁:
		var 缓存字符串
		if 配方等级>0:
			缓存字符串="LV:"+str(配方等级)+" ("+str(手工.数据合成配方(配方名称,"精通"))+"/"+str(
				结算升级("手工",玩法枚举.合成,配方名称,true))+")\r"
			if 配方升星>=1:缓存字符串+="升星:"+"★".repeat(配方升星)+"\r"
		else :缓存字符串="蓝图未解锁\r"
		内容字符串=缓存字符串+内容字符串
	else :
		if 富文本支持==[-1]:内容字符串=表格.蓝图数据(配方名称,"简介")+"\n"+内容字符串
		else :
			内容字符串="[font_size="+str(富文本支持[1])+"]"+表格.蓝图数据(配方名称,"简介")+"[/font_size]"+"\n"+内容字符串
			属性字符串="[font_size="+str(富文本支持[1])+"]"+属性字符串+"[/font_size]"
	if not 富文本支持==[-1]:
		var 文本尺寸:int=富文本支持[0]
		for 贴图 in 手工.资源字典:
			内容字符串 = 内容字符串.replace(贴图+"*","[img=%dx%d]%s[/img]:"%[文本尺寸,文本尺寸,手工.资源字典[贴图]["贴图"].resource_path])
		if  富文本支持.size()>=3 and 富文本支持[2]>0:
			var 装备贴图=表格.道具贴图(配方名称).resource_path
			内容字符串="[img="+str(富文本支持[2])+"x"+str(富文本支持[2])+"]"+装备贴图+"[/img]\n"+内容字符串
	return"配方:<" + 配方名称 + ">\n" + 内容字符串 + (("\n" + 属性字符串) if 属性字符串 != "" else "")
func 获取装备属性(_装备名称)->String:
	#var 装备实例:物品装备=物品装备.new(2)#需要获取装备属性要实例一个装备
	#装备实例.item_name=装备名称
	#装备实例.分类=表格.蓝图数据(装备名称,"分类")
	#装备实例.类型=表格.蓝图数据(装备名称,"类型")
	return ""
##没有的时间戳会创建,有则返回
##增加值=-1会设置为当前时间
##类型0:已过时间(int),类型1:时间戳本身,类型2:存在=真
## 计划.处理时间戳(梅存档["手工"][],0)
func 处理时间戳(时间戳路径: Dictionary,增加值:int=0,返回类型:int=0) :
	if not 时间戳路径 is Dictionary:
		print("错误:处理时间戳:",时间戳路径)
		return -1
	if 返回类型==2:
		return 时间戳路径.has("时间戳")
	var 当前时间:float = Time.get_unix_time_from_system()  # 获取当前系统时间戳（秒）
	if not 时间戳路径.has("时间戳") or 增加值==-1:# 检查时间戳路径是否存在该键
		时间戳路径["时间戳"] = 当前时间#不存在则创建并初始化为当前时间
	else:
		if 增加值!=0:
			时间戳路径["时间戳"] += 增加值
		if 时间戳路径["时间戳"] > 当前时间:# 处理系统时间回拨
			时间戳路径["时间戳"] = 当前时间
	if 返回类型==1:
		return 时间戳路径["时间戳"]
	#print(当前时间,"\r",时间戳路径["时间戳"],"\r",时间戳路径)
	return 当前时间-时间戳路径["时间戳"]
## 创建计时器统一方法
## 必选参数：时间间隔、回调方法
## 可选参数：通过字典传递，所有布尔值/挂载位置都在字典里
func 创建计时器(时间间隔: float, 回调方法: Callable, 选项: Dictionary = {}) -> Timer:
	var 是否循环: bool = 选项.get("是否循环", true)          # 原默认true
	var 回传计时器: bool = 选项.get("回传计时器", false)    # 原默认false
	var 错峰计算: bool = 选项.get("错峰计算", true)          # 原默认true
	var 挂载位置: Node = 选项.get("挂载位置", self)         # 原默认self
	var 计时器: Timer = Timer.new()
	if 回传计时器:
		回调方法 = func(): 回调方法.call(计时器)  # 需确保回调接受至少1个参数
	# 错峰计算逻辑
	if 错峰计算 and 是否循环:
		计时器创建次数 += 1
		var 时间间隔小数: int = round((时间间隔 - floor(时间间隔)) * 1000)
		var 当前时间: int = Time.get_ticks_msec() + 时间间隔小数
		var 基础延迟: float = 1.0 - (当前时间 % 1000) / 1000.0
		var 帧间隔: float = 1.0 / 30.0
		var 错峰延迟: float = 基础延迟 + ((计时器创建次数 - 1) % 30) * 帧间隔
		计时器.wait_time = 时间间隔 + 错峰延迟
		var 错峰回调: Callable = func():
			计时器.wait_time = max(0.1,时间间隔)
		计时器.timeout.connect(错峰回调, CONNECT_ONE_SHOT)
	else:
		计时器.wait_time = 时间间隔
	if 是否循环:
		计时器.timeout.connect(回调方法)
	else:
		计时器.one_shot = true
		计时器.timeout.connect(func():
			计时器.queue_free()
			回调方法.call())
	挂载位置.add_child(计时器)
	计时器.start()
	return 计时器
func 获得体力(体力值:int,限制=true):
	var 体力数据 = 梅存档["挂机"]["体力"]
	var 体力上限:int=数据体力("体力上限")
	体力数据["体力值"] += 体力值
	if 限制:
		if 体力数据["体力值"]+体力值>体力上限:
			体力值=int(体力上限-体力数据["体力值"])
	return 体力值
func 体力门票(需求体力值,门票名称=null) -> bool:
	var 体力数据 = 梅存档["挂机"]["体力"]#获取挂机数据,体力与门票保存在这里
	var 门票=体力数据.get("门票",{})
	if 需求体力值==0 and not 门票名称==null:#体力值设为0且门票不为null时为剪票逻辑,存在则返回成功并销毁门票.
		if 门票.has(门票名称):
			门票.erase(门票名称)
			return true
		return false
	if 门票名称 != null and 门票.has(门票名称) :
		return true
	elif 需求体力值<=体力数据.get("体力值", 240):
		if 门票名称 != null:#如果没有门票名称则直接扣除体力
			门票[门票名称]=int(Time.get_unix_time_from_system())
			体力数据["门票"] = 门票
			计划.语法糖通知("门票购买成功,今日内重试不反复消耗体力","门票")
		体力数据["体力值"] -= 需求体力值
		数据原罪("原罪值","傲慢",需求体力值*2)
		保存存档("消耗体力%d成功"%需求体力值)
		return true
	return false
func 获取零点时间戳(检查跳跃: int = 0,时间戳:int=int(Time.get_unix_time_from_system())) -> int:
	var 北京时间: int = int(检查跳跃+时间戳 + 32 * 3600)# 转换为北京时间戳（UTC+8）
	var 目标零点: int= int(北京时间 / 86400.0) * 86400# 计算今天0点的北京时间戳
	return 目标零点- 8 * 3600# 计算当前到初始目标零点的剩余秒数
func 全局图钉(物品名称:String,按钮状态:bool):
	if 按钮状态:
		梅存档["挂机"]["全局图钉"].append(str(物品名称))
	else :
		梅存档["挂机"]["全局图钉"].erase(str(物品名称))
	if 节点.has("主容器窗口") and 节点["主容器窗口"] != null:
		节点["主容器窗口"].重载图钉()
func 唯一ID(序号=0):
	var 时间戳 = str(Time.get_unix_time_from_system())
	var 时间戳最后6位 = 时间戳.substr(max(0, 时间戳.length() - 6))
	var 随机值 = str(randi() % 100).pad_zeros(2)  # 确保2位数
	return str(序号) + "#" + 时间戳最后6位 + "#" + 随机值
func 节点有效性检查(节点名称:String)->bool:
	return 节点名称 in 节点 and 节点[节点名称] != null
var 缓存获取配方数据:Dictionary={}
func 获取配方(类型参数="基础素材",阶级最大:int=20,阶级最小:int=1):#适用于合成界面筛选图纸
	if 阶级最大<阶级最小:
		var 最小缓存=阶级最小
		阶级最小=阶级最大
		阶级最大=最小缓存
	if 缓存获取配方数据.has(类型参数):
		if 缓存获取配方数据[类型参数].has(Vector2i(阶级最大,阶级最小)):
			return 缓存获取配方数据[类型参数][Vector2i(阶级最大,阶级最小)]
	var 图纸数据=表格.创世蓝图
	var 图纸条件=表格.蓝图表头["类型"]
	if 类型参数=="特殊":
		图纸条件=表格.蓝图表头["图纸集"]
	if 类型参数=="工具":
		图纸条件=表格.蓝图表头["分类"]
	var 图纸数组:Array=[]
	for 图纸 in 图纸数据:
		if 图纸[图纸条件] ==类型参数 :
			var 阶级整数=表格.蓝图数据(图纸[0],"阶级")
			#print(阶级整数,图纸[0])
			if not 阶级整数 is int:阶级整数=0
			if 阶级整数<=阶级最大 and 阶级整数>=阶级最小:
				图纸数组.append(图纸[0])
	if not 缓存获取配方数据.has(类型参数):缓存获取配方数据[类型参数]={}
	缓存获取配方数据[类型参数][Vector2i(阶级最大,阶级最小)]=图纸数组
	#print("筛选",图纸数组,Vector2i(阶级最大,阶级最小))
	return 图纸数组
func 获取标签(类型参数="材料",最大阶级=20):
	var 图纸数据=表格.创世蓝图
	var 图纸数组=[]
	var 序号=0
	for 图纸 in 图纸数据:
		if 序号<2:
			序号+=1
		else :
			if 表格.蓝图数据(图纸[0],"阶级")<=最大阶级 and 表格.蓝图标签检查(图纸[0],类型参数):
				图纸数组+=[图纸[0]]
	return 图纸数组
## 将整数转换为罗马数字（用于"等阶"显示）[br]
## 参数: 整数 （范围1-3999）[br]
## 返回: 对应的罗马数字字符串，若输入无效则返回空字符串
func 罗马数字(整数: int) -> String:
	if 整数 < 0 or 整数 > 3999:# 检查输入有效性（装备等级通常为正整数）
		return ""
	if 整数 == 0:return "零"
	var 罗马数组 = [# 罗马数字数值与符号映射表（从大到小排列）
		[1000, "M"],  # 千位
		[900, "CM"],
		[500, "D"],
		[400, "CD"],
		[100, "C"],   # 百位
		[90, "XC"],
		[50, "L"],
		[40, "XL"],
		[10, "X"],    # 十位
		[9, "IX"],
		[5, "V"],
		[4, "IV"],
		[1, "I"]]    # 个位
	var 文本 = ""
	for 罗马符号 in 罗马数组:# 从最大数值开始匹配，逐步减少剩余值并拼接符号
		var 值 = 罗马符号[0]
		var 符号 = 罗马符号[1]
		while 整数 >= 值:# 当剩余值大于等于当前数值时，拼接符号并减少剩余值
			文本 += 符号
			整数 -= 值
		if 整数 == 0:# 剩余值为0时提前退出循环
			break
	return 文本
func 字典结构(目标字典: Dictionary, 字典键数组: Array=[], 数组键数组: Array=[],移除键数组:Array=[]) -> void:
	for 键 in 字典键数组:# Godot 4 推荐用 `in` 判断键存在性，`is` 判断类型
		if not 键 in 目标字典 or not (目标字典[键] is Dictionary):
			目标字典[键] = {}
	for 键 in 数组键数组:# 处理「数组类型键」：不存在 或 类型非数组 → 覆盖为空数组
		if not 键 in 目标字典 or not (目标字典[键] is Array):
			目标字典[键] = []
	for 键 in 移除键数组:
		if 目标字典.has(键):
			print("移除%s键"%键,目标字典[键])
			目标字典.erase(键)
func 清除子节点(节点容器:Node,保留节点:Node=null):
	for 节点名 in 节点容器.get_children():
		if 保留节点==null or 节点名!=保留节点:
			节点容器.remove_child(节点名)
			节点名.queue_free()
func 科学计数(数值, 小数位数: int = 2,免转换范围:int=10000) -> String:
	if 数值 == 0:
		return "0"
	var 格式化数值 ="%.{长度}f".format({"长度":str(小数位数+1)})
	var 全零后缀 = "."+"0".repeat(小数位数)
	if abs(数值) < 免转换范围:
		格式化数值 =切割文本(格式化数值%float(数值))
		return 格式化数值.replace(全零后缀, "")
	var 量级 = 0# 计算数量级（10的幂）
	var 绝对值: float = abs(float(数值))
	if 数值>=1:
		while 绝对值 >= 10:
			绝对值 /= 10
			量级 += 1
	else :
		while 绝对值 < 1 and 绝对值 > 0:
			绝对值 *= 10
			量级 -= 1
	格式化数值 = 切割文本(格式化数值%绝对值)# 格式化小数部分（保留指定位数）
	格式化数值 = 格式化数值.replace(全零后缀, "")
	return "%se%d" % [格式化数值, 量级]# 拼接科学计数法字符串（如 "9.22e18"）
func 切割文本(文本: String) -> String:
	if 文本.length() <= 1:
		return 文本
	return 文本.substr(0, 文本.length() - 1)
func 打开存档目录(存档的路径=存档路径) -> bool:
	var 系统绝对路径: String = ProjectSettings.globalize_path(存档的路径)
	# 确保目录存在
	if not DirAccess.dir_exists_absolute(系统绝对路径):
		var 创建结果 = DirAccess.make_dir_recursive_absolute(系统绝对路径)
		if 创建结果 != OK:
			print("存档目录创建失败：", 系统绝对路径)
			return false

	# 尝试使用不同的方法打开
	var 命令: String = "cmd.exe"
	var 命令参数: PackedStringArray = ["/c", "start", "", 系统绝对路径]
	var 输出数组: Array = []
	var 退出码: int = OS.execute(命令, 命令参数, 输出数组)

	if 退出码 == 0:
		print("成功打开存档目录：", 系统绝对路径)
		return true
	else:
		print("打开存档目录失败，错误码：", 退出码)
		# 打印更多调试信息
		print("命令：", 命令)
		print("参数：", 命令参数)
		print("输出：", 输出数组)
		return false
func 文本节点宽度(文本节点,对齐方式:HorizontalAlignment=HORIZONTAL_ALIGNMENT_LEFT)->Vector2:
	if 文本节点 is RichTextLabel :
		var 字体:Font=文本节点.get_theme_font("normal_font")
		var 文本内容:String=文本节点.text
		var 字体大小:int=文本节点.get_theme_font_size("normal_font_size")
		return 字体.get_string_size(文本内容,对齐方式, -1,字体大小)
	elif 文本节点 is Label:
		var 字体:Font=文本节点.get_theme_font("font")
		var 文本内容:String=文本节点.text
		var 字体大小:int=文本节点.get_theme_font_size("font_size")
		return 字体.get_string_size(文本内容,对齐方式, -1,字体大小)
	return Vector2(0,0)
#endregion 便利引用
#region 语法糖
##快速寻找符号标签数组的物品名称
func 语法糖获取标签组(标签数组,最大阶级=20):
	var 图纸数组=[]
	for 标签 in 标签数组:
		图纸数组+=获取标签(标签,最大阶级)
	return 图纸数组
##新代码规范 需要已语法糖开头 便利检索.原方法放入便利引用
func 语法糖获得物品(物品名称, 数量=1,  类型="标准物品",参数:Dictionary = {}):
	return 获得物品语法糖(物品名称,数量,类型,参数)
##消耗物品数量的代码,超出部分不处理
func 语法糖消耗物品(物品名称, 数量=1,_参数 = null):
	GBIS.inventory_service.消耗指定数量物品("背包",物品名称,数量)
	更新_图钉.emit(物品名称)
##封装的精通获取逻辑
func 语法糖_快速熟练精通(系统,项目=null,熟练收益=true,类型="合成",自动存档:bool=true):
	var 通知=计划.配置文件.get("精通通知",true)
	var 时间戳路径=梅存档[系统]
	var 时间戳=计划.处理时间戳(时间戳路径)
	var 收益 = 精通收益(时间戳)
	if 收益 > 0 and 熟练收益:
		var 熟练转移:float=数据原罪("熟练转移",系统)
		#print("挂机+",收益*熟练转移,"手工+",收益*(1.0-熟练转移))
		if 熟练转移>0.0 and 熟练转移<=1.0:
			快速熟练精通_系统升级("挂机",收益*熟练转移)
		if 熟练转移<1.0 and 熟练转移>=0.0:
			快速熟练精通_系统升级(系统,收益*(1.0-熟练转移))
	if 项目!=null:
		收益=0
		match 类型:
			"合成":
				if 表格.蓝图字典.has(项目):
					var 冷却=表格.蓝图字典[项目][表格.蓝图表头["冷却"]]
					收益 = max(int(冷却), 1)
					手工.数据合成配方(项目,"精通",收益)
			_:
				计划.语法糖通知(类型+"的项目"+项目+"发出错误")
		if 通知 and 收益>0:计划.语法糖通知(项目+"项目精通+"+str(收益),"手工精通")
	计划.处理时间戳(时间戳路径,-1)#更新时间戳
	if 自动存档:保存存档("精通熟练收益结算")
func 快速熟练精通_系统升级(系统,收益):
	var 通知=计划.配置文件.get("熟练通知",true)
	var 升级检查:Dictionary=梅存档[系统].get("升级检查",{})
	var 增益:int=升级检查.size()
	var 熟练= 收益*(1+0.1*梅存档["挂机"].get("等级",0)+增益*0.05)
	var 精通= 收益*(1.28**数据原罪("突破"))
	梅存档[系统]["熟练"]+=熟练
	if 梅存档[系统]["精通"] >= 数据精通上限(系统):
		精通=精通*0.5#超出上限部分收益减半
	梅存档[系统]["精通"]+=精通
	if 通知:计划.语法糖通知(系统+"系统熟练+%.0f"%熟练+"精通池(+%.0f"%精通+")",系统+"熟练")
	结算升级(系统)
##对指定数值内两个元素进行交互,返回布尔值.
func 语法糖_数组移动(原数组: Array, 源索引: int, 目标索引: int) -> bool:
	if 原数组.size() == 0:# 检查数组是否为空
		print("错误：数组为空，无法移动元素")
		return false
	if 源索引 < 0 or 源索引 >= 原数组.size():# 检查索引合法
		print("错误：源索引超出数组范围（有效范围：0 ~ ", 原数组.size() - 1, "）")
		return false
	if 目标索引 < 0 or 目标索引 >= 原数组.size():
		print("错误：目标索引超出数组范围（有效范围：0 ~ ", 原数组.size() - 1, "）")
		return false
	if 源索引 == 目标索引:# 检查源索引和目标索引是否相同
		return true
	var 被移动元素 = 原数组.pop_at(源索引)# 执行移动操作
	if 源索引 < 目标索引:# 当源索引小于目标索引时，弹出元素后目标索引需要减1
		原数组.insert(目标索引 - 1, 被移动元素)
	else:
		原数组.insert(目标索引, 被移动元素)
	return true
##如果节点有效,调用节点API显示道具,注意:默认不会清空之前的内容,设置为空会隐藏
func 语法糖奖励显示(物品的数组: Array,标题:String="待确认奖励",详情等级:int=0,清空之前:bool=false,延迟重试:int=10):
	if 节点有效性检查("奖励悬浮面板"):
		var 面板:奖励悬浮面板=节点["奖励悬浮面板"]
		面板.标题节点.text=标题
		面板.详情=详情等级
		面板.custom_minimum_size=Vector2(10,0)+面板.标题节点.get_combined_minimum_size()
		if 清空之前:
			面板.物品数组=物品的数组
		else :
			面板.物品数组+=物品的数组
	else :
		if 延迟重试<=0:
			语法糖通知("错误,加载奖励显示失败")
			return
		await get_tree().process_frame
		call_deferred("语法糖奖励显示",物品的数组,标题,详情等级,清空之前,延迟重试-1)
##检查存档里是否有足够金币,扣款成功返回真,失败返回假
func 语法糖金币消费(消耗量,来源="默认消费"):
	var 用户数据=梅存档["挂机"]["用户信息"]
	if 梅存档["金币"]>=消耗量 and 消耗量>0:
		梅存档["金币"]-=消耗量
		任务.任务通用(任务.进度类型.消费,消耗量,来源)
		更新_图钉.emit("金币")
		用户数据["金币消费"]=用户数据.get("金币消费",0)+消耗量
		#更新_UI.emit()
		return true
	return false
## 用于保存历史通知信息的数组
var 历史通知文本列表:Array = []
var 缓存通知节点:通知场景
func 语法糖通知(文本:String,替换标签:String="",组件位置:Control=提示容器,启用延迟尝试:int=10):
	var 通知位置 = 计划.配置文件.get("通知位置", "右")# 从配置文件读取对齐方式，默认靠右
	if 通知位置=="悬浮":
		组件位置=其他容器
	var 容器有效 = 组件位置 is Control and 组件位置.is_inside_tree()
	if 容器有效:
		if 替换标签 != "" and 通知位置!="悬浮":#替换标签的提示
			for 子节点 in 组件位置.get_children():
				if 子节点.标签 == 替换标签:
					子节点.queue_free()
		var 对象:通知场景=preload("res://界面/插件/通知.tscn").instantiate()
		对象.文本=文本+" "
		对象.标签=替换标签
		if 缓存通知节点:
			对象.前辈=缓存通知节点
		组件位置.add_child(对象)
		缓存通知节点=对象
		历史通知文本列表.append(文本)
		if 历史通知文本列表.size() > 计划.配置文件.get("最大通知",20):
			历史通知文本列表.pop_at(0)
		通知更新.emit()
	else :
		if 启用延迟尝试>0:
			call_deferred("延迟加载通知", 文本, 替换标签,启用延迟尝试-1)
		else :
			print("节点错误:",文本)
func 延迟加载通知(文本, 替换标签,启用延迟尝试):
	await get_tree().process_frame
	语法糖通知(文本, 替换标签, 提示容器, 启用延迟尝试)
func 语法糖强调通知(文本:String,替换标签:String,标签点击动作:Callable=func():pass,自定义前缀:String="[b]<跳转>[/b]"):
	var 组件位置:Container=提示容器
	var 容器有效 = 组件位置 is Container and 组件位置.is_inside_tree()
	if 容器有效:
		if 替换标签 != "":# 如果指定了替换标签，则先删除相同标签的已有提示
			for 子节点 in 组件位置.get_children():
				if 子节点.标签 == 替换标签:
					子节点.queue_free()
		var 对象:通知场景=preload("res://界面/插件/通知.tscn").instantiate()
		对象.文本=自定义前缀+文本
		对象.标签=替换标签
		对象.点击动作=标签点击动作
		组件位置.add_child(对象)
var 背包坐标:Vector2=Vector2(0,0)
func 语法糖粒子(图片文本: String,数量: int=3) -> void:
	if not 其他容器:
		print("参数错误：容器为空")
		return
	var 目标精灵尺寸: Vector2 = Vector2(90, 90)
	var 起点: Vector2=其他容器.get_global_mouse_position()+Vector2(0,50)
	var 路径终点: Vector2=背包坐标
	var 图片:Texture2D=计划.表格.道具贴图(图片文本)
	if 图片 == null or 数量 <= 0:
		print("参数错误：图片为空或数量无效")
		return
	var 图片原始尺寸: Vector2 = 图片.get_size()
	if 图片原始尺寸.x <= 0 or 图片原始尺寸.y <= 0:
		print("错误：图片", 图片文本, "尺寸无效，无法计算缩放倍率")
		return
	var 缩放倍率_x: float = 目标精灵尺寸.x / 图片原始尺寸.x
	var 缩放倍率_y: float = 目标精灵尺寸.y / 图片原始尺寸.y
	var 最终缩放倍率: Vector2 = Vector2(min(缩放倍率_x, 缩放倍率_y), min(缩放倍率_x, 缩放倍率_y))
	# 公式：实际粒子数 = ceil(log2(数量 + 1))，但不超过10
	var 实际粒子数: int = ceil(log(数量 + 1) / log(2))
	for i in clampi(实际粒子数, 1, 10):
		var 移动精灵: Sprite2D = Sprite2D.new()
		移动精灵.texture = 图片
		移动精灵.centered = true  # 精灵锚点居中
		移动精灵.scale = 最终缩放倍率
		# 初始位置：在起点基础上轻微偏移，避免多个精灵重叠
		var 偏移量: Vector2 = Vector2(randf_range(-目标精灵尺寸.x,目标精灵尺寸.x), randf_range(-目标精灵尺寸.y,目标精灵尺寸.y))
		移动精灵.position = 起点 + 偏移量
		其他容器.add_child(移动精灵)
		播放精灵动画(移动精灵, 路径终点)# 启动精灵的动画逻辑
# 精灵动画逻辑：先掉落，后飞向终点
func 播放精灵动画(精灵节点: Sprite2D, 目标终点: Vector2) -> void:
	# 创建Tween动画节点（Godot 4推荐使用SceneTreeTween）
	var 动画控制器: Tween = create_tween()
	动画控制器.set_parallel(false)  # 串行执行动画（先掉落，后飞行）
	# 1. 掉落动画：先向下移动一段距离，模拟重力下坠
	var 掉落终点: Vector2 = 精灵节点.position + Vector2(0, 30)  # 向下掉落30像素
	动画控制器.tween_property(精灵节点, "position", 
		掉落终点, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)  # 缓出曲线，模拟重力
	# 2. 飞向终点动画：掉落完成后，飞向目标点
	动画控制器.tween_property(精灵节点, 
		"position",目标终点, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)  # 缓入缓出，飞行更顺滑
	# 3. 动画结束后销毁精灵
	动画控制器.finished.connect(精灵节点.queue_free)
#endregion 语法糖
#region 任务
func 对话处理(任务代号:String,附加值=[]):
	var 唯一任务字典:=任务.唯一任务字典
	if 唯一任务字典.has(任务代号):
		唯一任务字典[任务代号].任务完成逻辑(附加值)
func 成就处理(成就名称):
	steam.解锁成就(成就名称)
func 解锁窗口(窗口名称):
	var 窗口解锁 = 梅存档.挂机.窗口解锁
	if not 窗口解锁.has(窗口名称):
		红点.增加红点(窗口名称)
	窗口.解锁窗口(窗口名称)
	if 节点有效性检查("主容器窗口"):
		节点["主容器窗口"].生成任务栏按钮()
		计划.语法糖通知("已解锁"+窗口名称)
func 解锁研究方向(研究方向):
	手工.数据灵感("研究方向",研究方向)
	红点.增加红点("合成窗口")
	计划.语法糖通知("已解锁"+研究方向)
func 解锁系统(系统):
	if 系统=="手工":
		if not 手工.上线:手工.手工系统上线()
func 系统解锁(系统)->bool:
	if 梅存档[系统].get("等级",-1)==-1:
		return false
	return true
#endregion 任务
#region 窗口功能
##用于控制所有窗口(含其他系统)的状态修改例如选中物品等"非重要数据"可能被清空!
##返回的数据存在旧版本储存结果不可信,必须处理例外情况
func 窗口状态管理(窗口名称,条目,默认=null,修改=null):
	var 窗口字典:Dictionary = 梅存档["挂机"]["窗口"]
	if not 窗口名称 in 窗口字典:
		窗口字典[窗口名称]={}
	var 窗口数据:Dictionary = 窗口字典[窗口名称]
	if 修改==null:
		if 默认==null:#无修正逻辑
			return 窗口数据.get(条目,默认)
		var 原始返回值 = 窗口数据.get(条目, 默认)
		var 默认值类型 = typeof(默认)
		var 原始值类型 = typeof(原始返回值)
		if 原始值类型 != 默认值类型:
			return 默认
	else :
		窗口数据[条目]=修改
	return 窗口数据.get(条目,默认)

## 读取存档内数据,并限制值的范围(嵌套)
## 参数：基础参数与"窗口状态管理"一致
## 最大or最小（可选,默认值0和1）
## 规则：仅限制int/float/Vector2/Vector2i，超范围返回默认值；其他类型直接返回
func 窗口状态_限制(窗口名称, 条目, 默认, 最大=null, 最小=null):
	var 原始值 = 窗口状态管理(窗口名称, 条目, 默认)#窗口状态管理会保证存档值类型正确,否则使用默认值
	if 默认 is int:
		最小 = 最小 if 最小 is int else 0
		最大 = 最大 if 最大 is int else 1
	elif 默认 is float:
		最小 = 最小 if 最小 is float else 0.0
		最大 = 最大 if 最大 is float else 1.0
	elif 默认 is Vector2 or 默认 is Vector2i:
		if 默认 is Vector2:
			最小 = 最小 if 最小 is Vector2 else Vector2(0, 0)
			最大 = 最大 if 最大 is Vector2 else Vector2(1, 1)
		else :
			最小 = 最小 if 最小 is Vector2i else Vector2i(0, 0)
			最大 = 最大 if 最大 is Vector2i else Vector2i(1, 1)
		return Vector2(clamp(原始值.x, 最小.x, 最大.x), clamp(原始值.y, 最小.y, 最大.y))
	else:return 原始值
	return clamp(原始值, 最小, 最大)
#endregion 窗口功能
#region 原罪玩法
func 数据原罪(返回="熟练转移",项目="手工",修改=null):
	# 获取原罪数据的根字典（初始化代码已确保该层级存在）
	var 原罪数据=梅存档["挂机"]["原罪数据"]
	if not 原罪数据.has("种子"):原罪数据["种子"]=randi()
	var 原罪关系={"挂机":"傲慢","木料":"暴食","矿城":"贪婪","手工":"懒惰","游历":"暴怒","职业":"色欲","召唤":"嫉妒"}
	match 返回:#额外允许传入系统名称代指原罪名称,方便其他函数传入参数
		"原罪值","原罪上限":if 项目 in 原罪关系:项目=原罪关系[项目]
	match 返回:
		"暴食等级","暴食卡路里","暴食精通","暴食精通需求":
			return 原罪_暴食(返回,项目,修改)
		"熟练转移":
			if not 原罪数据.has(返回):原罪数据[返回]={}
			if 修改 is float and  修改>=0:# 修改逻辑：仅当修改为浮点数时覆盖，限制范围0~1
				原罪数据[返回][项目] = clamp(修改, 0.0, 1.0)
			return float(原罪数据[返回].get(项目, 0.0))
		"原罪值":
			if not 原罪数据.has(返回):原罪数据[返回]={}
			var 返回值=原罪数据[返回].get(项目, 0)
			if not (返回值 is float or 返回值 is int):
				返回值=0
			if 修改 is float or 修改 is int:# 修改逻辑：仅当修改为浮点或整数数时增加
				原罪数据[返回][项目] = clamp(float(修改+返回值),0,数据原罪("原罪上限",项目))
			return int(返回值)
		"原罪上限":
			var 额外:int=装备.安全访问(项目+"力")*10
			if 项目=="傲慢":额外+=int(steam.统计已完成成就数量()*50)
			if 项目=="贪婪":额外+=int(计划.数据原罪("原罪值","贪婪")*0.5)
			if not 原罪数据.has(返回):原罪数据[返回]={}
			if 修改 is float or 修改 is int:# 修改逻辑：仅当修改为浮点或整数数时增加
				原罪数据[返回][项目] = float(修改+原罪数据[返回].get(项目, 0))
			return int(1000+原罪数据[返回].get(项目, 0))+额外
		"突破":
			if not 原罪数据.has(返回):原罪数据[返回]=0
			return int(原罪数据[返回])
		"原罪力量":
			var 原罪值合计:=0.0
			var 倍率合计:=1.0
			var 倍率:=[]
			for 系统名称 in 原罪关系:
				var 原罪值=数据原罪("原罪值",原罪关系[系统名称])
				原罪值合计+=原罪值
				倍率+=[log(原罪值) / log(10)]
			for 倍数 in 倍率:
				if 倍数>0:倍率合计+=倍数*0.05
			return 原罪值合计*倍率合计
		"突破成功率":
			var 原罪力量:float=数据原罪("原罪力量")
			var 固定值={0:1000,1:2000,2:3500,3:5000}
			var 突破:int = 数据原罪("突破")
			if 突破<固定值.size():return clamp(原罪力量/固定值[突破], 0.0, 1.0)
			return 0.0
		"尝试突破":
			var 突破成功率:float=数据原罪("突破成功率")
			if 突破成功率<0.2:return"成功率至少20%"
			if 数据系统("挂机","等级")<(数据原罪("突破")*5+5):return"挂机等级需要先达到%d"%(数据原罪("突破")*5+5)
			if 数据系统("挂机","熟练")<结算升级("挂机",玩法枚举.无,"null",true):return"熟练度需要先达到上限"
			var 随机 = RandomNumberGenerator.new()
			if 原罪数据.has("种子"):随机.state = 原罪数据["种子"]
			else :随机.state=randi()#除非发生意外
			原罪数据["种子"]=随机.randi()#防止玩家进行SL
			if 突破成功率>=随机.randf():
				原罪数据["突破"] = int(原罪数据.get("突破", 0)+1)
				for 系统名 in 原罪关系:
					var 原罪力=装备.安全访问(原罪关系[系统名]+"力")
					var 保留比例:float=原罪力/(800+原罪力)
					var 当前值=原罪数据["原罪值"].get(原罪关系[系统名],0)
					原罪数据["原罪值"][原罪关系[系统名]]=(当前值*保留比例)
				计划.结算升级("挂机")#突破后等级上限增加了,进行升级检查
				计划.更新_UI.emit()
				return "成功"
			else :
				var 扣除值:int=int(梅存档["挂机"]["熟练"]*0.2)
				var 傲慢上限:int=int(100*(1+数据原罪("突破")))
				梅存档["挂机"]["熟练"]-=扣除值
				数据原罪("原罪上限","挂机",傲慢上限)
				计划.更新_UI.emit()
				return "失败,损失20%%熟练度共%d点,增加傲慢上限%d"%[扣除值,傲慢上限]
		_:
			print("数据:原罪打印了意外的结果\r传入数据:返回=",返回," 项目=",项目," 修改=",修改)
			breakpoint#不应该传入不合法的值
			return -1
var 缓存贪婪得分={}
func 更新贪婪总分()->int:
	var 总分:int=0
	for 参数 in 卡包配置.keys():
		if not 缓存贪婪得分.has(参数):
			计算卡包总得分(参数)
		总分+=缓存贪婪得分[参数]
	return 总分
func 计算卡包总得分(卡包名: String) -> int:
	# 1. 校验卡包是否存在
	var 卡包信息 = 计划.卡包配置.get(卡包名, null)
	if not 卡包信息:
		return 0
	var 单卡价值:float = 卡包信息.基础价值
	var 惩罚倍率:float = 卡包信息.惩罚倍率
	var 卡包总卡片数:int = 卡包信息.卡片列表.size()
	
	# 3. 核心数据获取
	var 卡片次数字典:Dictionary = 计划.原罪_贪婪(卡包名,"卡包字典")
	var 完成次数:int = 获取卡包最低提交次数(卡包名)  # 提交次数的最小值
	# 4. 计算「超过完成次数部分」的惩罚后总和
	var 超出部分:float = 0.0
	for 卡片 in 卡片次数字典:
		var 超过次数:float = max(0, 卡片次数字典[卡片] - 完成次数)  # 仅计算超过的部分（非负）
		if 超过次数 > 0:
			超出部分 += pow(超过次数, 1.0 / 惩罚倍率)
	# 5. 计算价值次数（按你的公式）
	var 价值次数 = 完成次数 * 卡包总卡片数 + 超出部分
	# 6. 计算卡包总价值（最终得分）
	var 卡包总价值:int = int(价值次数 * 单卡价值)
	缓存贪婪得分[卡包名]=卡包总价值
	return 卡包总价值
func 获取卡包最低提交次数(卡包名: String) -> int:
	var 卡片次数字典 = 计划.原罪_贪婪(卡包名,"卡包字典")
	if 卡片次数字典.is_empty():
		return 0
	# 提取所有次数值，取最小值
	var 次数列表:Array = []
	for 次数 in 卡片次数字典.values():
		次数列表.append(次数)
	return 次数列表.min()  # Godot内置min方法，保留英文
##内部方法,减少代码缩进层数
func 原罪_暴食(分支,项目,修改):
	var 原罪数据=梅存档["挂机"]["原罪数据"]
	var 返回="暴食里程碑"
	if not 原罪数据.has(返回):原罪数据[返回]={}
	if not 原罪数据[返回].has(项目):原罪数据[返回][项目]={}
	match 分支:
		"暴食等级":
			return float(原罪数据.get(返回, {}).get(项目, {}).get("等级", 0))
		"暴食卡路里":
			var 暴食里程碑=原罪数据.get(返回, {})
			var 卡路里上限=100
			for 项目名 in 暴食里程碑:
				if 暴食里程碑[项目名] is Dictionary and 暴食里程碑[项目名].has("等级"):
					卡路里上限+=int(10*暴食里程碑[项目名]["等级"])
			return 卡路里上限
		"暴食精通":
			if (修改 is float or 修改 is int) and not 修改==0:# 修改逻辑：仅当修改为浮点或整数数时增加
				原罪数据[返回][项目]["精通"] = 修改+原罪数据[返回][项目].get("精通", 0)
				结算升级("挂机",玩法枚举.暴食,项目)
			return float(原罪数据[返回][项目].get("精通", 0))
		"暴食精通需求":
			return 结算升级("挂机",玩法枚举.暴食,项目,true)
var 卡包配置: Dictionary = {}
func 更新收藏品卡包配置字典():
	var 收藏品类型={
		"符文":{
			"基础价值": 15.0,
			"惩罚倍率": 1.55,
			"循环奖励":[200,50,30,1000,"资源回复代币",1],
			"替换奖励":{5:["蓝图纸",360],10:["蓝图纸",540],15:["黄图纸",200],20:["蓝图纸",540],
			25:["蓝图纸",540],30:["蓝图纸",540],},},
		"灾厄":{
			"基础价值": 20.0,
			"惩罚倍率": 1.6,
			"循环奖励":[250,100,20,1000,"手工精通代币",2],#代币和奖励数量由里程碑代码直接解码
			"替换奖励":{5:["蓝图纸",360],10:["蓝图纸",540],15:["黄图纸",200],20:["蓝图纸",540],},},
		"颜料":{
			"基础价值": 20.0,
			"惩罚倍率": 1.5,
			"循环奖励":[100,25,30,800,"蓝图纸",20],
			"替换奖励":{5:["手工精通代币",5],10:["手工精通代币",5],15:["手工精通代币",5],20:["手工精通代币",5],
			25:["手工精通代币",5],30:["手工精通代币",5],35:["手工精通代币",5],40:["手工精通代币",5],}},
		"元素":{
			"基础价值": 18.0,
			"惩罚倍率": 1.65,
			"循环奖励":[200,90,20,800,"挂机精通代币",2],
			"替换奖励":{}},
		"失败品":{
			"基础价值": 10.0,
			"惩罚倍率": 1.5,
			"循环奖励":[120,80,20,800,"催化剂代币",2],
			"替换奖励":{}}
			}
	##返回物品名称数组:所物品都有收藏品标签
	var 收藏品=获取标签("收藏品")
	卡包配置={}
	for 藏品标签 in 收藏品类型:
		if 收藏品类型[藏品标签].has("循环奖励") and 收藏品类型[藏品标签].循环奖励.size()>=6:
			var 卡片列表=[]
			var 格式数组:Array[int]=[]
			var 循环奖励:Array=收藏品类型[藏品标签].循环奖励
			var 奖金需求=循环奖励[0]
			var 奖金增长=循环奖励[1]
			var 奖金数量=循环奖励[2]
			var 奖金上限=循环奖励[3]
			for i in range(奖金数量):
				if 奖金需求>奖金上限:奖金需求=奖金上限
				格式数组.append(奖金需求)
				奖金需求+=奖金增长
			for 物品名 in 收藏品:
				if 表格.蓝图标签检查(物品名,藏品标签):#检查物品是否有藏品标签,如果有则加入卡片列表
					卡片列表.append(物品名)
			卡包配置[藏品标签]=收藏品类型[藏品标签].duplicate()
			卡包配置[藏品标签].卡片列表=卡片列表
			卡包配置[藏品标签].奖金池=格式数组
	#print("卡包配置",卡包配置)
func 原罪_贪婪(名称,返回="卡片数量",增加=0):
	var 收藏:Dictionary=梅存档.挂机.收藏品
	if not 收藏.has("卡包"):
		收藏.卡包={}
	match 返回:
		"卡片数量":
			if not 收藏.卡包.has(名称):
				收藏.卡包[名称]=0
			if not 增加==0:
				收藏.卡包[名称]+=增加
			return int(收藏.卡包[名称])
		"卡包字典":
			var 卡包信息 = 卡包配置.get(名称, null)
			if not 卡包信息:return {}
			var 卡片次数字典: Dictionary = {}
			for 卡片 in 卡包信息.卡片列表:
				if 收藏.卡包.has(卡片):
					卡片次数字典[卡片] = int(收藏.卡包.get(卡片, null))
				else :
					卡片次数字典[卡片]=0
			return 卡片次数字典
		"领取记录":
			if not 收藏.has(返回) or not 收藏[返回] is Dictionary:
				收藏[返回]={}
			return 收藏[返回]
	return 0
#endregion 原罪玩法
#region 系统级API
##所有系统公共的方法(仅查看 不支持在此方法修改)
func 数据系统(系统="挂机",返回="等级"):
	if 梅存档.has(系统):
		match 返回:
			"精通上限":return 数据精通上限(系统)
			"阶级":return int(ceili(梅存档[系统].get("等级",-1) / 5.0))
			_:return int(梅存档[系统].get(返回,-1))
	breakpoint#不应该传入不合法的系统
	return null
func 数据精通上限(系统):
	var 等级=梅存档.get(系统,{}).get("等级",-1)
	var 精通力=int(装备.精通力*100)
	if 系统=="挂机":
		return 5000+等级*800+技能树.数据技能树(系统+"核心")+精通力
	if 等级==-1:
		return 10000
	return 10000+等级*1000+技能树.数据技能树(系统+"核心")+精通力
func 数据状态(值类型="生命值",默认值:int=0,覆盖:int=-1)->int:
	var 状态:Dictionary=梅存档["挂机"]["状态"]
	if 覆盖>=0:状态[值类型]=覆盖
	return 状态.get(值类型,默认值)
func 卡路里检查():
	var 状态:Dictionary=梅存档["挂机"]["状态"]
	if 状态.get("卡路里",0)>=1:
		状态["卡路里"]-=1
		卡路里收益("卡路里挂机")
		卡路里收益("卡路里手工")
	if 状态.get("贪婪",0)>=1:
		状态["贪婪"]-=1
func 卡路里收益(检查="卡路里手工"):
	var 状态:Dictionary=梅存档["挂机"]["状态"]
	if 状态.get(检查,0)<=0:
		状态[检查]=0
	状态[检查]+=1
	var 需求值=1
	if 检查=="卡路里手工":需求值=20
	elif 检查=="卡路里挂机":需求值=50
	if 状态[检查]>=需求值:
		var 获取量=int(状态[检查]/需求值)
		if 检查=="卡路里手工":
			手工.获得资源("精华",获取量)
			语法糖通知("精华+%d"%获取量)
		elif 检查=="卡路里挂机":
			获得体力(获取量)
			语法糖通知("体力+%d"%获取量)
		状态[检查]-=需求值*获取量
	
func 数据体力(返回="体力上限"):
	var 体力数据 = 梅存档["挂机"]["体力"]
	match 返回:
		"体力上限":
			return 体力数据.get("体力上限", 240)+int(数据原罪("暴食等级","挂机")*6)
		"体力":
			return 体力数据.get("体力值", 0)
		"门票数组":
			return 体力数据.get("门票",{}).keys()
#endregion 系统级API

#region 空白模板
#endregion 空白模板

func 显示后执行(需要执行方法:Callable,显示节点:CanvasItem):
	await get_tree().process_frame
	if not 显示节点:#如果节点不存在则退出,防止等待节点不存在
		return 
	if 显示节点.is_visible_in_tree():
		断开信号(显示节点.visibility_changed,显示后执行)
		需要执行方法.call()
	else :
		if not 显示节点.visibility_changed.is_connected(显示后执行):
			显示节点.visibility_changed.connect(显示后执行.bind(需要执行方法,显示节点))
func 断开信号(信号:Signal,方法:Callable):
	if 信号.is_connected(方法):
		信号.disconnect(方法)
