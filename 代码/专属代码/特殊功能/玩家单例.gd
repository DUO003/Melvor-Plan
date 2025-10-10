extends Node
class_name 玩家功能
@export_group("基础属性")
@export var 血量:int=100
@export var 攻击:int=10
@export var 魔法:int=0

@export_group("进阶属性")
@export var 回血:int=0
@export var 回蓝:int=0
@export var 闪避:int=0
@export var 暴击:int=0

var 减伤:float=0
var 攻速:float=2
var 攻击距离:int=50
var 装备来源属性:Array=[]
var 当前血量:int=血量

@export var 默认减伤:float=0
@export var 默认攻速:float=2
@export var 默认攻击距离:int=50
@export var 基础属性增长={"血量":15,"攻击":5,"魔法":10}

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
func 更新属性():
	var 游历等级=初始化.梅存档["游历"].get("等级",0)
	血量 = 100+int(游历等级*基础属性增长["血量"])
	攻击 = 10+int(游历等级*基础属性增长["攻击"])
	魔法 = int(游历等级*基础属性增长["魔法"])
	var 承受伤害比例 = 1.0 - (默认减伤 / 100.0)
	攻速=默认攻速
	攻击距离=默认攻击距离
	for 装备 in 装备来源属性:
		血量 += 装备.血量
		攻击 += 装备.攻击
		魔法 += 装备.魔法
		回血 += 装备.回血
		回蓝 += 装备.回蓝
		闪避 += 装备.闪避
		暴击 += 装备.暴击
		# 仅护甲分类装备处理减伤
		if 装备.分类 == "护甲" or 装备.has_method("定义减伤"):
			var 装备减伤 = clamp(装备.定义减伤(), 0, 100)
			承受伤害比例 *= (100.0 - 装备减伤) / 100.0
		if 装备.分类 == "武器":#合法情况下仅有一件武器直接设置
			攻速=装备.定义攻速()
			攻击距离=装备.定义攻击距离()
	减伤 = 1.0 - 承受伤害比例
func 战力文本更新():
	更新属性()
	return "血量:"+str(血量)+"				魔法:"+str(魔法)+"
攻击:"+str(攻击)+"	距离:"+str(int(攻击距离))+"/攻速"+str(攻速)+"秒
减伤:"+str(int(减伤*100))+"%"
