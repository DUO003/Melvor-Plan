extends Control
class_name 任务卡片
var 任务数据:任务资源
var 任务详情:={}
var 任务序号:int=0
var 任务领取按钮:Button
func _ready() -> void:
	计划.任务更新.connect(加载任务说明)
func 初始化任务():
	if not 任务数据:
		return
	任务详情=任务数据.当前任务数据
	$"红点提示".红点条目="任务_"+任务数据.任务名称
	var 未完成前置任务:Array=计划.任务.统计未完成前置任务(任务数据.任务名称)
	var 任务数量:int=任务详情.get("前置任务",[]).size()
	var 任务完成量:int=任务数量-未完成前置任务.size()
	print(任务数据.任务名称,"前置数量%d/%d"%[任务完成量,任务数量])
	if 任务数量==0 or 任务完成量==任务数量:#前置任务条件满足
		custom_minimum_size.y=450
		%"任务内容区".custom_minimum_size.y=300
		%"前置任务进度条".visible=false
		%"按钮区".visible=true
		%"任务描述".text=解析文本()
	else :
		custom_minimum_size.y=220
		%"任务内容区".custom_minimum_size.y=150
		%"前置任务进度条".visible=true
		%"按钮区".visible=false
		%"前置任务进度条".max_value = 任务数量  # 最大值
		%"前置任务进度条".value = 任务完成量  # 当前值
		%"任务描述".text = "前置任务未解锁"+str(任务完成量)+"/"+str(任务数量)+"\n下一个前置任务:"+未完成前置任务[0]
	$"红点提示".点击逻辑=func():
		if not 计划.红点.红点数据.has("任务_"+任务数据.任务名称):
			计划.红点.红点数据["任务_"+任务数据.任务名称]=1
			计划.更新红点.emit("任务_"+任务数据.任务名称)
			计划.语法糖通知("本次登录期间<%s>任务的红点提示已隐藏"%任务数据.任务名称)
	更新标题()
	解析功能按钮()
func 更新标题():
	var 后缀=""
	if 任务数据.任务完成:
		后缀="(已完成)"
	elif 计划.红点.获取红点状态("任务_"+任务数据.任务名称)==1:
		if 任务数据.任务状态:
			后缀="(进行中)"
		else :
			后缀="(可领取)"
		#print(任务名称,任务领取状态.get(任务名称,false))
	$"任务名称".text=任务数据.任务类型+str(任务序号)+"."+任务数据.任务名称+后缀
	
func 加载任务说明(更新任务:Array[任务资源]=[]):
	if 更新任务.is_empty() or 更新任务.has(任务数据):
		%"任务描述".text=解析文本()
func 解析文本():
	var 任务描述数组=任务详情["任务描述"]
	var 任务文本:String="\n".join(任务描述数组)
	if 任务数据.任务状态:
		任务文本="已领取(正在记录任务目标)\r"+任务文本
	elif 计划.红点.获取红点状态("任务_"+任务数据.任务名称)==1:
		任务文本="任务暂停中->\r"+任务文本
	if not 任务文本.find("{当前进度}")==-1 and "进度描述" in 任务详情:
		if not 任务数据.任务本地.is_empty():
			var 替换文本=任务数据.进度描述
			var 任务当前=任务数据.任务本地["当前进度列表"]
			var i=0
			for 条件 in 任务数据.前置条件:
				var 条件文本="{%s}"%条件.条件名称
				var 任务进度值=任务当前[i]
				if 任务进度值 is float:
					任务进度值="%.0f"%任务进度值
				else :
					任务进度值=str(任务进度值)
				替换文本=替换文本.replace(条件文本, 任务进度值)
				条件文本="{%s需求}"%条件.条件名称
				替换文本=替换文本.replace(条件文本, str(条件["目标值"]))
				i+=1
			任务文本 = 任务文本.replace("{当前进度}", 替换文本)
		else :
			任务文本 = 任务文本.replace("{当前进度}", "任务以完成")
	return 任务文本
func 解析功能按钮():
	计划.清除子节点(%"真实区")
	var 按钮数组=[]
	for 功能数组 in 任务详情.get("功能按钮"):
		if not 任务数据.任务完成 or 功能数组[0]=="对话":
			var 按钮=Button.new()#目前仅存在按钮一种功能后续可能会追加其他选项
			按钮.text=功能数组[1]
			if 功能数组[0]=="对话":
				按钮.pressed.connect(func():启动对话(任务数据.任务名称))
			elif 功能数组[0]=="解锁":
				按钮.pressed.connect(func():
					if 任务数据.任务完成:
						计划.语法糖通知("任务奖励已领取","任务提示")
						return
					完成任务(任务数据.任务名称,功能数组))
			elif 功能数组[0]=="提交":
				按钮.pressed.connect(func():
					if 任务数据.任务完成:
						计划.语法糖通知("任务奖励已完成,无需重复","任务提示")
						return
					if 计划.检查背包物品数量("绿色电路板")>=功能数组[2]:
						计划.语法糖消耗物品("绿色电路板",功能数组[2])
						完成任务(任务数据.任务名称,功能数组)
					else :计划.语法糖通知("绿色电路板不足","任务提示"))
			%"真实区".add_child.call_deferred(按钮)
			按钮数组.append(按钮)
	if 任务数据.任务完成:
		var 文本=Label.new()
		文本.text="奖励已领取"
		%"真实区".add_child.call_deferred(文本)
	elif not 任务数据.任务本地.is_empty():
		var 目标值=任务数据.任务本地.size()
		var 进度值=任务数据.任务本地["完成总进度"]
		if 目标值>进度值:
			隐藏或显示节点(按钮数组,false)
			var 进度条=梅任务进度条.new()
			进度条.任务数据=任务数据
			进度条.功能按钮=func():隐藏或显示节点(按钮数组,true)
			%"真实区".add_child(进度条)
			var 按钮=Button.new()
			%"真实区".add_child.call_deferred(按钮)
			任务领取按钮=按钮
			更新按钮文本()
			任务领取按钮.pressed.connect(接受任务)
func 更新按钮文本():
	if 任务数据.任务状态:
		任务领取按钮.text="暂停任务"
	else :
		任务领取按钮.text="接受任务"
func 隐藏或显示节点(节点数组:=[],显示:bool=true):
	for 节点名称 in 节点数组:
		节点名称.visible=显示
func 完成任务(任务代号,参数="null"):
	if 任务领取按钮:
		任务领取按钮.queue_free()
	计划.删除强调通知.emit(任务代号)
	计划.任务完成处理(任务代号,参数,1)
	
func 启动对话(对话时间线):
	if Dialogic.current_timeline != null:
		return
	var 剧情进度=计划.梅存档["挂机"].get("任务进度",{}).get(对话时间线,0)
	if 剧情进度==0:
		Dialogic.VAR.set("SCJQ", true)#首次剧情=真
	else :
		Dialogic.VAR.set("SCJQ", false)#首次剧情=假
	Dialogic.start(对话时间线)
func 接受任务():
	if not 任务数据.任务完成:
		任务数据.任务状态=not 任务数据.任务状态
		更新标题()
		加载任务说明()
		更新按钮文本()
		计划.更新红点.emit("任务_"+任务数据.任务名称)
