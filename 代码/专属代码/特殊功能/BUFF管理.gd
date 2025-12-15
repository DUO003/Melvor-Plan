extends Node
class_name 梅BUFF  # 游戏名称关联的类名
## 核心存储：当前所有生效的BUFF实例（梅BUFF存档版本）
var 所有BUFF: Array[梅BUFF数据] = []
## 已名称为键存储(不存档)运行时生效,与所有BUFF内数据一致
var BUFF字典:Dictionary[String,梅BUFF数据]={}
signal 更新_BUFF()
#region BUFF的方法
var BUFF方法字典: Dictionary = {#[匿名方法,创建时调用,层数增加时调用]
	"以太药水": 
		{"触发":func(_BUFF: 梅BUFF数据):BUFF_资源回复.emit(),
		"移除":func(_BUFF: 梅BUFF数据):BUFF_资源回复.emit()},
	"测试":{"间隔":空方法},
}
func 方法检查(BUFF名称,类型):
	if BUFF方法字典.has(BUFF名称) and BUFF方法字典[BUFF名称].has(类型):
		return BUFF方法字典[BUFF名称][类型]
	return false
##手工系统点击资源回复受到BUFF影响时发出(开始和结束)
signal BUFF_资源回复()
##打印测试结果,并检查过期
func 空方法(BUFF: 梅BUFF数据):
	print("[间隔触发] 测试方法执行 | BUFF：", BUFF.BUFF名称, "| 层数：", BUFF.层数)
#endregion BUFF的方法
#region 初始化
## 外部调用的初始化检查方法（仅初始化时调用一次）
## 核心逻辑：读存档 → 删临时BUFF → 重建离线暂停的有效BUFF
func 初始化BUFF():
	var 存档BUFF数组: Array = []#安全读取存档中的BUFF数组
	if  "BUFF" in 计划.梅存档["挂机"]:
		存档BUFF数组 = 计划.梅存档["挂机"]["BUFF"]
	else:
		所有BUFF = []
		return
	存档BUFF数组 = _过滤临时类型BUFF(存档BUFF数组)#过滤并删除所有"临时"类型的BUFF
	存档BUFF数组 = _重建离线暂停BUFF(存档BUFF数组)#处理离线暂停的BUFF
	for BUFF in 存档BUFF数组:
		if BUFF is 梅BUFF数据:
			为buff赋值配置(BUFF,获取buff配置(BUFF.BUFF名称))
			所有BUFF+=[BUFF]
	所有BUFF=存档BUFF数组
	BUFF字典.clear()#注册字典#跳过空名称的异常BUFF
	for buff实例 in 所有BUFF:
		if buff实例.BUFF名称:BUFF字典[buff实例.BUFF名称] = buff实例
	重建所有间隔BUFF计时器()
	计划.梅存档["挂机"]["BUFF"]=存档BUFF数组
	更新_BUFF.emit()
	#print(BUFF字典.keys())
	#for BUFF in 所有BUFF:
		#print(BUFF)
func 重建所有间隔BUFF计时器():
	for 目标BUFF in 所有BUFF:
		创建计时器(目标BUFF)
func 创建计时器(目标BUFF:梅BUFF数据):
	if 目标BUFF.间隔计时器==null and 目标BUFF.触发类型 == "间隔" and 目标BUFF.触发间隔 > 0:
		var 计时器选项: Dictionary = {
				"是否循环": true,# 间隔BUFF默认循环触发
				"回传计时器": false,# 无需回传计时器实例
				"错峰计算": false,# 不保留错峰计算逻辑
				"挂载位置": self}#传入管理器节点
		var 间隔回调方法:Callable=func():空方法(目标BUFF)#这个逻辑仅打印
		var 间隔方法=方法检查(目标BUFF.BUFF名称,"间隔")
		if 间隔方法 is Callable:
			间隔回调方法=func():间隔方法.call(目标BUFF)
		var 间隔计时器: Timer = 计划.创建计时器(目标BUFF.触发间隔,间隔回调方法,计时器选项)
		目标BUFF.间隔计时器 = 间隔计时器
	if 目标BUFF.移除计时器==null and not 目标BUFF.剩余持续时间==-1:
		创建移除计时器(目标BUFF)
func 创建移除计时器(目标BUFF:梅BUFF数据):
	if 目标BUFF.剩余持续时间>0:
		var 计时器选项: Dictionary = {
			"是否循环": false,# 间隔BUFF默认循环触发
			"回传计时器": false,# 无需回传计时器实例
			"错峰计算": false,# 不保留错峰计算逻辑
			"挂载位置": self}#传入管理器节点
		var 移除回调方法:Callable=func():
			if not 检查BUFF过期(目标BUFF):#移除失败表示BUFF被延长了
				目标BUFF.移除计时器.stop()
				目标BUFF.移除计时器.queue_free()
				创建移除计时器(目标BUFF)#下一个时间继续
		var 移除计时器: Timer = 计划.创建计时器(目标BUFF.剩余持续时间,移除回调方法,计时器选项)
		目标BUFF.移除计时器 = 移除计时器
		
## 辅助方法：过滤临时类型BUFF（返回非临时的有效BUFF）
func _过滤临时类型BUFF(原始存档数组: Array) -> Array[梅BUFF数据]:
	var 过滤后数组: Array[梅BUFF数据] = []
	for buff in 原始存档数组:
		if buff is 梅BUFF数据:#仅处理梅BUFF数据类型
			if buff.BUFF类型 != "临时":过滤后数组.append(buff)
		else:print("跳过非梅BUFF数据的无效存档项：", buff)
	return 过滤后数组
## 辅助方法：重建离线暂停的BUFF（核心逻辑）
func _重建离线暂停BUFF(过滤后数组: Array[梅BUFF数据]) -> Array[梅BUFF数据]:
	var 最终有效数组: Array[梅BUFF数据] = []
	var 当前系统时间戳: float = Time.get_unix_time_from_system()  # 当前秒级时间戳
	for 原BUFF in 过滤后数组:
		if not 原BUFF.离线暂停:# 非离线暂停的BUFF：直接检查是否过期，有效则保留
			if _检查BUFF是否过期(原BUFF, 当前系统时间戳):
				最终有效数组.append(原BUFF)
			else:print("BUFF已过期：", 原BUFF.BUFF名称)
			continue
		elif 原BUFF.持续时长 == -1.0:# 永久BUFF（持续时长=-1）直接保留
			最终有效数组.append(原BUFF)
			continue
		var 离线前已消耗时间: float = 原BUFF.同步时间 - 原BUFF.创建时间戳# 处理「离线暂停」类型的BUFF
		var 离线前剩余时间: float = 原BUFF.持续时长 - 离线前已消耗时间
		if 离线前剩余时间 <= 0:# 剩余时间≤0 → 过期，放弃重建
			print("离线暂停BUFF已过期（剩余时间≤0），放弃：", 原BUFF.BUFF名称)
			continue
		var 新BUFF: 梅BUFF数据 = _复制并重建BUFF(原BUFF, 离线前剩余时间, 当前系统时间戳)# 剩余时间>0 → 重建BUFF
		最终有效数组.append(新BUFF)
	return 最终有效数组
## 辅助方法：检查普通BUFF（非离线暂停）是否过期
func _检查BUFF是否过期(目标BUFF: 梅BUFF数据, 当前时间戳: float) -> bool:
	if 目标BUFF.持续时长 == -1.0:# 永久BUFF（持续时长=-1）永远不过期
		return true
	var 已消耗时间: float = 当前时间戳 - 目标BUFF.创建时间戳# 计算当前剩余时间
	var 剩余时间: float = 目标BUFF.持续时长 - 已消耗时间
	return 剩余时间 > 0  # 剩余时间>0则有效
## 辅助方法：复制原BUFF并重建离线暂停的有效BUFF
func _复制并重建BUFF(原BUFF: 梅BUFF数据, 离线前剩余时间: float, 当前时间戳: float) -> 梅BUFF数据:
	var 新BUFF: 梅BUFF数据 = 原BUFF.duplicate(true)
	新BUFF.创建时间戳 = 当前时间戳
	新BUFF.持续时长 = 离线前剩余时间
	新BUFF.同步时间 = 当前时间戳
	return 新BUFF
#endregion 初始化
#region 创建或移除BUFF
## 保存BUFF基础数据
var BUFF继承字典: Dictionary = {
	"计时": {# 示例1：计时型
		"生效类型": "计时",# 计时/计数/无（决定生效周期逻辑）
		"BUFF类型": "标准",# 临时/标准/永久（存档/移除规则）
		"持续时长": 1.0,# 计时类型默认持续时间（秒）
		"剩余次数": -1,# 计数类型默认触发次数（-1无限制）
		"修改方式": "覆盖",# 可选：覆盖/叠加/不变（计时/计数的时间/次数更新规则）
		"层数上限": 1,# 最大叠加层数（-1无限制）
		"叠加方式": "加法",# 加法/乘法/替换
		"触发类型": "被动",# 被动/主动/条件
		"脱战清空": false,# 是否脱战后清空
		"触发间隔": -1,# 触发间隔（秒）（-1不触发）
		"离线暂停": false,# 是否离线时暂停计时/计数
		"贴图名称":"沙漏",
		"效果数值":{}},
	"计数": {# 示例2：计数型
		"生效类型": "计数",
		"BUFF类型": "标准",
		"持续时长": -1,
		"剩余次数": 1,
		"修改方式": "叠加",
		"层数上限": 1,
		"叠加方式": "加法",
		"触发类型": "被动",
		"脱战清空": false,
		"触发间隔": -1,
		"离线暂停": false,
		"贴图名称":"爱心",
		"效果数值":{}},
	"永久": {# 示例3：永久型BUFF
		"生效类型": "无",
		"BUFF类型": "永久",
		"持续时长": -1,
		"剩余次数": -1,
		"修改方式": "不变",
		"层数上限": 1,
		"叠加方式": "加法",
		"触发类型": "被动",
		"脱战清空": false,
		"触发间隔": -1,
		"离线暂停": false,
		"贴图名称":"箭头",
		"效果数值":{}}}
## BUFF基础配置字典{键：BUFF名称 | 值：继承类型+差异}
var BUFF配置字典: Dictionary = {
	"测试": {"继承":"计时","持续时长": 3.5,"触发类型": "间隔","触发间隔": 1},
	"以太药水": {"继承":"计时","持续时长": 300.5,"贴图名称":"魔药","层数上限": 3,
		"效果数值":{"资源回复":{"木材":1,"矿石":1,"皮革":1,"药草":1}}},
	}#以太药水
## 外部调用的BUFF创建方法
## 参数说明：
##   BUFF名称: 要创建的BUFF名称（必须在配置字典中存在）
##   来源: BUFF来源备注
##   强度: 该层BUFF的强度值
##   持续时间修正: 自定义时长/次数
## 返回值: 创建/叠加成功返回true，失败返回false
func 创建BUFF(BUFF名称: String,来源: String,强度: Variant = 1.0,持续时间修正: float = -1.0) -> bool:
	if not BUFF配置字典.has(BUFF名称):# 1. 校验：配置字典中是否存在该BUFF
		print("BUFF创建失败：配置字典中不存在【%s】" % BUFF名称)
		return false
	var buff配置:Dictionary = 获取buff配置(BUFF名称)
	if not buff配置:return false#如果为空
	var 层数上限 = buff配置["层数上限"]
	if BUFF字典.has(BUFF名称):# 3. 检查是否已存在该BUFF实例
		var 现有BUFF = BUFF字典[BUFF名称]# 3.1 存在：校验层数上限
		if 现有BUFF.层数 + 1 > 层数上限 and 层数上限 != -1:
			print("BUFF创建失败：【%s】已达最大层数(%d)" % [BUFF名称, 层数上限])
			return false
		现有BUFF.强度.append(强度)
		现有BUFF.来源 = 来源
		处理BUFF时间次数更新(现有BUFF, buff配置, 持续时间修正)
		更新_BUFF.emit()
		return true
	else:#创建新的BUFF实例
		var 目标BUFF = 梅BUFF数据.new()
		目标BUFF.BUFF名称 = BUFF名称#基础属性初始化
		目标BUFF.来源 = 来源
		目标BUFF.强度 = [强度]  # 第一层强度存入数组
		目标BUFF.创建时间戳 = Time.get_unix_time_from_system()  # 赋值创建时间
		目标BUFF.同步时间 = 目标BUFF.创建时间戳
		目标BUFF.BUFF类型 = buff配置["BUFF类型"]  # 直接读取配置的BUFF类型（无映射）
		var 生效类型 = buff配置["生效类型"]# 4.2 根据生效类型初始化时间/次数属性
		match 生效类型:
			"计时":# 计时类型：使用持续时长，剩余次数-1
				var 最终持续时长 = 持续时间修正 if 持续时间修正 != -1 else buff配置["持续时长"]
				目标BUFF.持续时长 = 最终持续时长
				目标BUFF.剩余次数 = -1
			"计数":# 计数类型：使用剩余次数，持续时长-1
				var 最终剩余次数 = int(持续时间修正) if 持续时间修正 != -1 else buff配置["剩余次数"]
				目标BUFF.剩余次数 = 最终剩余次数
				目标BUFF.持续时长 = -1
			_:# 永久型BUFF：时间/次数均为-1
				目标BUFF.持续时长 = -1
				目标BUFF.剩余次数 = -1
		目标BUFF.离线暂停 = buff配置["离线暂停"]
		目标BUFF.名称显示 = BUFF名称
		为buff赋值配置(目标BUFF,buff配置)
		if 目标BUFF.触发类型=="间隔":
			创建计时器(目标BUFF)
		所有BUFF.append(目标BUFF)#加入存储
		BUFF字典[BUFF名称] = 目标BUFF
		var 方法=方法检查(目标BUFF.BUFF名称,"触发")
		if 方法 is Callable:方法.call(目标BUFF)
		print("BUFF创建成功：【%s】，层数：1，类型：%s，生效类型：%s"%[BUFF名称, 目标BUFF.BUFF类型, 生效类型])
		更新_BUFF.emit()
		return true
func 获取buff配置(BUFF名称:String)->Dictionary:
	var 自定义配置 = BUFF配置字典[BUFF名称]# 2. 合并继承配置 + 自定义差异配置
	if not BUFF继承字典.has(自定义配置["继承"]):# 校验继承类型是否存在
		print("BUFF创建失败：【%s】的继承类型【%s】不存在" % [BUFF名称, 自定义配置["继承"]])
		return {}
	var buff配置 = BUFF继承字典[自定义配置["继承"]].duplicate(true)# 深拷贝继承模板
	for 键 in 自定义配置:# 用自定义配置覆盖继承模板的字段
		if 键 != "继承": # 跳过"继承"关键字，仅覆盖业务字段
			buff配置[键] = 自定义配置[键]
	return buff配置
func 为buff赋值配置(BUFF:梅BUFF数据,buff配置:Dictionary):
	BUFF.最大层数 = buff配置["层数上限"]  # 设置最大叠加层数
	BUFF.叠加方式 = buff配置["叠加方式"]
	BUFF.触发类型 = buff配置["触发类型"]
	BUFF.脱战清空 = buff配置["脱战清空"]
	BUFF.触发间隔 = buff配置["触发间隔"]
	BUFF.效果数值 = buff配置["效果数值"].duplicate(true)
	BUFF.贴图名称 = buff配置["贴图名称"]
## 内部辅助方法：处理已有BUFF的时间/次数更新逻辑
func 处理BUFF时间次数更新(现有BUFF: 梅BUFF数据, buff配置: Dictionary, 持续时间修正: float) -> void:
	var 生效类型 = buff配置["生效类型"]
	var 修改方式 = buff配置["修改方式"]
	var 当前时间戳 = Time.get_unix_time_from_system()
	现有BUFF.同步时间=当前时间戳
	if buff配置["BUFF类型"] == "永久":
		return
	match 生效类型:
		"计时":# 计时类型：处理持续时长
			var 目标持续时长 = 持续时间修正 if 持续时间修正 != -1 else buff配置["持续时长"]
			var 原剩余时间 = 现有BUFF.剩余持续时间
			match 修改方式:
				"覆盖":# 覆盖：刷新创建时间戳，重置剩余时间
					现有BUFF.创建时间戳 = 当前时间戳
					现有BUFF.持续时长 = 目标持续时长
				"叠加":现有BUFF.持续时长 = 原剩余时间 + 目标持续时长# 叠加：增加持续时长
				"不变":pass# 不变：不修改时间相关属性
		"计数":# 计数类型：处理剩余次数
			var 目标剩余次数 = int(持续时间修正) if 持续时间修正 != -1 else buff配置["剩余次数"]
			match 修改方式:
				"覆盖":现有BUFF.剩余次数 = 目标剩余次数# 覆盖：直接重置剩余次数
				"叠加":现有BUFF.剩余次数 += 目标剩余次数# 叠加：增加剩余次数
				_:pass# 不变：不修改次数相关属性
##移除BUFF
func 移除BUFF(BUFF名称: String, 移除层数: int = 1) -> bool:
	if not BUFF字典.has(BUFF名称):
		return false
	var 目标BUFF = BUFF字典[BUFF名称]
	for i in range(移除层数):# 移除对应层数的强度值（从末尾移除，因为新层追加在末尾）
		if 目标BUFF.强度.size() > 0:
			目标BUFF.强度.pop_back()
	if 目标BUFF.层数 <= 0:# 层数为0时彻底移除
		目标BUFF.删除BUFF()#停止计时器如果有
		所有BUFF.erase(目标BUFF)
		BUFF字典.erase(BUFF名称)
		var 方法=方法检查(目标BUFF.BUFF名称,"移除")
		if 方法 is Callable:方法.call(目标BUFF)
		print("BUFF已彻底移除：【%s】" % BUFF名称)
		更新_BUFF.emit()
		return true
	else:
		print("BUFF层数减少：【%s】，剩余层数：%d" % [BUFF名称, 目标BUFF.层数])
		更新_BUFF.emit()
		return true
##手动移除BUFF
func 手动移除BUFF(BUFF名称: String) -> bool:
	if not BUFF字典.has(BUFF名称):
		return false
	var 目标BUFF:梅BUFF数据 = BUFF字典[BUFF名称]
	移除BUFF(BUFF名称,目标BUFF.层数)
	return true
##定时检查BUFF过期
func 检查BUFF() -> void:
	for BUFF实例 in 所有BUFF:
		检查BUFF过期(BUFF实例)
##定时检查BUFF过期
func 检查BUFF过期(BUFF实例:梅BUFF数据) -> bool:
	var 当前时间=Time.get_unix_time_from_system()
	BUFF实例.同步时间=当前时间
	if BUFF实例.剩余持续时间 > 0.0:# 计时型BUFF,保留条件
		return false
	elif BUFF实例.剩余次数 > 0:# 计数型BUFF,保留条件
		return false
	elif BUFF实例.BUFF类型 == "永久":#如果前两个条件都不使用的BUFF生效只能用永久
		return false
	移除BUFF(BUFF实例.BUFF名称, BUFF实例.层数)
	#print(BUFF实例.BUFF名称,"剩余持续时间:",BUFF实例.剩余持续时间)
	return true
#endregion 创建或移除BUFF
var BUFF缓存:Dictionary[String,Dictionary]={}
func BUFF统计(统计类型="资源回复"):
	if BUFF缓存.has(统计类型):
		var 当前字典:Dictionary = BUFF缓存[统计类型]
		if 校验缓存有效性(当前字典):
			return 当前字典.duplicate(true)  # 缓存有效直接返回
	var 字典:Dictionary={}
	for BUFF in 所有BUFF:
		BUFF.获取效果(统计类型,字典)
	BUFF缓存[统计类型]=字典
	return 字典.duplicate(true)
# 缓存有效性校验函数（解耦核心逻辑，保留原命名）
func 校验缓存有效性(缓存字典: Dictionary) -> bool:
	if not (缓存字典.has("BUFF来源") and 缓存字典.has("哈希")):
		return false
	var BUFF来源列表 = 缓存字典["BUFF来源"]
	var 哈希列表 = 缓存字典["哈希"]
	if not (BUFF来源列表 is Array and 哈希列表 is Array and BUFF来源列表.size() == 哈希列表.size()):
		return false
	for 索引 in BUFF来源列表.size():
		var 当前BUFF = BUFF来源列表[索引]
		var 缓存哈希 = 哈希列表[索引]
		if not (当前BUFF is 梅BUFF数据 and 当前BUFF.文件哈希 == 缓存哈希):
			return false
	return true# 所有校验通过，缓存有效
