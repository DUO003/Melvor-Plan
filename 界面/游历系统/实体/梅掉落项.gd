extends Resource
class_name 梅掉落项

# 物品配置
@export var 物品名称: String = ""
@export var 掉落概率: float = 1.0  # 数值越大越容易掉
@export var 最小数量: int = 1
@export var 最大数量: int = 1
@export var 添加冲突词条: Array[String]=[]
@export var 冲突词条: String=""
# 物品类型（对应你的语法糖）
@export var 物品类型: String = "标准物品"
@export var 自定义参数: Dictionary = {}

func 检查配置是否合法() -> bool:
	# 允许的物品类型（严格按你给的例子）
	var 允许类型 = [
		"标准物品",
		"装备物品",
		"物品宝石",
		"物品方块",
		"点数"]
	#检查物品名称不能为空
	if 物品名称 == "":
		push_error("【梅掉落项】配置错误：物品名称不能为空！")
		return false
	elif not 计划.表格.蓝图字典.has(物品名称):
		push_error("【梅掉落项】配置错误：<%s>物品可能不存在"%物品名称)
		return false
	#数量不能为负数
	if 最小数量 < 0:
		push_error("【梅掉落项】配置错误：最小数量不能为负数 → " + 物品名称)
		return false
	if 最大数量 < 0:
		push_error("【梅掉落项】配置错误：最大数量不能为负数 → " + 物品名称)
		return false

	#物品类型必须是允许的类型
	if not 允许类型.has(物品类型):
		push_error("【梅掉落项】配置错误：物品类型不合法 → " + 物品名称 + " 类型:" + 物品类型)
		return false

	# 所有检查通过
	return true
