extends 基类梅窗口
#真实字典位于"梅窗口"此处运行时会覆盖
var 跳转:梅窗口
var 界面路径映射: Dictionary = {}#数组参数1.场景路径,参数2.场景对应的系统
var 界面父子关系: Dictionary = {}#界面父子关系字典，键为主界面名称，值为子界面名称数组
var 打开界面: Dictionary ={}#键为主界面名称，值为当前显示的子界面名称（null表示显示主界面）
var 初始界面="初始"#缓存当前窗口名称
var 任务栏数组: Array = []# 任务栏需要显示的界面名称数组,从存档加载
var 全局图钉=["金币"]
var 界面图钉={}
var 滚动计时器:Timer
var 图钉区光标=false
@onready var 任务栏节点: VBoxContainer = %"任务栏"
@onready var 任务按钮本体: Button = %"任务"  # 明确为Button节点
signal 场景更新(当前场景)# 场景变化时会发出信号,首次加载也会发出
func _ready():
	super._ready()
	场景更新.connect(func(场景名称):计划.emit_signal("场景更新",场景名称))
	%"图钉".mouse_entered.connect(func(): 图钉区光标=true)
	%"图钉".mouse_exited.connect(func(): 图钉区光标=false)
	滚动计时器=计划.创建计时器(2,func():
		if not 图钉区光标 and %"图钉容器".size.x>1920 :
			移动节点到最后(%"图钉容器"))
	界面路径映射=计划.窗口.界面路径映射#加载
	界面父子关系=计划.窗口.界面父子关系
	界面图钉=计划.窗口.界面图钉
	打开界面={}
	for key in 界面父子关系.keys():
		打开界面[key] = null
	计划.提示容器=%"提示容器"#仅空窗口注册
	生成任务栏按钮()# 在节点加载完成后生成任务栏按钮
	if 初始界面=="初始":
		if 计划.跳转设置:
			重载场景("任务窗口")
		else :
			重载场景(任务栏数组[0])
func _exit_tree():#理论上不会执行
	生命周期计时器+=[滚动计时器]
	super._exit_tree()
func 重载图钉():
	for 节点 in %"图钉容器".get_children():
		%"图钉容器".remove_child(节点)
		节点.queue_free()
	var 图钉场景 = preload("res://界面/插件/图钉.tscn").instantiate()
	全局图钉=计划.梅存档["挂机"]["全局图钉"]
	for 图钉 in 全局图钉:
		var 新图钉=图钉场景.duplicate()
		新图钉.物品名称=图钉
		%"图钉容器".add_child(新图钉)
	var 当前界面图钉=[]
	if 打开界面[初始界面]==null:
		当前界面图钉=界面图钉.get(初始界面,[])
	else :
		当前界面图钉=界面图钉.get(打开界面[初始界面],[])
	for 图钉 in 当前界面图钉:
		if 图钉 not in 全局图钉:
			var 新图钉=图钉场景.duplicate()
			新图钉.物品名称=图钉
			%"图钉容器".add_child(新图钉)
func 生成任务栏按钮() -> void:# 生成任务栏所有按钮
	for 节点 in 任务栏节点.get_children():
		if 节点!=任务按钮本体:
			节点.queue_free()
	var 窗口解锁数组: Array = 计划.梅存档["挂机"].get("窗口解锁",[])
	var 窗口禁用数组: Array = 计划.梅存档["挂机"].get("窗口禁用",[])
	if not 窗口解锁数组.has("任务窗口"):
		窗口解锁数组.append("任务窗口")
	if 窗口解锁数组.has("默认窗口"):
		窗口解锁数组.erase("默认窗口")
	任务栏数组 = []
	for 窗口 in 窗口解锁数组:
		if not 窗口禁用数组.has(窗口):# 其他窗口：必须不在禁用数组中才保留
			任务栏数组.append(窗口)
	if not 任务栏数组.has("任务窗口"):
		任务栏数组.insert(0, "任务窗口")
	for 界面名称 in 任务栏数组:
		var 任务按钮: Button = 任务按钮本体.duplicate()
		任务按钮.show()#防止节点为隐藏
		任务按钮.text = 界面名称.replace("界面", "").replace("窗口", "")
		var 路径=界面路径映射[界面名称][1]
		var 纹理=load(路径) if 路径!="" else null
		if 纹理:
			任务按钮.icon=纹理
			var 文本字数:int=任务按钮.text.length()#获取长度
			if 文本字数>=2:
				@warning_ignore("integer_division")
				任务按钮.add_theme_font_size_override("font_size", max(20,120/文本字数))
		任务按钮.pressed.connect(func(): _任务栏(界面名称))
		var 红点提示 = 任务按钮.get_node("红点提示")
		红点提示.红点条目=界面名称
		任务栏节点.add_child(任务按钮)
	任务按钮本体.hide()# 按钮本体初始隐藏

## 参数: 场景名称(例如 "背包界面")
func 重载场景(场景名称: String, 子场景名称 = null,强制重载=false) -> void:
	if GBIS.has_moving_item():
		GBIS.moving_item_service.安全清除移动物品()
	if 计划.节点有效性检查("奖励悬浮面板"):
		var 节点:奖励悬浮面板=计划.节点["奖励悬浮面板"]
		节点.清空界面()
	if not 强制重载 and 初始界面!="初始" and 初始界面==场景名称 and 打开界面[场景名称] == 子场景名称:
		print("当前场景已经为",str(场景名称))
		return
	if 子场景名称 != null:#验证子场景有效性
		if 界面父子关系.has(场景名称) and not 界面父子关系[场景名称].has(子场景名称):
			print("子场景错误",str(子场景名称))
			子场景名称 = null
	# 检查场景名称是否在映射表中
	var 场景字典名
	if 子场景名称 == null:
		场景字典名=场景名称
	else :
		场景字典名=子场景名称
	if not 界面路径映射.has(场景字典名):
		print("错误: 场景名称 '", 场景字典名, "' 不存在于路径映射中")
		return
	var 场景容器: Node = %场景容器
	for 子节点 in 场景容器.get_children():# 清空场景容器下的所有节点
		场景容器.remove_child(子节点)
		子节点.queue_free()  # 释放节点资源
	var 场景路径: String = 界面路径映射[场景字典名][0]# 从字典中获取场景路径
	var 场景加载器: PackedScene = load(场景路径)
	if 场景加载器 == null:
		print("无法加载场景: ", 场景路径)
		return
	# 实例化场景并添加到容器
	var 场景实例: Node = 场景加载器.instantiate()
	场景容器.add_child(场景实例)
	初始界面=场景名称
	打开界面[场景名称] = 子场景名称
	重载图钉()
	emit_signal("场景更新",场景名称)

func _任务栏(界面名称) -> void:
	重载场景(界面名称,打开界面[界面名称])
	计划.梅红点单例.消除红点(界面名称,"",-1)
	pass # Replace with function body.
# 传入容器节点，检查是否有2个以上子节点，如果是则将第一个节点移到最后
func 移动节点到最后(容器节点: Node) -> void:
	if 容器节点 == null:
		print("错误：容器节点为空")
		return
	var 子节点数量 = 容器节点.get_child_count()
	if 子节点数量 > 2:
		var 节点 = 容器节点.get_child(0)
		容器节点.move_child(节点, 子节点数量 - 1)
	else:
		print("子节点数量不足，不执行移动")
func 便利摄像机效果(效果参数=""):
	if 效果参数=="":
		屏幕震动(%"摄像机",3,10,0.5)
#快捷方法
	#计划.节点["空节点"].重载场景("合成界面",null)
# 简洁版本
func 打印戈多引擎开发者():
	var author_info = Engine.get_author_info()
	print("Godot引擎贡献者信息:")
	for category in author_info:
		print(category + ": " + str(author_info[category]))
