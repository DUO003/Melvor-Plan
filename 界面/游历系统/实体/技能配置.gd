extends Resource
class_name 梅技能配置
##技能名称需要对应动画文件
@export var 技能名称: String = ""
##技能的物品简介
@export var 技能描述: String = ""
## 1.主动 2.被动##预留
@export var 技能类型: String="主动"
## 1.近战攻击 2.远程攻击
@export var 子弹类型: String="近战攻击"
##玩家从游历数据获取,怪物由怪物的强度决定
@export var 技能等级: int = 1
##每级增加的强度值,默认0.01
@export var 每级强度加成: float = 0.01
##倍率,技能伤害等于攻击力*强度值
@export var 强度值: float = 1.0
##技能栏显示图片
@export var 技能图标: Texture2D = null
##倍率 对于实体本身最大距离的倍率
@export var 飞行倍率: float = 1.0
##每秒飞行距离的倍率
@export var 弹道速度倍率: float = 1.0
##默认无,在播放动画前的准备时间不包括动画部分,单位秒
@export var 吟唱时间: float = 0.0
##技能释放完成后冷却长度,从技能释放结束计算,单位秒
@export var 冷却时间: float = 1.0
##技能需要消耗多少蓝
@export var 魔法消耗: float = 0.0
##如果有多个技能同时可以释放,AI会选择的依据
@export var AI释放优先级: int = 0
##远程技能效果,近战无效对于实体本身最大距离的倍率
@export var AI释放距离: float = 0.5
##技能释放时变为 当前时间戳
var 技能释放时间戳:float=-1
##需要释放一次技能后才能读取到
var 后摇时长:float=-1
## 就绪->释放中->就绪
var 已释放: bool = false
func _init(注册技能名称:String,等级:int= 1) -> void:
	var 表格:=计划.表格
	if not 表格.蓝图字典.has(注册技能名称):
		print("错误,找不到技能")
		return
	技能名称=注册技能名称
	技能等级=等级
	技能描述=表格.蓝图数据(技能名称,"简介")
	技能图标=表格.道具贴图(技能名称)
	var 属性:Dictionary=表格.获取属性(技能名称,null,{})
	# 从属性字典批量赋值，不存在则使用变量自身默认值
	子弹类型 = 属性.get("子弹类型", 子弹类型)
	技能类型 = 属性.get("技能类型", 技能类型)
	强度值 = 属性.get("强度值", 强度值)
	冷却时间 = 属性.get("冷却时间", 冷却时间)
	魔法消耗 = 属性.get("魔法消耗", 魔法消耗)
	每级强度加成 = 属性.get("每级强度加成", 每级强度加成)
	飞行倍率 = 属性.get("飞行倍率", 飞行倍率)
	弹道速度倍率 = 属性.get("弹道速度倍率", 弹道速度倍率)
	吟唱时间 = 属性.get("吟唱时间", 吟唱时间)
	AI释放优先级 = 属性.get("AI释放优先级", AI释放优先级)
	AI释放距离 = 属性.get("AI释放距离", AI释放距离)
# 技能是否可以释放（核心判断）
func 技能可用检查() -> bool:
	# 误差宽容值：1/30 秒 ≈ 0.03 秒，解决帧精度问题
	const 误差宽容值 = 1.0 / 30.0
	if 已释放:
		var 当前时间 = Time.get_unix_time_from_system()
		var 释放时间 = 技能释放时间戳
		var 后摇结束时间 = 释放时间 + 后摇时长
		if 当前时间 < (后摇结束时间 - 误差宽容值):
			var 剩余后摇 = 后摇结束时间 - 当前时间
			print("[后摇中] 剩余后摇：%.2f 秒" % 剩余后摇)
			return false
		var 冷却结束时间 = 释放时间 + 冷却时间
		if 当前时间 < (冷却结束时间 - 误差宽容值):
			var 剩余冷却 = 冷却结束时间 - 当前时间
			print("[冷却中] 剩余冷却：%.2f 秒" % 剩余冷却)
			return false
	return true
# 获取剩余冷却/后摇时间（UI 用）
func 剩余冷却时间() -> float:
	if 已释放:
		var 当前时间 = Time.get_unix_time_from_system()
		var 结束时间 = max(后摇时长, 冷却时间)+技能释放时间戳
		var 剩余 = 结束时间 - 当前时间
		return max(剩余, 0.0)
	return 0.0
var 子弹字典:Dictionary={
	"近战攻击":{
		"场景":preload("res://界面/游历系统/实体/近战攻击.tscn")},
	"远程攻击":{
		"场景":preload("res://界面/游历系统/实体/远程攻击.tscn")},}
##返回后摇
func 释放技能(实体:游历实体)->float:
	var 子弹数据:Dictionary=子弹字典.get(子弹类型,{})
	if 子弹数据.has("场景"):
		var 子弹场景:游历子弹=子弹数据.场景.instantiate()
		if 实体.实体类型=="怪物":子弹场景.碰撞目标层=5
		elif 实体.实体类型=="玩家":子弹场景.碰撞目标层=2
		子弹场景.伤害值=实体.攻击力*强度值+每级强度加成*技能等级
		if 子弹类型=="近战攻击":
			子弹场景.武器名称=实体.武器名称
			if 子弹场景 is 游历子弹_近战攻击:
				子弹场景.击退力=实体.击退力*实体.近战攻击容器.scale
			实体.近战攻击容器.add_child(子弹场景)
		elif 子弹类型=="远程攻击":
			子弹场景.武器名称=技能名称
			if not 计划.地图.子弹管理器:
				return 0
			if 子弹场景 is 游历子弹_远程攻击:
				子弹场景.global_position=实体.近战攻击容器.global_position
				子弹场景.最大飞行距离=实体.最大攻击距离*飞行倍率
				子弹场景.子弹速度=实体.速度*弹道速度倍率
				子弹场景.子弹方向=Vector2(1,0)#碰撞范围.scale
				计划.地图.子弹管理器.add_child(子弹场景)
		已释放 = true
		后摇时长=子弹场景.获取动画时长()
		技能释放时间戳=Time.get_unix_time_from_system()
	return 后摇时长
	
