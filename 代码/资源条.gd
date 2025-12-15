@tool  # 关键：让脚本在编辑器内运行，实现实时预览
extends Control
class_name 资源进度条
## 设定资源字典中的其中一种资源
@export var 资源名称: String = "木材":
	set(值):
		资源名称=值
		if is_inside_tree():
			更新贴图()
var 鼠标:bool=false
var 基础量: float = 1
var 是否长按: bool = false        # 标记是否处于长按状态
var 长按计时器: Timer            # 用于长按周期性回复的计时器

var 资源回复速度:Dictionary#如果没有当前资源名称,表示回复量=0.0
var 当前数量:float=0
var 上限值:float=0
var 背包内数量:int=0
var 类型:String="基础"
func _ready():
	更新贴图()# 节点就绪时初始化
	if Engine.is_editor_hint():
		$"进度".size=Vector2(400,50)
		$"回复".visible=false
	else :
		类型=计划.手工.检查资源类(资源名称)
		更新点击回复量()
		更新UI()
		计划.BUFF.BUFF_资源回复.connect(更新点击回复量)
		$"点击范围".mouse_entered.connect(func():
			鼠标=true
			计划.手工.更新_资源.emit(self))
		$"点击范围".mouse_exited.connect(func():
			鼠标=false
			计划.手工.更新_资源.emit())
	if is_inside_tree():# 编辑器内安全检查：确保节点已加入场景树，避免空引用错误
		长按计时器 = Timer.new()
		长按计时器.wait_time = 0.5    # 长按间隔0.5秒
		长按计时器.one_shot = false   # 循环触发
		长按计时器.timeout.connect(长按超时处理)
	add_child(长按计时器)
	$"点击范围".gui_input.connect(点击逻辑)
func 更新点击回复量():
	if 类型=="特殊":基础量=0
	elif 类型=="高级":基础量=0.1
	elif 类型=="基础":基础量=1
	var 额外点击回复:Dictionary=计划.BUFF.BUFF统计("资源回复")
	if 额外点击回复.has(资源名称):
		基础量+=额外点击回复[资源名称]
	print(额外点击回复)
func 更新UI():
	资源回复速度=计划.手工.资源回复
	当前数量 = 计划.手工.查看资源(资源名称)
	上限值 = 计划.手工.资源上限字典.get(资源名称,0)
	背包内数量=计划.检查背包物品数量(资源名称)
	if 类型=="特殊":
		$"进度".max_value = 1
		$"进度".value = 1
		$"进度".show_percentage=false
		%"显示数量".text="拥有:"+str(int(背包内数量+当前数量))
		%"显示数量".visible=true
	else :
		$"进度".max_value = 上限值
		$"进度".value = 当前数量
		$"进度".show_percentage=false
		if 背包内数量>=1:
			%"显示数量".text="存:"+str(背包内数量)
			%"显示数量".visible=true
		else :
			%"显示数量".visible=false
	var 回复速度=资源回复速度.get(资源名称,0)
	if 回复速度==0:
		$"进度".size=Vector2(400,50)
		$"回复".visible=false
		%"刻度".更新进度条参数(上限值,400)
	else :
		var 宽度=int(%"显示数量".get_combined_minimum_size().x)
		$"进度".size=Vector2(400-宽度,50)
		$"回复".visible=true
		$"回复".text= "+%.1f" % 回复速度
		%"刻度".更新进度条参数(上限值,400-宽度)
func 点击逻辑(event: InputEvent):
	if is_inside_tree():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:# 仅响应鼠标左键事件
			if event.pressed:
				# 鼠标按下时处理
				处理按下()
			else:
				# 鼠标释放时处理
				处理释放()
func 更新贴图():
	if not is_inside_tree():# 编辑器内安全检查：确保节点已加入场景树，避免空引用错误
		print("节点未加入节点树")
		return
	var 贴图节点 = $贴图
	$"文本".text=str(资源名称)
	if not 贴图节点:# 确保TextureRect节点存在
		print("警告：未找到「贴图」节点，请检查节点路径")
		return
	if Engine.is_editor_hint():
		var 纹理 = 梅手工.new().资源字典.get(资源名称,{"贴图":null})["贴图"]
		贴图节点.texture = 纹理
	else :
		var 纹理 = 计划.手工.资源字典.get(资源名称,{"贴图":null})["贴图"]
		if 纹理:
			$"资源粒子".emitting=false
		贴图节点.texture = 纹理
		$"资源粒子".texture = 纹理
	
func 处理按下():
	#更新点击回复量()
	if 基础量>0:
		计划.手工.获得资源(资源名称, 基础量 * 5, true, true)# 点击立即回复5倍基础量资源
		是否长按 = true# 标记为长按状态并启动计时器
		长按计时器.start()
		$"资源粒子".amount=10
		$"资源粒子".amount_ratio=0.25
		$"资源粒子".preprocess=0.5
		$"资源粒子".emitting=true
	else :计划.语法糖通知("不能通过点击回复:"+资源名称,"资源回复")
func 处理释放():# 结束长按状态但不停止计时器
	是否长按 = false
func 长按超时处理():
	#print(资源名称,"长按超时处理",是否长按)
	if 是否长按:# 长按期间每0.5秒回复1倍基础量资源
		if not $"资源粒子".emitting:
			$"资源粒子".emitting=true
			$"资源粒子".preprocess=0
			$"资源粒子".amount_ratio=0.3
		计划.手工.获得资源(资源名称, 基础量, true, true)# 每0.5秒回复一次基础量资源
	else :
		长按计时器.stop()
