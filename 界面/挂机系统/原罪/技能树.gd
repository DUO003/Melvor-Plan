extends HSplitContainer

var 技能名称:String
@onready var 中心节点: Control = %显示区域
@onready var 范围节点: Control = %技能中心点
@onready var 技能文本: RichTextLabel = %显示的技能
@onready var 动作进度条: Control = %动作进度条
@onready var 研究队列: VBoxContainer = %研究队列
@onready var 研究倍率: HSlider = %研究倍率
@onready var 研究经费: Label = %研究经费
@onready var 加入队列: Button = %加入队列
@onready var 清空队列: Button = %清空队列
@onready var 回到中心: Button = $技能树节点/显示区域/回到中心
var 中心点:Vector2=Vector2(0,0)
func _ready() -> void:
	%"技能树节点".clip_contents=true
	计划.技能树.检查技能树队列()
	加载技能文本("挂机核心")
	计划.技能点击信号.connect(加载技能文本)
	中心节点.gui_input.connect(_当范围节点接收GUI输入时)
	var 研究制作队列:Array = 计划.技能树.队列技能()
	刷新研究队列(研究制作队列)
	if 研究制作队列.size()>=1:
		动作进度条.开始动作("技能研究",1,self)
		清空队列.visible=true
	else :清空队列.visible=false
	加入队列.pressed.connect(加入制作队列)
	清空队列.pressed.connect(清空制作队列)
	研究倍率.value=float(计划.技能树.技能队列参数("研究强度"))
	计划.更新_UI.connect(更新制作强度)
	回到中心.pressed.connect(回中心)
	更新制作强度()
	更新细线()
	await get_tree().process_frame
	中心点=Vector2(中心节点.size.x*0.5,中心节点.size.y*0.5)
	范围节点.position=计划.窗口状态管理("技能树","拖动位置",中心点)
func 更新制作强度():
	计划.技能树.技能队列参数("研究强度",int(研究倍率.value))
	研究经费.text="每秒消耗%.0f金币\n获取%d的研究进度"%[1*int(研究倍率.value**2),1*研究倍率.value]
func 加入制作队列():
	var 前置技能=计划.技能树.数据技能树(技能名称, "前置技能")
	for 前置技能名称 in 前置技能:
		var 前置技能当前等级 = 计划.技能树.数据技能树(前置技能名称, "等级")
		if 前置技能当前等级 < 1:
			计划.语法糖通知("需要先至少获得一级%s技能"%前置技能名称,"技能树")
			return
	var 最大等级=计划.技能树.数据技能树(技能名称, "最大等级")
	var 当前等级=计划.技能树.数据技能树(技能名称, "等级")
	if 当前等级>=最大等级:
		计划.语法糖通知("技能已满级","技能树")
		return
	var 更新制作队列:Array = 计划.技能树.队列技能(技能名称,1)
	if not 动作进度条.执行动作中:
		动作进度条.开始动作("技能研究",1,self)
		清空队列.visible=true
	刷新研究队列(更新制作队列)
func 清空制作队列():
	var 技能=计划.技能树.技能队列参数("技能")
	技能["制作队列"]=[]
	刷新研究队列()
	加载技能文本()
func 刷新研究队列(研究制作队列=计划.技能树.队列技能()):
	var 研究队列节点=研究队列.get_children()
	if 研究队列节点.size()==研究制作队列.size():
		for i in range(研究队列节点.size()):
			var 文本标签 = 研究队列节点[i]
			var 技能的名称=研究制作队列[i]["技能名称"]
			var 技能的次数=研究制作队列[i]["制作次数"]
			var 研究进度 = 计划.技能树.数据技能树(技能的名称, "研究进度")
			var 研究费用 = 计划.技能树.数据技能树(技能的名称, "研究费用")
			文本标签.text="研究:%s*%d\r进度：%.0f/%.0f"%[技能的名称,int(技能的次数),float(研究进度),float(研究费用)]
	else :
		计划.清除子节点(研究队列)
		for 研究 in 研究制作队列:
			var 文本标签 = RichTextLabel.new()
			var 技能的名称=研究["技能名称"]
			var 技能的次数=研究["制作次数"]
			var 研究进度 = 计划.技能树.数据技能树(技能的名称, "研究进度")
			var 研究费用 = 计划.技能树.数据技能树(技能的名称, "研究费用")
			文本标签.bbcode_enabled=true
			文本标签.add_theme_font_size_override("normal_font_size", 32)
			文本标签.add_theme_constant_override("line_separation", -15)
			文本标签.scroll_active=false
			文本标签.fit_content=true
			文本标签.anchor_left=0
			文本标签.anchor_right=1
			文本标签.text="研究:%s*%d\r进度：%.0f/%.0f"%[技能的名称,int(技能的次数),float(研究进度),float(研究费用)]
			研究队列.add_child(文本标签)
	if 研究制作队列.size()==0:
		动作进度条.暂停()
		清空队列.visible=false
func 处理动作(动作名称):
	if 动作名称=="技能研究":
		if 计划.技能树.检查技能树队列():
			刷新研究队列()
			加载技能文本()
			计划.更新_UI.emit()
			计划.保存存档("技能研究")
var 是否正在拖动: bool = false
var 拖动偏移量: Vector2 = Vector2.ZERO
var 滑动速度: Vector2 = Vector2.ZERO
const 速度衰减系数: float = 8
const 停止阈值: float = 1.0
func 回中心():
	中心点=Vector2(中心节点.size.x*0.5,中心节点.size.y*0.5)
	范围节点.position=中心点
var 时间
##范围节点的GUI输入回调函数
func _当范围节点接收GUI输入时(事件: InputEvent):
	if 事件 is InputEventMouseButton:
		if 事件.button_index == MOUSE_BUTTON_LEFT and 事件.pressed:# 左键按下：开启拖动
			是否正在拖动 = true
			拖动偏移量 = 事件.global_position - 范围节点.global_position
		elif 事件.button_index == MOUSE_BUTTON_LEFT and not 事件.pressed:
			是否正在拖动 = false
			计划.窗口状态管理("技能树","拖动位置",null,范围节点.position)
	elif 事件 is InputEventMouseMotion and 是否正在拖动:
		范围节点.global_position = 事件.global_position - 拖动偏移量
		var 速度倍率=1.0
		滑动速度 = 速度倍率*事件.velocity
# 每帧处理惯性滑动逻辑（核心）
func _process( delta: float):# 非拖动 + 速度（像素/秒）大于阈值
	if 滑动速度.length() > 停止阈值:
		滑动速度 *= (1 - 速度衰减系数 * delta)
		if not 是否正在拖动:
			范围节点.position += 滑动速度 * delta
	elif not 是否正在拖动:
		if not 滑动速度==Vector2.ZERO:
			计划.窗口状态管理("技能树","拖动位置",null,范围节点.position)
			滑动速度 = Vector2.ZERO
func 加载技能文本(技能名=技能名称):
	技能名称=技能名
	var 技能字典 = 计划.技能树.数据技能树(技能名称, "字典")
	if not 技能字典 is Dictionary:
		技能文本.text="找不到技能"
	else:
		var 最大等级 = 计划.技能树.数据技能树(技能名称, "最大等级")
		var 技能简介 = 技能字典["简介"]
		var 前置技能数组 = 技能字典["前置技能"]
		var 未满足前置技能数组 = []
		var 所属系统 = 技能字典["系统"]
		var 当前等级 = 计划.技能树.数据技能树(技能名称, "等级")
		var 研究进度 = 计划.技能树.数据技能树(技能名称, "研究进度")
		var 研究费用 = 计划.技能树.数据技能树(技能名称, "研究费用")
		var 技能强度 = 计划.技能树.数据技能树(技能名称, "强度")
		var 强度文本 = ""# 5. 处理强度后缀：未达最大等级时显示(+xx)
		if 当前等级 < 最大等级:
			var 每级增加强度 = 技能字典["每级增加强度"]
			if 技能强度 is float:
				强度文本 = "\n强度：%.2f(+%.2f)" % [技能强度,每级增加强度]
			else :
				强度文本 = "\n强度：%d(+%d)" % [技能强度,每级增加强度]
		else :
			if 技能强度 is float:
				强度文本 = "\n强度：%.2f" % [技能强度]
			else :
				强度文本 = "\n强度：%d" % [技能强度]
		for 单个前置技能名称 in 前置技能数组:
			var 前置技能当前等级 = 计划.技能树.数据技能树(单个前置技能名称, "等级")
			if 前置技能当前等级 < 1:
				未满足前置技能数组.append(单个前置技能名称)
		var 前置技能文本 = "\n前置技能："+",".join(未满足前置技能数组)
		if 未满足前置技能数组.size()<=0:前置技能文本=""
		var 技能展示文本模板 = "【%s】\n所属系统：%s\n简介：%s\n等级：%.0f/%.0f级%s%s\n研究进度：%.0f/%.0f"
		技能文本.text=技能展示文本模板 % [技能名称,所属系统,技能简介,float(当前等级),
			float(最大等级),强度文本,前置技能文本,float(研究进度),float(研究费用)]
func 更新细线():
	var 缓存字典={}
	for 节点 in 范围节点.get_children():
		if 节点 is 技能节点:
			var 当前技能名称=节点.技能文本
			var 前置技能:Array=计划.技能树.数据技能树(当前技能名称, "前置技能")
			缓存字典[当前技能名称]={}
			缓存字典[当前技能名称]["节点"]=节点
			缓存字典[当前技能名称]["前置技能数组"]=前置技能
	# 第二步：遍历缓存字典，生成技能节点间的线段数据
	var 线段数据数组: Array = []
	for 当前技能名称 in 缓存字典.keys():
		# 获取当前技能对应的节点和前置技能数组
		var 当前技能条目 = 缓存字典[当前技能名称]
		var 当前节点 = 当前技能条目["节点"]
		var 前置技能数组 = 当前技能条目["前置技能数组"]
		# 跳过无前置技能的节点（无需连线）
		if 前置技能数组.is_empty():
			continue
		# 遍历当前节点的所有前置技能，匹配对应节点并生成线段
		for 前置技能名称 in 前置技能数组:
			# 校验：前置技能是否存在于缓存字典中（避免找不到节点报错）
			if not 缓存字典.has(前置技能名称):
				print("前置技能「%s」未找到对应节点，跳过连线" % 前置技能名称)
				continue
			var 前置节点 = 缓存字典[前置技能名称]["节点"]
			var 当前节点坐标 = 当前节点.position+ 当前节点.size / 2
			var 前置节点坐标 = 前置节点.position+ 前置节点.size / 2
			var 单条线段 = [
				当前节点坐标.x, 当前节点坐标.y,
				前置节点坐标.x, 前置节点坐标.y]
			线段数据数组.append(单条线段)
	%"技能树中心点".更新线段数据(线段数据数组)
