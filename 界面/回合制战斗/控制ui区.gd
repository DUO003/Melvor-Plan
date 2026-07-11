# 回合制控制区UI脚本 梅控制区_回合制
extends ScrollContainer
class_name 梅控制区_回合制

# 节点绑定
@onready var 启用自动: CheckBox = %启用自动
@onready var 索敌菜单: OptionButton = %索敌菜单
@onready var 技能区: GridContainer = %技能区

@export var 回合管理器:梅回合管理器
var 技能按钮场景: = preload("res://界面/回合制战斗/技能按钮.tscn")

# 当前选中战斗实体
var 选中实体:梅回合制实体 = null

# 外部枚举简写
var 枚举数据 = 梅技能数据_回合制

func _ready() -> void:
	if not 回合管理器:
		print("警告,控制找不到管理器")
		return
	# 2. 第一步：用字典映射刷新下拉菜单所有选项
	刷新索敌菜单选项()
	
	启用自动.toggled.connect(_自动按钮切换)
	索敌菜单.item_selected.connect(_索敌菜单切换)
	回合管理器.回合开始.connect(回合更新处理)
	回合管理器.回合结束.connect(回合更新处理)
func 回合更新处理(行动实体:梅回合制实体):
	if 行动实体 and 选中实体 and 行动实体==选中实体:
		var 待刷新技能按钮:=技能区.get_children()
		for 技能按钮 in 待刷新技能按钮:
			if not 技能按钮:
				break
			if 技能按钮 is 梅技能按钮_回合制:
				技能按钮._更新技能状态()
		
# 核心入口：战斗开始时调用此方法，传入目标实体
func 重载控制区(更新实体:梅回合制实体) -> void:
	# 1. 赋值当前操作实体
	选中实体 = 更新实体
	if 选中实体 == null:
		索敌菜单.disabled = true
		启用自动.disabled = true
		return
	else :
		索敌菜单.disabled = false
		启用自动.disabled = false
	#同步当前实体的自动战斗设置
	启用自动.button_pressed=选中实体.自动战斗
	#读取实体自身的选择方式枚举
	同步菜单选中至实体选择方式()
	#同步技能
	同步技能列表()

# 功能1：清空并重新填充索敌下拉菜单文本
func 刷新索敌菜单选项() -> void:
	索敌菜单.clear()
	# 遍历字典，按枚举顺序添加选项
	for 枚举键 in 枚举数据.选择字典映射:
		var 显示文本 = 枚举数据.选择字典映射[枚举键]
		索敌菜单.add_item(显示文本)
		# 把原始枚举值存入item_metadata，方便反向匹配
		索敌菜单.set_item_metadata(索敌菜单.get_item_count() - 1, 枚举键)

# 功能2：根据选中实体的「选择方式」枚举，自动选中下拉对应项
func 同步菜单选中至实体选择方式() -> void:
	if 选中实体 == null:
		return
	var 当前索敌枚举 = 选中实体.选择方式
	
	# 遍历所有菜单条目，匹配metadata里存的枚举值
	for 索引 in range(索敌菜单.get_item_count()):
		var 条目枚举值 = 索敌菜单.get_item_metadata(索引)
		if 条目枚举值 == 当前索敌枚举:
			索敌菜单.selected = 索引
			break

#同步技能
func 同步技能列表():
	var 技能列表:=选中实体.技能列表.duplicate()
	技能列表.append(梅技能数据_回合制.new())
	print("技能列表",技能列表)
	梅加载.工具.清除子节点(技能区)
	for 技能资源 in 技能列表:
		var 技能按钮实例:=技能按钮场景.instantiate()
		if 技能按钮实例 is  梅技能按钮_回合制:
			技能按钮实例.技能资源=技能资源
			技能按钮实例.选择当前技能.connect(_检查技能可用性.bind(技能资源))
			技能区.add_child(技能按钮实例)
		else :
			print("警告,技能按钮类型错误")
			return
func _检查技能可用性(技能:梅技能数据_回合制):
	if not 选中实体:
		print("控制区找不到实体")
		return
	if 技能.检查技能可用状态(选中实体):
		回合管理器._选择技能方法(技能)
	else :
		print("技能不可用")
		
func _自动按钮切换(新状态:bool):
	if not 选中实体:
		print("控制区找不到实体")
		return
	选中实体.自动战斗 = 新状态
# 索敌下拉菜单切换事件，玩家选择后同步赋值给当前选中实体
func _索敌菜单切换(选中索引: int) -> void:
	# 无选中实体直接退出
	if 选中实体 == null:
		return
	# 从选中条目读取预存的枚举元数据
	var 目标索敌方式: 梅技能数据_回合制.选择枚举 = 索敌菜单.get_item_metadata(选中索引)
	# 将下拉选择的枚举赋值给实体的选择方式字段
	选中实体.选择方式 = 目标索敌方式
	var 显示文本:String = 枚举数据.选择字典映射[目标索敌方式]
	print("更新索敌方式为:%s"%显示文本)
