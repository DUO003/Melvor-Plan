extends Control
class_name 基类梅窗口#逐渐改使用基类 当前大部分窗口未使用
@export var 基类窗口名称:String=""#所有继承者必须重写这个
@export_multiline var 提示文本: Array[String] = []#非强制
@export var 选项卡同步: Dictionary[String,TabContainer] = {}
@export var 滚动区同步: Dictionary[String,ScrollContainer] = {}
@export var 生命周期计时器: Array[Timer]
func _ready() -> void:
	assert(基类窗口名称 != "", "基类窗口名称不能为空，所有继承者必须重写这个属性")
	计划.节点[基类窗口名称]=self#注册
	call_deferred("自动加载")
func 自动加载():
	for 选项名称:String in 选项卡同步:
		var 当前选项卡=选项卡同步[选项名称]
		当前选项卡.current_tab=计划.窗口状态_限制(基类窗口名称,选项名称,0,当前选项卡.get_tab_count(),0)
		当前选项卡.tab_selected.connect(func(序号):计划.窗口状态管理(基类窗口名称,选项名称,null,序号))
	for 选项名称:String in 滚动区同步:
		var 当前滚动区=滚动区同步[选项名称]
		当前滚动区.scroll_horizontal=计划.窗口状态管理(基类窗口名称,选项名称+"水平",0)
		当前滚动区.scroll_vertical=计划.窗口状态管理(基类窗口名称,选项名称+"垂直",0)
		var 水平=当前滚动区.get_h_scroll_bar()
		var 垂直=当前滚动区.get_v_scroll_bar()
		水平.mouse_exited.connect(func():保存滚动区(当前滚动区,选项名称))
		垂直.mouse_exited.connect(func():保存滚动区(当前滚动区,选项名称))
func 保存滚动区(当前滚动区:ScrollContainer,选项名称:String):
	计划.窗口状态管理(基类窗口名称,选项名称+"水平",null,当前滚动区.scroll_horizontal)
	计划.窗口状态管理(基类窗口名称,选项名称+"垂直",null,当前滚动区.scroll_vertical)
	#print("已保存",当前滚动区.scroll_vertical,当前滚动区.scroll_horizontal)
func _exit_tree() -> void:
	if 计划.节点.has(基类窗口名称):# 安全检查：确保字典中存在该键再移除
		计划.节点.erase(基类窗口名称)
	for 计时器 in 生命周期计时器:
		计时器.queue_free()
	for 选项名称:String in 滚动区同步:
		保存滚动区(滚动区同步[选项名称],选项名称)
func 清除子节点(节点容器,保留节点=null):
	计划.清除子节点(节点容器,保留节点)#用的太多了,移动到全局代码更方便
func 定期更新提示文本(目标文本节点):
	if 目标文本节点 == null:
		return
	elif 提示文本.size() == 0:
		目标文本节点.text = "温馨提示"
		return
	elif 提示文本.size() == 1:
		目标文本节点.text = 提示文本[0]
		return
	var 当前显示文本 = 目标文本节点.text# 4. 数组有多条文本时，选择与当前文本不同的提示
	var 可选提示列表 = 提示文本.filter(func(单条提示):# 过滤出与当前文本不同的可选提示
		return 单条提示 != 当前显示文本)
	if 可选提示列表.size() > 0:# 5. 从可选提示中随机选择一条（若所有提示都与当前相同，则随机选数组中任意一条）
		var 随机索引 = randi() % 可选提示列表.size()
		目标文本节点.text = 可选提示列表[随机索引]
	else:# 极端情况：数组所有元素相同（虽不符合常规，但做兼容处理）
		目标文本节点.text = 提示文本[0]
func 节点有效性检查(节点名称:String)->bool:
	return 节点名称 in 计划.节点 and 计划.节点[节点名称] != null
var 屏幕震动锁定:bool=false
var 初始位置:Vector2
func 屏幕震动(摄像机节点: Node2D, 震动频率: int, 震动幅度: int, 震动持续时间: float) -> void:
	# 参数合法性校验与修正
	震动频率 = max(震动频率, 1)  # 确保频率至少为1帧
	震动幅度 = max(震动幅度, 1)  # 确保幅度至少为1像素
	震动持续时间 = max(震动持续时间, 0.1)  # 确保最少0.1秒
	
	# 记录摄像机初始位置(用于最终复位)
	if not 屏幕震动锁定:
		初始位置 = 摄像机节点.position
		屏幕震动锁定=true
	# 计算总震动帧数(基于当前帧率)
	var 帧率 = int(Engine.get_frames_per_second())  # 返回float，表示当前实际FPS
	var 总震动帧数 = int(震动持续时间 * 帧率)
	总震动帧数 = max(总震动帧数, 1)  # 确保至少有1帧震动
	
	var 当前帧计数 = 0
	var 当前偏移量 = Vector2.ZERO  # 初始偏移为0
	
	# 循环执行震动效果
	for _X in range(总震动帧数):
		当前帧计数 += 1
		
		# 每隔指定频率帧更新一次偏移量
		if 当前帧计数 % 震动频率 == 0:
			当前偏移量 = Vector2(
				randf_range(-震动幅度, 震动幅度),  # X轴随机偏移
				randf_range(-震动幅度, 震动幅度))   # Y轴随机偏移
		# 应用偏移到摄像机位置
		摄像机节点.position = 初始位置 + 当前偏移量
		await get_tree().process_frame
	# 震动结束后强制复位到初始位置
	摄像机节点.position = 初始位置
	屏幕震动锁定=false
