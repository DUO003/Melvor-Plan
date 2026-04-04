extends 基类梅窗口
##关于显示层级
#0层功能区
#1层游戏主场景
#2地图(部分窗口内,跟随摄像机移动)
#3提示信息,物品栏
#4层对话
#5层暂停/测试界面
##真实字典位于"梅窗口"此处运行时会覆盖
var 窗口:梅窗口=计划.窗口
var 初始界面="初始"#缓存当前窗口名称
var 任务栏数组: Array = []# 任务栏需要显示的界面名称数组,从存档加载
var 全局图钉=["金币"]
var 滚动计时器:Timer
var 图钉区光标=false
@onready var 摄像机: Camera2D = %摄像机
@onready var 任务栏节点: VBoxContainer = %"任务栏"
@onready var 任务按钮本体: Button = %"任务"  # 明确为Button节点
@onready var 其他容器: Control = %其他容器
@onready var 等级显示: 梅精通熟练条 = %等级显示
signal 场景更新(当前场景)# 场景变化时会发出信号,首次加载也会发出
func _ready():
	场景容器= %场景容器
	super._ready()
	场景更新.connect(func(场景名称):计划.emit_signal("场景更新",场景名称))
	%"图钉".mouse_entered.connect(func(): 图钉区光标=true)
	%"图钉".mouse_exited.connect(func(): 图钉区光标=false)
	滚动计时器=计划.创建计时器(2,func():
		if not 图钉区光标 and %"图钉容器".size.x>1920 :
			移动节点到最后(%"图钉容器"))
	var 分割长度:int=int(计划.窗口状态管理("根节点","分割长度",200))
	%"任务栏分割".split_offset=分割长度
	%"任务栏分割".drag_ended.connect(func():计划.窗口状态管理("根节点","分割长度",null,%"任务栏分割".split_offset))
	计划.提示容器=%"提示容器"#仅空窗口注册
	计划.其他容器=其他容器
	生成任务栏按钮()# 在节点加载完成后生成任务栏按钮
	更新BUFF()
	计划.BUFF.更新_BUFF.connect(更新BUFF)
	if 初始界面=="初始":
		var 打开场景=计划.窗口状态管理("根场景","初始",任务栏数组[0])
		重载场景(打开场景)
func _exit_tree():#理论上不会执行
	生命周期计时器+=[滚动计时器]
	super._exit_tree()
var BUFF提示模板 = preload("res://界面/根界面/buff状态.tscn")
func 更新BUFF():
	var 新BUFF列表:Array[梅BUFF数据] = 计划.BUFF.所有BUFF
	var 现有BUFF节点 = %BUFF.get_children()
	var 现有节点数量 = 现有BUFF节点.size()
	var 新BUFF数量 = 新BUFF列表.size()
	for i in 新BUFF数量:
		var 当前BUFF数据 = 新BUFF列表[i]
		var 目标BUFF节点:Node
		if i < 现有节点数量:
			目标BUFF节点 = 现有BUFF节点[i]
			目标BUFF节点.BUFF数据 = 当前BUFF数据
			目标BUFF节点.初始化()
		else:#超出索引
			目标BUFF节点 = BUFF提示模板.instantiate()
			目标BUFF节点.BUFF数据 = 当前BUFF数据
			%BUFF.add_child(目标BUFF节点)
	if 现有节点数量 > 新BUFF数量:
		for i in range(新BUFF数量, 现有节点数量):
			var 多余节点 = 现有BUFF节点[i]
			%BUFF.remove_child(多余节点)
			多余节点.queue_free()
func 重载图钉():
	计划.清除子节点(%"图钉容器")
	var 背包按钮:=生成任务栏节点("背包界面",true)
	%"图钉容器".add_child(背包按钮)
	计划.背包坐标=背包按钮.global_position+Vector2(背包按钮.size)*0.5
	var 图钉场景 = preload("res://界面/插件/图钉.tscn").instantiate()
	全局图钉=计划.梅存档["挂机"]["全局图钉"]
	if 全局图钉.size()>=1:
		for 图钉 in 全局图钉:
			var 新图钉=图钉场景.duplicate()
			新图钉.物品名称=图钉
			%"图钉容器".add_child(新图钉)
	var 当前界面图钉=窗口.窗口数据[初始界面].图钉
	if 当前界面图钉.size()>=1:
		for 图钉 in 当前界面图钉:
			if 图钉 not in 全局图钉:
				var 新图钉=图钉场景.duplicate()
				新图钉.物品名称=图钉
				%"图钉容器".add_child(新图钉)
	if 当前界面图钉.size()==0 and 全局图钉.size()==0:
		var 标签=Label.new()
		标签.text="图钉可以在背包添加,固定显示物品数量"
		标签.add_theme_color_override("font_color", Color(1,1,1))
		%"图钉容器".add_child(标签)
func 生成任务栏按钮() -> void:# 生成任务栏所有按钮
	for 节点 in 任务栏节点.get_children():
		if 节点!=任务按钮本体:
			节点.queue_free()
	var 窗口解锁数组: Array = 计划.梅存档.挂机.窗口解锁
	var 窗口禁用数组: Array = 计划.梅存档.挂机.窗口禁用
	if not 窗口解锁数组.has("任务窗口"):
		窗口解锁数组.append("任务窗口")
	if 窗口解锁数组.has("默认窗口"):
		窗口解锁数组.erase("默认窗口")
	任务栏数组 = []
	for 窗口名 in 窗口解锁数组:
		if not 窗口禁用数组.has(窗口名):# 其他窗口：必须不在禁用数组中才保留
			任务栏数组.append(窗口名)
	if not 任务栏数组.has("任务窗口"):
		任务栏数组.insert(0,"任务窗口")
	var 待移除元素:Array=[]
	for 界面名称 in 任务栏数组:
		if 窗口.窗口数据.has(界面名称):
			任务栏节点.add_child(生成任务栏节点(界面名称))
		else :
			待移除元素.append(界面名称)
	if 待移除元素.size()>=1:
		for 界面名称 in 待移除元素:
			print("当前%s界面不存在从存档中移除"%界面名称)
			窗口解锁数组.erase(界面名称)
			窗口禁用数组.erase(界面名称)
	任务按钮本体.hide()# 按钮本体初始隐藏
func 生成任务栏节点(界面名称:String,隐藏文本:bool=false)->Button:
	if not 窗口.窗口数据.has(界面名称):
		return null
	var 任务按钮: Button = 任务按钮本体.duplicate()
	任务按钮.show()#防止节点为隐藏
	if 隐藏文本:
		任务按钮.text = ""
		任务按钮.custom_minimum_size=Vector2(80,80)
	else :
		任务按钮.text = 窗口.窗口数据[界面名称].显示名
		任务按钮.custom_minimum_size=Vector2(220,70)
	var 路径=窗口.窗口数据[界面名称].贴图
	var 纹理=load(路径) if 路径!="" else null
	if 纹理:
		任务按钮.icon=纹理
		var 文本字数:int=任务按钮.text.length()#获取长度
		if 文本字数>=2:
			pass
			#任务按钮.add_theme_font_size_override("font_size", max(20,100.0/文本字数))
	任务按钮.pressed.connect(重载场景.bind(界面名称))
	var 红点提示 = 任务按钮.get_node("红点提示")
	红点提示.红点条目=界面名称
	return 任务按钮
## 参数: 场景名称(例如 "背包界面")
func 重载场景(场景名称: String,强制重载=false) -> void:
	if not 窗口.窗口数据.has(场景名称):
		print("错误: 场景%s不存在于路径映射中"%场景名称)
		return
	var 场景配置:Dictionary=窗口.窗口数据[场景名称] as Dictionary
	if GBIS.has_moving_item():
		GBIS.moving_item_service.安全清除移动物品()
	if 计划.节点有效性检查("奖励悬浮面板"):
		var 节点:奖励悬浮面板=计划.节点["奖励悬浮面板"]
		节点.清空界面()
	if not 强制重载 and 初始界面!="初始" and 初始界面==场景名称:
		print("当前场景已经为",str(场景名称))
		return
	for 子节点 in 场景容器.get_children():# 清空场景容器下的所有节点
		场景容器.remove_child(子节点)
		子节点.queue_free()  # 释放节点资源
	var 场景路径: String = 场景配置.场景路径
	var 场景加载器: PackedScene = load(场景路径)
	if 场景加载器 == null:
		print("无法加载场景: ", 场景路径)
		return
	# 实例化场景并添加到容器
	var 场景实例: Node = 场景加载器.instantiate()
	场景容器.add_child(场景实例)
	初始界面=场景名称
	计划.窗口状态管理("根场景","初始",null,场景名称)
	计划.红点.消除红点(场景名称,"",-1)
	重载图钉()
	emit_signal("场景更新",场景名称)
	var 系统名称:String=场景配置.系统
	var 玩法名称:String=场景配置.显示名
	等级显示.页面修改(系统名称,玩法名称)
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
		屏幕震动(摄像机,3,10,0.5)
#快捷方法
	#计划.节点["空节点"].重载场景("合成界面",null)
# 简洁版本
func 打印戈多引擎开发者():
	var author_info = Engine.get_author_info()
	print("Godot引擎贡献者信息:")
	for category in author_info:
		print(category + ": " + str(author_info[category]))
