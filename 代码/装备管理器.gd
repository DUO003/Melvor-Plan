extends Node
class_name 梅装备
#region 挂机数据
var 装备单例:EquipmentSlotRepository
var 装备来源属性:Array[物品装备]=[]
var 精通力:float=0
var 傲慢力:float=0
var 暴食力:float=0
var 贪婪力:float=0
var 懒惰力:float=0
var 暴怒力:float=0
var 色欲力:float=0
var 嫉妒力:float=0
var 挂机默认={"精通力":5,"傲慢力":10,"暴食力":10,"贪婪力":10,"懒惰力":10,"暴怒力":10,"色欲力":10,"嫉妒力":10,}
var 挂机增长={"精通力":1,"傲慢力":5,"暴食力":5,"贪婪力":5,"懒惰力":5,"暴怒力":5,"色欲力":5,"嫉妒力":5,}
#endregion 挂机数据
#region 手工数据
var 制作力:float=0
var 研究力:float=0
var 炼金力:float=0
var 烹饪力:float=0
var 手工默认={"制作力":10,"研究力":10,"炼金力":10,"烹饪力":10}
var 手工增长={"制作力":5,"研究力":5,"炼金力":5,"烹饪力":5}
#endregion 手工数据
#region 游历数据
@export_group("基础属性")
var 血量:int=100
var 攻击:int=10
var 魔法:int=0
@export_group("进阶属性")
var 回血:int=0
var 回蓝:int=0
var 闪避:int=0
var 暴击:int=0
var 减伤:float=0
var 攻速:float=2
var 攻击距离:int=50
var 游历默认={"血量":100,"攻击":10,'魔法':0,"默认减伤":0,"默认攻速":2,"默认攻击距离":50}
var 游历增长={"血量":15,"攻击":5,"魔法":10}
#endregion 游历数据
func _ready() -> void:
	加载装备单例()
func 加载装备单例():
	if not 装备单例:
		装备单例=EquipmentSlotRepository.instance
func 打印属性():
	更新属性()
	print("装备后属性：")
	print("血量: ", 血量)
	print("攻击: ", 攻击)
	print("魔法: ", 魔法)
	print("回血: ", 回血)
	print("回蓝: ", 回蓝)
	print("闪避: ", 闪避)
	print("暴击: ", 暴击)
func 更新装备栏():
	装备来源属性=[]
	加载装备单例()
	for 槽位名称 in 装备单例._slot_data_map.keys():
		var 装备:物品装备 = 装备单例._slot_data_map[槽位名称].equipped_item
		if 装备:装备来源属性.append(装备)
func 获得装备槽宝石(名称,返回名称:bool=true)->Array:
	加载装备单例()
	var 装备槽:EquipmentSlotData=装备单例._slot_data_map.get(名称,null)
	if 装备槽:
		var 宝石数组:Array[物品宝石]=装备槽.装备栏宝石
		var 宝石名称:Array=[]
		if 返回名称:
			for 宝石 in 宝石数组:
				宝石名称.append(宝石.item_name)
			return 宝石名称
		else :return 宝石数组
	return []
func 更新属性(系统="游历"):
	更新装备栏()
	更新挂机数据()
	match 系统:
		"手工":更新手工数据()
		"游历":更新游历数据()
func 更新挂机数据():
	精通力 = 0
	懒惰力 = 0
func 更新手工数据():
	var 等级:int=max(0,计划.数据系统("手工"))
	制作力 = 手工默认.制作力+等级*手工增长.get("制作力",0)
	研究力 = 手工默认.研究力+等级*手工增长.get("研究力",0)
	炼金力 = 手工默认.炼金力+等级*手工增长.get("炼金力",0)
	烹饪力 = 手工默认.烹饪力+等级*手工增长.get("烹饪力",0)
func 更新游历数据():
	var 等级:int=max(0,计划.数据系统("游历"))
	血量 = 游历默认.血量+int(等级*游历增长.血量)
	攻击 = 游历默认.攻击+int(等级*游历增长.攻击)
	魔法 = 游历默认.魔法+int(等级*游历增长.魔法)
	攻速=游历默认.默认攻速
	攻击距离=游历默认.默认攻击距离
	var 承受伤害比例 = 1.0 - (游历默认.默认减伤 / 1.0)
	for 装备 in 装备来源属性:
		if 装备.分类 == "武器" and 装备.通用检查("攻速") and 装备.通用检查("攻击距离"):#合法情况下仅有一件武器直接设置
			攻速=游历默认.默认攻速*装备.基础数值[装备.类型].攻速
			攻击距离=int(游历默认.默认攻速*装备.基础数值[装备.类型].攻击距离)
		elif 装备.分类 == "护甲" and 装备.通用检查("减伤"):
			var 装备减伤 = clamp(装备.基础数值[装备.类型].减伤, 0.0, 1.0)
			承受伤害比例 *= (1.0 - 装备减伤) / 1.0
	减伤 = min(0.8,1.0 - 承受伤害比例)
func 战力文本更新(系统="游历") -> Array:
	更新属性(系统)
	var 等级:int = 计划.数据系统(系统)
	var 文本数组:Array = []
	文本数组.append("%s等级:%d" % [系统, 等级])
	文本数组.append("精通力:%.0f" % [精通力])
	match 系统:
		"手工":
			文本数组.append("懒惰力:%.0f" % [懒惰力])
			文本数组.append("制作力:%.0f" % [制作力])
			文本数组.append("研究力:%.0f" % [研究力])
			文本数组.append("炼金力:%.0f" % [炼金力])
			文本数组.append("烹饪力:%.0f" % [烹饪力])
		"游历":
			文本数组.append("血量:%d" % [血量])
			文本数组.append("魔法:%d" % [魔法])
			文本数组.append("攻击:%d" % [攻击])
			文本数组.append("距离%.0f" % [攻击距离])
			文本数组.append("攻速:%.1f秒" % [攻速])
			文本数组.append("减伤:%.0f%%" % [减伤*100])
		_:pass
	return 文本数组
