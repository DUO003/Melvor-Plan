extends GridContainer
var 原始配方节点 = null
func _ready():
	原始配方节点 = $"配方"
@onready var 已解锁按钮: CheckButton = %已解锁
@onready var 检索: LineEdit = %检索
func 克隆配方节点(配方列表=["铁锭", "纤维", "鞣革"], 原始节点=原始配方节点):# 根据配方列表数量克隆节点
	var 编号数组= 计划.表格.获取表格信息数组(计划.表格.创世蓝图,配方列表,"名称")
	#print("编号数组",编号数组)
	for i in range(配方列表.size()):
		var 配方名称=配方列表[i]
		if not 检索.text=="":
			if not 检索.text in 配方名称:
				continue
		var 配方编号=int(编号数组[i])
		var 克隆节点:Button = 原始节点.duplicate()
		克隆节点.name = "配方" + str(i + 1)  # 命名为配方1、配方2...
		克隆节点.visible = true  # 克隆节点设为可见
		var 配方名标签 = 克隆节点.get_node("配方名")# 获取克隆节点下的"配方名"Label节点并设置文本
		var 解锁=false
		if 配方名标签 != null and 配方名标签 is Label:
			if 配方解锁(配方名称):
				配方名标签.text = 配方列表[i]
				var 配方等级 = 计划.手工.数据合成配方(配方名称,"等级")
				var 残缺配方 = 计划.手工.数据合成配方(配方名称,"残缺图纸数量")
				if 残缺配方==0:
					克隆节点.text=""
				else:
					if 配方等级==-1:
						克隆节点.text="残缺图纸*"+str(残缺配方)+"\n\n\n\n"
					else:
						克隆节点.text="研究残缺*"+str(残缺配方)+"\n\n\n\n"
				if not 配方等级==-1:
					解锁=true
			else :
				克隆节点.text=""
				配方名标签.text = "未解锁"
		处理样式(克隆节点,配方名称,解锁)
		克隆节点.mouse_entered.connect(func(): 鼠标进入(配方编号))# 连接鼠标进入信号
		克隆节点.mouse_exited.connect(func(): 鼠标离开(配方编号))# 连接鼠标离开信号
		克隆节点.gui_input.connect(func(按键信号): # 确保节点可以接收鼠标事件
			if 按键信号 is InputEventMouseButton and 按键信号.pressed:
				鼠标点击(配方编号, 按键信号))
		克隆节点.mouse_filter = Control.MOUSE_FILTER_STOP
		克隆节点.focus_mode = Control.FOCUS_NONE
		if 已解锁按钮.button_pressed:
			if 解锁:add_child(克隆节点)
		else :
			add_child(克隆节点)
	if get_children().size()==1:
		计划.语法糖通知("请调整筛选条件,当前没有符合条件的蓝图")
# 功能：复制 Button 节点的 normal 原始样式，修改后批量赋值给 pressed/hover/focus 状态
# 参数1：节点 - 目标 Button 节点（如你的“克隆节点”）
# 参数2：图片 - 要替换的图片路径（例："res://images/btn_bg.png"）
func 处理样式(节点: Button, 配方名称: String, 解锁: bool) -> void:
	var 纹理 = 计划.表格.道具贴图(配方名称)# 1. 加载图片
	var 样式 = 节点.get_theme_stylebox("normal").duplicate(true)# 2. 复制样式模板
	样式.样式数组[2].texture = 纹理# 3. 修改复制后的基础样式（统一替换图片）
	if 解锁:# 4. 根据解锁状态设置调制颜色（白色/暗灰色）
		样式.样式数组[2].modulate_color =Color(1, 1, 1)
	else :
		样式.样式数组[2].modulate_color =Color(0.2, 0.2, 0.2)
	for state in ["normal", "pressed", "hover", "focus"]:# 5. 批量将修改后的基础样式，赋值给所有需要同步的状态
		节点.add_theme_stylebox_override(state, 样式)
# 鼠标进入事件处理方法
func 鼠标进入(配方序号):
	# 记录当前配方序号
	#print("配方序号: " , 配方序号)
	%悬浮面板.配方序号 = 配方序号
# 鼠标离开事件处理方法
func 鼠标离开(配方序号):
	# 只有当离开的是当前正在显示的配方时才隐藏
	if 配方序号 == %悬浮面板.配方序号:
		%悬浮面板.配方序号 = 0
# 鼠标事件处理方法
func 鼠标点击(配方序号,按键信号):
	var 装备名称 = 计划.表格.创世蓝图[配方序号][0]
	if 按键信号.button_index == MOUSE_BUTTON_LEFT:
		if 配方解锁(装备名称):
			if 制作物品(配方序号)!=1:
				计划.语法糖通知("材料不足，无法制作","手工提示")
		else:
			计划.语法糖通知( "配方未解锁，无法制作","手工提示")
	elif 按键信号.button_index == MOUSE_BUTTON_RIGHT:
		计划.手工.队列合成("制作队列",装备名称)
	else :
		计划.语法糖通知( "中键点击","手工提示")

func 制作物品检查(表格字典):
	if 表格字典 == {}:
		return 0.0  # 配方不存在，返回0进度
	var 材料权重 = {"零件": 3,"精华": 9}# 定义材料权重配置
	var 物品名称 = 表格字典.get("名称", "")
	if 物品名称 == "":
		print("配方错误")
		return 0.0  # 配方错误返回0进度
	var 材料类型列表 = 计划.手工.资源字典.keys()# 定义需要消耗的材料类型
	var 材料足够 = true
	var 总需求权重 = 0.0
	var 当前满足权重 = 0.0
	var 配方升星=计划.手工.数据合成配方(物品名称,"升星")
	# 检查材料并计算权重
	for 材料类型 in 材料类型列表:
		var 所需数量 = float(表格字典.get(材料类型, 0))
		if 配方升星 >= 1:所需数量*=0.9
		if 所需数量 > 0:
			var 当前数量 = 计划.手工.查看资源(材料类型)+计划.检查背包物品数量(材料类型)
			#print(材料类型,":",当前数量,"/",所需数量,"资源:",计划.手工.查看资源(材料类型))
			var 权重 = 材料权重.get(材料类型, 1)# 获取材料权重，默认为1
			总需求权重 += 所需数量 * 权重# 累计总需求权重
			var 满足数量 = min(当前数量, 所需数量)
			当前满足权重 += 满足数量 * 权重# 累计当前满足的权重（不超过需求）
			if 当前数量 < 所需数量:# 检查是否足够
				材料足够 = false
	if 材料足够:
		return 1.0  #返回1
	else:# 计算进度（避免除零错误）
		var 进度 = 0.0
		if 总需求权重 > 0:
			进度 = 当前满足权重 / 总需求权重
			进度 = clamp(进度, 0.0, 1.0)  # 确保进度在0-1范围内
		return 进度


func 制作物品(配方序号):
	var 表格字典 = 计划.表格.获取表格字典(计划.表格.创世蓝图, 配方序号)# 获取配方对应的物品表格数据
	var 进度 = 制作物品检查(表格字典)
	#print("表格字典:",表格字典)
	if 进度==1.0:
		var 物品名称 = 表格字典.get("名称", "")
		var 材料类型列表 = 计划.手工.资源字典.keys()# 定义需要消耗的材料类型
		for 材料类型 in 材料类型列表:# 扣除所需材料
			var 所需数量 = 表格字典.get(材料类型, 0)
			计划.手工.获得资源(材料类型, -所需数量, true, false)
		计划.手工.完成制作(物品名称)
		计划.emit_signal("更新_UI")
		return 1.0  # 制作成功返回1
	else:
		return 进度

func 配方解锁(配方名称):
	var 配方等级 = 计划.手工.数据合成配方(配方名称)
	var 残缺配方 = 计划.手工.数据合成配方(配方名称,"残缺图纸数量")
	if 配方等级>=0 or 残缺配方>=1:
		return true
	return false
