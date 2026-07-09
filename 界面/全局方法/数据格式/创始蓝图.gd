extends Resource
class_name 梅创始蓝图
var 名称: String = ""
var 阶级: int = 0
var 价值: int = 0
var 名称_EN: String = ""
var 简介: String = ""
var 简介_EN: String = ""
var 标签: String = ""
var 分类: String = ""
var 类型: String = ""
var 职业: String = ""
var 图纸集: String = ""
var icon: Texture2D = null
var 堆叠: int = 0
var 矿石: float = 0.0
var 木材: float = 0.0
var 皮革: float = 0.0
var 药草: float = 0.0
var 零件: float = 0.0
var 精华: float = 0.0
var 冷却: float = 0.0
var 属性: Dictionary = {}
## 构造函数
func _init(表头数组: Array,类型数组: Array,数据数组: Array) -> void:
	# 数组长度不一致 → 直接报错
	if 表头数组.size() != 数据数组.size():
		print("【梅创始蓝图】初始化失败：表头数量与数据数量不一致！")
		return
	# 遍历赋值
	for 索引 in range(表头数组.size()):
		var 当前表头: String = 表头数组[索引]
		var 当前类型: String = 类型数组[索引]
		var 当前数据: String = 数据数组[索引]
		# 转换并赋值
		转换并赋值(当前表头,当前类型,当前数据)
# 类型转换 + 赋值
func 转换并赋值(成员名称: String,成员类型:String,数据文本: String) -> void:
	var 成员新值:Variant
	match 成员类型:
		"文本":#TYPE_STRING:# 字符串
			成员新值=数据文本
		"整数":#TYPE_INT:# 整数
			if 数据文本.is_valid_int():
				成员新值=int(数据文本)
			else :
				成员新值=0
		"浮点":#TYPE_FLOAT:# 浮点数
			if 数据文本.is_valid_float():
				成员新值=float(数据文本)
			else :
				成员新值=0
		"字典":#TYPE_DICTIONARY:# 字典
			成员新值=解析JSON_字典(数据文本)
		"图片":#TYPE_OBJECT:# 图片
			成员新值=解析图片(数据文本)
		_:
			print("【%s】不支持的变量类型：%s:"%[成员名称, 成员类型],get(成员名称))
			return
	set(成员名称, 成员新值)
func 解析JSON_字典(解析文本:String="")->Dictionary:
	var 字典:={}
	if 解析文本=="":
		return 字典
	var json:JSON = JSON.new()
	var 解析:Error  = json.parse(解析文本)
	if 解析 == OK and json.data is Dictionary:
		字典 = json.data
	else :
		print("错误,解析错误",解析文本)
	return 字典
func 解析图片(贴图路径:String)->Texture2D:
	var 贴图:Texture2D=load(贴图路径)
	if 贴图:
		return 贴图
	return preload("res://素材/自制/图标/未知图片.png")
