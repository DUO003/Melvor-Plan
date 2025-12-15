extends Resource
class_name 梅BUFF数据
#region 持久化
## BUFF唯一ID，全局不可重复，用于管理器索引和存档关联
@export var BUFF名称: String = "默认BUFF"
## 标准,临时BUFF有时效性,临时BUFF存档后会删除,永久BUFF为条件触发移除["标准", "临时", "永久"]
@export var BUFF类型: String = "标准"
## BUFF创建时间戳（秒）记录生效起始时间，离线时计算持续时长
@export var 创建时间戳: float = -1.0
## BUFF持续时长（秒），-1表示永久或计触发次数 控制生效周期
@export var 持续时长: float = -1.0
## BUFF剩余触发次数，-1表示不限制或计时 控制生效周期
@export var 剩余次数: int = -1
## 最后一次同步时间戳
## 设计目的：记录离线前最后校验时间，计算离线期间状态变化
@export var 同步时间: float = 0
## BUFF离线时否暂停计时,这个标签在BUFF载入时决定是否重新根据剩余时间生成新BUFF
@export var 离线暂停: bool = false
## 设计目的：允许每层BUFF单独携带一个强度修改值,BUFF层数不能单独过期
@export var 强度: Array = []
## BUFF来源,一段用于dbug的文本,描述被谁加入到buff队列中的
@export var 来源: String = ""
#endregion 持久化
#region 缓存
## BUFF显示名称，用于UI展示，多语言扩展空间
var 名称显示: String = BUFF名称
## 统一管理多维度基础属性，适配不同类型BUFF,不能直接读,需要根据叠加方式和层数使用方法获取.
var 效果数值: Dictionary = {}
## 相同BUFF的计算规则["加法", "乘法", "取最大值", "取最小值"]
var 叠加方式: String = "加法"
## 最大叠加层数，1表示不可叠加,-1不限制
var 最大层数: int = 1
## 设计目的：区分生效方式["被动", "间隔"]
var 触发类型: String = "被动"
## 角色脱战,或死亡时清空这个BUFF
var 脱战清空: bool = false
## 设计目的：控制间隔触发型BUFF的触发频率,添加计时器被设置,修改此值不能修改计时器
var 触发间隔: float = -1
## 用于BUFF图标显示
var 贴图名称: String
#region 计时器
## 如果为间隔则保存计时器,实际位于BUFF管理器节点下此处保存引用
var 间隔计时器: Timer
## 如果为计时BUFF则保存计时器,实际位于BUFF管理器节点下此处保存引用
var 移除计时器: Timer
func 删除计时器():
	var 计时器数组=[间隔计时器,移除计时器]
	for 计时器 in 计时器数组:
		if is_instance_valid(计时器) :
			if 计时器 is Timer:
				计时器.stop()
				计时器.queue_free()
#endregion 计时器
#endregion 缓存
#region 只读
## 剩余持续时间(只读)(秒)，检查时更新还有多久(整数)
var 剩余持续时间: float:
	get:
		if 持续时长==-1.0:return -1#持续时间为-1时表示无限
		else :
			var 剩余时间 = 持续时长 - (Time.get_unix_time_from_system() - 创建时间戳)
			return max(0.0, 剩余时间)
##用于哈希校验强度数组可能的数据结构示意[1.0...]
var 文件哈希:int:
	get:return hash(强度)
## 设计目的：统计强度数组长度
var 层数: int:
	get:return 强度.size()
#endregion 只读
#region 内置方法
func 删除BUFF():
	删除计时器()
##核心方法：根据统计类型计算并累加效果到传入的字典[br]
##参数说明：统计类型: 要检查的效果类型（如"资源回复"）
##目标字典:用于累加结果的字典（引用）
func 获取效果(统计类型: String, 目标字典: Dictionary) -> void:
	if not 效果数值.has(统计类型):return# 边界检查：无对应效果类型时直接返回
	var 强度合计: float = 计算强度合计()# 1. 计算强度合计值
	if 强度合计 == 0.0:return
	var 效果子字典: Dictionary = 效果数值[统计类型]# 2. 获取当前统计类型的效果字典（如{"木头":1}）
	if not 效果子字典:return
	for 属性名: String in 效果子字典:# 3. 遍历效果项，累加到目标字典
		var 基础值: float = float(效果子字典[属性名])
		var 最终增量: float = 基础值 * 强度合计
		if 目标字典.has(属性名):# 累加/初始化目标字典的值
			目标字典[属性名] += 最终增量
		else:目标字典[属性名] = 最终增量
	if not 目标字典.has("哈希"):目标字典["哈希"]=[]
	if not 目标字典.has("BUFF来源"):目标字典["BUFF来源"]=[]
	目标字典["哈希"].append(文件哈希)
	目标字典["BUFF来源"].append(self)
## 内部方法：根据叠加方式计算所有层数的强度合计
func 计算强度合计() -> float:
	if 层数 <= 0 or 强度.size() == 0:# 处理层数为0或强度数组为空的情况
		return 0.0
	match 叠加方式:# 根据叠加方式计算合计
		"加法":return 强度.reduce(func(元素:float, 值:float): return float(元素 + 值), 0.0)
		"乘法":return 强度.reduce(func(元素:float, 值:float): return float(元素 * 值), 1.0)
		"取最大值":return 强度.max()
		"取最小值":return 强度.min()
		_:
			push_warning("未知的叠加方式：%s，返回0" % 叠加方式)
			return 0.0#错误
#endregion 内置方法
