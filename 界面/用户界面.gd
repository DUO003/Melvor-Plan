extends Control
# 界面路径映射字典，维护界面名称与对应路径的关系
var 界面路径映射: Dictionary = {
	"合成界面": "res://界面/合成界面.tscn",
	"合成_抽奖机界面": "res://界面/合成_抽奖机界面.tscn",
	"背包界面": "res://界面/背包界面.tscn",
	"小游戏界面": "res://界面/小游戏界面.tscn",
	"小游戏_水排序":"res://界面/水排序.tscn",
	# 可以在这里继续添加其他界面
}
# 界面父子关系字典，键为主界面名称，值为子界面名称数组
var 界面父子关系: Dictionary = {
	"合成界面": ["合成_抽奖机界面"],
	"背包界面": [],
	"小游戏界面": ["小游戏_水排序"]
}
var 打开界面: Dictionary ={
	"合成界面":null,
	"背包界面":null,
	"小游戏界面":null
}# 记录当前打开的界面状态：键为主界面名称，值为当前显示的子界面名称（null表示显示主界面）
var 初始界面=0#表示任务栏数组第几个元素 从0计数
# 任务栏需要显示的界面名称数组
var 任务栏数组: Array = ["合成界面", "背包界面","小游戏界面"]  # 可以添加更多界面
@onready var 任务栏节点: VBoxContainer = $"任务栏"
@onready var 任务按钮本体: Button = $"任务栏/任务"  # 明确为Button节点
# 加载场景到场景容器的方法
func _ready():
	#注册
	初始化.提示容器=%"提示容器"
	初始化.节点["空节点"]=self
	print("空节点")
	# 在节点加载完成后生成任务栏按钮
	生成任务栏按钮()

# 生成任务栏所有按钮
func 生成任务栏按钮() -> void:
	for 界面名称 in 任务栏数组:
		var 任务按钮: Button = 任务按钮本体.duplicate()
		任务按钮.text = 界面名称.replace("界面", "")
		任务按钮.name = 界面名称
		任务按钮.pressed.connect(func(): _任务栏(界面名称))
		任务栏节点.add_child(任务按钮)
	var 按钮: Button = 任务栏节点.find_child(任务栏数组[初始界面], true, false)
	if 按钮:
		print("测试:",str(按钮))
		按钮.emit_signal("pressed")
		#按钮.set_pressed_no_signal(true)# 设置按钮视觉效果为按下状态,但未实现
	任务按钮本体.hide()# 按钮本体初始隐藏

# 参数: 场景名称(例如 "背包界面")
func 重载场景(场景名称: String, 子场景名称 = null) -> void:
	if GBIS.has_moving_item():
		GBIS.moving_item_service.clear_moving_item()
	if 任务栏数组[初始界面]==场景名称 and 打开界面[场景名称] == 子场景名称:
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
	var 场景路径: String = 界面路径映射[场景字典名]# 从字典中获取场景路径
	var 场景加载器: PackedScene = load(场景路径)
	if 场景加载器 == null:
		print("无法加载场景: ", 场景路径)
		return
	# 实例化场景并添加到容器
	var 场景实例: Node = 场景加载器.instantiate()
	场景容器.add_child(场景实例)
	初始界面=任务栏数组.find(场景名称)
	打开界面[场景名称] = 子场景名称


func _任务栏(界面名称) -> void:
	重载场景(界面名称,打开界面[界面名称])
	pass # Replace with function body.

#快捷方法
	#初始化.节点["空节点"].重载场景("合成界面",null)
