extends Control
class_name 订单卡片
@export_group("外部传入入参数")
@export var 订单数据: 梅订单数据
@export var 提交数量:int=1
var 初始提交
@export_group("固定文本")
@export_multiline var 固定文本:String="[font_size=47][b]{物品名称}[/b][/font_size]
倍率{倍率}%
合计:{金币数量}[img=40x40]res://素材/游戏素材/货币/2.png[/img]
剩余{额外奖励}次赠品+{额外奖励数量}[img=40x40]{额外奖励图片}[/img]"
var 固定条件=[["{物品名称}",func():return 订单数据.名称],
["{倍率}",func():return "%.1f"%(100*订单数据.单价)],
["{金币数量}",func():
	var 金币:int=0
	if 提交数量>=1:
		var 单价损失:float=订单数据.单价损失
		var 基础价格:float=订单数据.价格
		for i in range(提交数量):
			金币+=int(基础价格)#存在非常微小的差异
			基础价格=单价损失*基础价格
	return 金币],
["{额外奖励}",func():return 订单数据.额外奖励],
["{额外奖励数量}",func():return 订单数据.额外物品数量],
["{额外奖励图片}",func():return 计划.表格.道具贴图(订单数据.额外物品).resource_path]]
var 固定标题="[img=40x40]{图标}[/img]#{标题}"
var 提交:Button
func _ready() -> void:
	初始提交=提交数量
	if 提交数量==0:
		var 订单数量=计划.读取数据订单("订单数量",订单数据.订单类型)
		var 物品数量:int=订单数据.背包数量
		var 订单量:int=订单数据.订单量
		while not 订单数量<=提交数量:
			if 订单量>物品数量:break
			物品数量-=订单量
			提交数量+=1
		if 提交数量==0:提交数量=1
	提交=%"提交"
	全面更新()
	%"放弃".pressed.connect(放弃)
	提交.pressed.connect(func(): 
		var 提交成功:int=0
		for i in range(提交数量):
			if 订单数据.提交订单():提交成功+=1
		if 提交成功<1:计划.语法糖通知("订单提交条件不满足","订单提交")
		if 提交成功==1:计划.语法糖通知("订单提交成功","订单提交")
		else :计划.语法糖通知("订单提交成功%d次"%提交成功,"订单提交")
		if 初始提交==0:计划.更新玩法.emit()
		计划.更新_UI.emit())
	计划.更新_UI.connect(全面更新)
	if not 订单数据.时限==-1:
		$"计时器".timeout.connect(func(): 更新计时器())
func 放弃():
	订单数据.放弃()
	计划.更新_UI.emit()
	if 计划.节点有效性检查("订单界面"):
		计划.节点["订单界面"].网格容器.mouse_behavior_recursive=MOUSE_BEHAVIOR_DISABLED
		计划.创建计时器(0.3,func():计划.节点["订单界面"].网格容器.mouse_behavior_recursive=MOUSE_BEHAVIOR_INHERITED,{"是否循环":false})
func 全面更新():
	var 缓存标题=固定标题
	缓存标题=缓存标题.replace("{图标}",订单数据.图标)
	缓存标题=缓存标题.replace("{标题}",订单数据.订单类型)
	$"订单类型".text=缓存标题
	if not 订单数据 is 梅订单数据 or 订单数据.名称=="":
		显示或隐藏(false)
		self_modulate=Color(0.352, 0.352, 0.352, 1.0)
	else :
		显示或隐藏(true)
		self_modulate=Color(1.0, 1.0, 1.0, 1.0)
		$"装饰文本".text=订单数据.修饰
		#print("装饰",订单数据.修饰)
		var 缓存贴图=计划.表格.道具贴图(订单数据.名称)
		if 缓存贴图:
			$"贴图".texture=缓存贴图
		else :$"贴图".texture=null
		var 背包数量=订单数据.背包数量
		$"进度条".max_value=订单数据.订单量
		$"进度条".value=背包数量
		var 目标订单量=订单数据.订单量*提交数量
		$"进度条/进度".text=str(min(目标订单量,背包数量))+"/"+str(目标订单量)
		if not 提交数量==1:$"进度条/进度".text+="(%d)"%订单数据.订单量
		var 文本=固定文本
		for 条件 in 固定条件:
			文本=文本.replace(条件[0], str(条件[1].call()))
		$"报酬".text=文本
		if 初始提交==0:提交.text="全部提交"
		elif 提交数量==1:提交.text="提交"
		else:提交.text="提交*%d"%提交数量
		更新计时器()

func 更新计时器():
	if 订单数据.时限==-1 or 订单数据.名称=="":
		$"倒计时".visible=false
	else :
		var 当前时间: float=Time.get_unix_time_from_system()
		var 剩余秒数: int=int(订单数据.时限-当前时间)
		if 剩余秒数>0:
			$"倒计时".visible=true
			$"倒计时".text="剩余："+计划.格式化时间(剩余秒数,2)
		else :
			放弃()

func 显示或隐藏(显示:bool):
	if not 显示:
		$"倒计时".visible=false
	$"订单类型".visible=true
	$"贴图".visible=显示
	$"装饰文本".visible=显示
	%"提交".visible=显示
	%"放弃".visible=显示
	$"报酬".visible=显示
	$"进度条".visible=显示
