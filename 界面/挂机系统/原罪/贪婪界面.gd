extends 基类梅窗口
# 标记是否正在拖动范围节点
var 是否正在拖动: bool = false
# 存储鼠标点击位置与节点位置的偏移量（避免拖动时节点瞬移到鼠标位置）
var 拖动偏移量: Vector2 = Vector2.ZERO
# 范围节点的引用（需在编辑器中赋值或在_ready中获取）
@onready var 范围节点: 里程碑进度条 = %里程碑进度条
# 滑动速度（记录拖动时的鼠标速度）
var 滑动速度: Vector2 = Vector2.ZERO
const 速度衰减系数: float = 8
const 停止阈值: float = 1.0
@onready var 收藏卡包: OptionButton = %收藏卡包
@onready var 占位节点: Control = %占位节点
@onready var 收藏品容器: HBoxContainer = %收藏品容器
@onready var 一键领取: Button = %一键领取
@onready var 提交数量: SpinBox = %提交数量
@onready var 贪婪条: ProgressBar = %贪婪条
@onready var 数值: Label = %数值
@onready var 收藏评分: Label = %收藏评分
func _ready() -> void:
	super._ready()#注册
	var 主菜单=%"主菜单"
	主菜单.pressed.connect(func():计划.切换场景(null,"原罪界面"))
	var 奖池:Array=[]
	奖池=计划.卡包配置.keys()
	收藏卡包.clear()
	for 参数 in 奖池:
		收藏卡包.add_item(参数)
	收藏卡包.selected=计划.窗口状态管理(基类窗口名称,"拖动位置",0)
	收藏卡包.item_selected.connect(func(参数):
		计划.窗口状态管理(基类窗口名称,"拖动位置",null,参数)
		更新卡包())
	提交数量.value=计划.窗口状态管理(基类窗口名称,"提交数量",1.0)
	更新卡包()
	占位节点.gui_input.connect(_当范围节点接收GUI输入时)
	计划.更新_UI.connect(更新得分)
	一键领取.pressed.connect(一键领取逻辑)
	提交数量.value_changed.connect(func(值):
		if 值==0.0:
			计划.语法糖通知("提交全部已启用")
		计划.窗口状态管理(基类窗口名称,"提交数量",null,值))
	var 加载位置:Vector2=计划.窗口状态管理(基类窗口名称,"拖动位置",Vector2(30,160))
	加载位置.y=160
	范围节点.position=加载位置
	更新得分()
	计划.过去一秒.connect(贪婪检查)
var 贪婪大于零=false
func 贪婪检查():
	var 贪婪值=计划.数据状态("贪婪")
	if 贪婪值>0:
		更新得分(false)
	elif 贪婪大于零:
		print("更新成功",贪婪值)
		贪婪大于零=false
		更新得分(false)
var 得分字典:Dictionary={}
func 更新得分(提示=true,卡包名=收藏卡包.text):
	var 得分缓存=计划.计算卡包总得分(卡包名)
	if 提示 and 得分缓存-得分字典.get(卡包名,0)>0:
		计划.语法糖通知("得分增加+%d"%(得分缓存-得分字典.get(卡包名,0)),"贪婪得分")
	得分字典[卡包名]=得分缓存
	范围节点.里程碑点数=得分缓存
	var 贪婪值=min(10,计划.数据状态("贪婪"))
	var 卡包信息 = 计划.卡包配置.get(收藏卡包.text, null)
	var 单卡价值:float=0
	if 卡包信息:
		if 贪婪值>0:贪婪大于零=true
		单卡价值=卡包信息.基础价值*(10-贪婪值)/10
	收藏评分.text="收藏评分:%d(单卡%.0f)"%[得分缓存,单卡价值]
	var 原罪值=计划.数据原罪("原罪值","贪婪")
	var 原罪上限=计划.数据原罪("原罪上限","贪婪")
	贪婪条.value=原罪值
	贪婪条.max_value=原罪上限
	数值.text="%d/%d"%[原罪值,原罪上限]
var 收藏卡片 = preload("res://界面/挂机系统/原罪/收藏卡片.tscn").instantiate()
func 更新卡包():
	var 当前卡包配置:Dictionary=计划.卡包配置[收藏卡包.text]
	范围节点.奖励名称=当前卡包配置.循环奖励[4]
	范围节点.奖励数量=当前卡包配置.循环奖励[5]
	if 当前卡包配置.has("替换奖励"):
		范围节点.替换奖励=当前卡包配置.替换奖励
	else :
		范围节点.替换奖励={}
	范围节点.里程碑数组=当前卡包配置.奖金池
	var 领取记录:Dictionary=计划.原罪_贪婪("","领取记录")
	范围节点.里程碑领取=领取记录.get(收藏卡包.text,[])
	更新得分(false)
	计划.清除子节点(收藏品容器)
	var 卡包信息 = 计划.卡包配置.get(收藏卡包.text, null)
	var 单卡价值:float=0
	if 卡包信息:
		单卡价值=卡包信息.基础价值
	for 名称 in 当前卡包配置.卡片列表:
		var 克隆卡片:梅收藏卡片=收藏卡片.duplicate()
		克隆卡片.物品名称=名称
		克隆卡片.提交数量=提交数量
		克隆卡片.单卡价值=单卡价值
		收藏品容器.add_child(克隆卡片)
	限制范围()
func 一键领取逻辑():
	var 当前卡包配置:Dictionary=计划.卡包配置[收藏卡包.text]
	var 当前得分:int=计划.计算卡包总得分(收藏卡包.text)
	var 得分奖励:int=0
	var 替换奖励
	if 当前卡包配置.has("替换奖励"):
		替换奖励=当前卡包配置.替换奖励
	else :
		替换奖励={}
	var 序号:int=0
	var 领取记录:Dictionary=计划.原罪_贪婪("","领取记录")
	if not 领取记录.has(收藏卡包.text):
		领取记录[收藏卡包.text]=[]
	var 当前领取记录:Array=领取记录[收藏卡包.text]
	var 领取成功=false
	for i in 当前卡包配置.奖金池:
		得分奖励+=i
		序号+=1
		if 当前得分>=得分奖励 and not 当前领取记录.has(序号):
			var 奖励名称
			var 数量
			if 替换奖励.has(序号):
				奖励名称=替换奖励[序号][0]
				数量=替换奖励[序号][1]
			else :
				奖励名称=当前卡包配置.循环奖励[4]
				数量=当前卡包配置.循环奖励[5]
			计划.获得物品语法糖(奖励名称,数量)
			计划.语法糖通知("获得%s*%d"%[奖励名称,数量])
			当前领取记录.append(序号)
			领取成功=true
	if 领取成功:
		var 原罪值=计划.数据原罪("原罪值","贪婪")
		if 原罪值>=1:
			计划.数据原罪("原罪值","贪婪",-原罪值)
	else :
		计划.语法糖通知("没有可领取的奖励","贪婪提示")
	更新卡包()
func _当范围节点接收GUI输入时(事件: InputEvent) -> void:
	if 事件 is InputEventMouseButton:
		if 事件.button_index == MOUSE_BUTTON_LEFT and 事件.pressed:  # 左键按下：开启拖动
			是否正在拖动 = true
			拖动偏移量 = 事件.global_position - 范围节点.global_position
		elif 事件.button_index == MOUSE_BUTTON_LEFT and not 事件.pressed:  # 左键松开：结束拖动
			是否正在拖动 = false
			计划.窗口状态管理(基类窗口名称,"拖动位置",null,范围节点.position)
	elif 事件 is InputEventMouseMotion and 是否正在拖动:  # 鼠标移动且处于拖动状态
		# 核心修改：只计算X轴位置，固定Y轴为范围节点原本的Y坐标
		var 目标X位置: float = 事件.global_position.x - 拖动偏移量.x
		# 保持Y轴位置不变，仅更新X轴
		范围节点.global_position = Vector2(目标X位置, 范围节点.global_position.y)
		# 滑动速度也只保留X轴，Y轴置0
		var 速度倍率: float = 1.0
		滑动速度 = Vector2(速度倍率 * 事件.velocity.x, 0.0)
# 每帧处理惯性滑动逻辑（核心）
var 保护宽度=800
func _process( delta: float):# 非拖动 + 速度（像素/秒）大于阈值
	if 滑动速度.length() > 停止阈值:
		滑动速度 *= (1 - 速度衰减系数 * delta)
		if 限制范围():滑动速度*=-0.5
		if not 是否正在拖动:
			范围节点.position += 滑动速度 * delta
	elif not 是否正在拖动:
		if not 滑动速度==Vector2.ZERO:
			计划.窗口状态管理(基类窗口名称,"拖动位置",null,范围节点.position)
			#print("拖动位置保存",范围节点.position)
			滑动速度 = Vector2.ZERO
func 限制范围():
	if 范围节点.position.x<保护宽度-范围节点.size.x:
		范围节点.position.x=保护宽度-范围节点.size.x
		return true
	if 范围节点.position.x>-保护宽度+占位节点.size.x:
		范围节点.position.x=-保护宽度+占位节点.size.x
		return true
	return false
