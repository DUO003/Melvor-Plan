extends 梅队列数据
class_name 梅烹饪数据
@export var 烹饪菜谱:String=""
@export var 当前菜谱:Dictionary
var 耗时:float=-1:
	get:return 耗时计算方法()
func 耗时计算方法():
	return 烹饪耗时()
func 烹饪耗时(启用精通效果:bool=true):
	var 等级:int=0
	if 启用精通效果:
		等级=计划.手工.数据烹饪菜谱(烹饪菜谱,"等级")
	var 阶级=计划.表格.蓝图数据(烹饪菜谱,"阶级")
	var 基础耗时:float=(60+10*阶级)*(1-(等级*0.005))
	if not 当前菜谱:#如果是空字典
		return -1
	for 标签 in 当前菜谱:
		var 标签字典:Dictionary=当前菜谱[标签]
		if not 标签字典.has("物品") or not 标签字典.has("标签") or not 标签字典.has("数量"):
			return -1
		var 当前耗时:float=5
		if 等级>75:当前耗时=2
		elif 等级>50 :当前耗时=3
		elif 等级>25 :当前耗时=4
		if not 标签字典["标签"]=="":
			当前耗时+=计划.手工.烹饪工序查询(标签字典["标签"],"耗时")
		基础耗时+=当前耗时*标签字典["数量"]
	if OS.has_feature("editor_runtime"):
		return max(60,基础耗时)*0.1
	return max(60,基础耗时)*1.0
func 放弃任务():
	breakpoint#断点
##返回是否需要更新
func 领取奖励()->bool:
	if not 队列中:
		计划.手工.队列烹饪(self,0)
		return true
	if 队列完成<1:
		计划.语法糖通知("暂无奖励","烹饪提示")
		return false
	计划.steam.解锁成就("烹饪自动化")
	var 统计奖励=[计划.语法糖获得物品(烹饪菜谱,队列完成)]
	var 烹饪精通=烹饪耗时(false)*队列完成
	计划.手工.数据烹饪菜谱(烹饪菜谱,"精通",烹饪精通)
	计划.语法糖奖励显示(统计奖励,"获得料理",1)
	计划.语法糖通知("%s菜谱精通+%d"%[烹饪菜谱,烹饪精通])
	计划.任务.任务通用(计划.任务.进度类型.烹饪,队列完成,烹饪菜谱)
	队列完成=0
	if 队列数量==0:
		队列配置(0)
		计划.手工.队列烹饪(self,0)
		计划.更新_UI.emit()
		计划.保存存档("领取烹饪奖励")
		return true
	计划.更新_UI.emit()
	计划.保存存档("领取烹饪奖励")
	return false
func 扣除材料(扣除数量:int=1,手动制作:bool=true):
	for 标签 in 当前菜谱:
		var 标签字典:Dictionary=当前菜谱[标签]
		if 手动制作:
			if 标签=="调味品":计划.手工.数据调料点数(标签字典.物品,-扣除数量)
			else :计划.语法糖消耗物品(标签字典.物品,标签字典.数量*扣除数量)
		else :
			if 标签字典.标签=="":计划.语法糖消耗物品(标签字典.物品,标签字典.数量*扣除数量)
			else :计划.手工.烹饪预制(标签字典.物品,标签字典.标签,-标签字典.数量*扣除数量)
func _init(创建参数=null) -> void:
	super._init(创建参数)
	var 配方=创建参数
	if 配方 is Dictionary:
		当前菜谱=配方
func 检查配方有效性()->bool:
	if 烹饪菜谱=="":
		return false
	for 标签 in 当前菜谱:
		var 标签字典:Dictionary=当前菜谱[标签]
		if not 标签字典.has_all(["物品","标签","数量"]):
			return false
	return true
