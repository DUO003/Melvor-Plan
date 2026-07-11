extends Node2D
class_name 梅回合制实体
@export var 血量:int=100:
	set(值):
		血量=值
		_更新血条()
		if 血量<=0:死亡信号.emit()
@export var 蓝量:int=100:
	set(值):
		蓝量=值
		_更新蓝条()
@export var 最大血量:int=100
@export var 最大蓝量:int=100
@export var 速度:int=10
@export var 攻击力:int=10
##外观信息
@export var 贴图:Texture=preload("res://icon.svg")
##阵容信息
@export var 阵营:StringName=""
@export var 排号:int=0
##随时变化的排号
@export var 实时排号:int=0
@export var 站位:Vector2=Vector2.ZERO

##自动
@export var 自动战斗:bool=true
##接下来会攻击什么阵营的对手(双阵营时无须选择)
@export var 攻击目标:StringName=""
##当攻击时选择目标是null会根据选择方式来获取一次选择目标[br]
@export var 选择方式:梅技能数据_回合制.选择枚举=梅技能数据_回合制.选择枚举.距离最近
##手动选择目标时避免重选,自动选择目标时回合结束会清空选择目标,手动选择目标死亡时会复位
@export var 重选目标:bool=false
##接下来要普通攻击的目标,如果为null会触发筛选目标逻辑(技能使用另外的逻辑)
@export var 选择目标:梅回合制实体=null
##手动选择技能
@export var 手动选择技能:梅技能数据_回合制=null
## 在检查器里手动填，比如精灵图片的宽度
@export var 角色宽度: float = 32.0
#region 技能参数
## 当前实体拥有的技能
@export var 技能列表:Array[梅技能数据_回合制]=[]
## 当前实体自动释放的技能
@export var 技能自动释放:Array[梅技能数据_回合制]=[]
#endregion 技能参数

var 回合管理器:梅回合管理器
@onready var 血条节点: ProgressBar = %"血条"
@onready var 血条血量: Label = %血条血量
@onready var 测试按钮: Button = %"测试"
@onready var 蓝条节点: ProgressBar = %蓝条
@onready var 蓝条蓝量: Label = %蓝条蓝量
@onready var 图片: Sprite2D = %图片
signal 死亡信号
func _ready() -> void:
	实体初始化()
	测试按钮.pressed.connect(测试功能)
func 测试功能():
	血量-=10
func 实体初始化():
	if not 血条节点:
		print("错误,血条节点不存在")
		return
	if not 蓝条节点:
		print("错误,蓝条节点不存在")
		return
	血条节点.max_value=最大血量
	血量=最大血量
	蓝条节点.max_value=最大蓝量
	蓝量=最大蓝量
	图片.texture=贴图
	图片.scale=梅加载.工具.计算纹理缩放倍率(贴图,124,124)
func _更新血条():
	if not 血条节点:
		print("错误,血条节点不存在")
		return
	血条节点.value=血量
	血条血量.text="%d/%d"%[血量,最大血量]
func _更新蓝条():
	if not 蓝条节点:
		print("错误,蓝条节点不存在")
		return
	蓝条节点.value=蓝量
	蓝条蓝量.text="%d/%d"%[蓝量,最大蓝量]
var 敌对字典:Dictionary={"友方":["敌方"],"敌方":["友方"]}

func 获取敌对目标()->梅回合制实体:
	var 敌对目标数组: Array = 敌对字典[阵营]
	var 分组名称: StringName = 敌对目标数组[0]
	var 目标数组: Array = 返回节点列表(分组名称)
	if 目标数组.is_empty():
		print("警告,敌人不存在")
		return
	for 目标 in 目标数组:
		if 目标 and 目标 is 梅回合制实体:
			return 目标
	print("警告筛续敌人错误")
	return
var 火球术: = preload("res://界面/技能效果/火球术.tscn")

func 回合行动() -> void:
	##定义动画速度
	var 行动倍率:float=0.5
	# 指定要执行的技能
	手动选择技能 = null  # 清空，避免下次误用
	var 执行技能:梅技能数据_回合制=null
	if 自动战斗:
		执行技能=筛选技能()
	else :
		# 等待玩家选择技能
		await 回合管理器.确认选择技能
		执行技能 = 手动选择技能
	蓝量-=执行技能.魔法消耗
	var 敌人: 梅回合制实体 = 获取敌对目标()
	# 根据枚举分发不同动画逻辑，并等待动画全部跑完
	match 执行技能.攻击动画枚举:
		梅技能数据_回合制.动画枚举.火球术:
			await 执行火球术动画(敌人,执行技能, 行动倍率)
		_:
			await 执行近战动画(敌人,执行技能, 行动倍率)
	print("单位动作协程结束")
func 筛选技能() -> 梅技能数据_回合制:
	for 技能 in 技能列表:
		if 技能.检查技能可用状态(self):
			return 技能
	return 梅技能数据_回合制.new()
func 触发技能(目标敌人: 梅回合制实体, 执行技能: 梅技能数据_回合制) -> void:
	# 基础伤害：攻击力 × 技能倍率（倍率随等级成长）
	var 基础倍率 := 执行技能.基础威力 + 执行技能.技能等级 * 执行技能.基础成长
	var 基础伤害 := 攻击力 * 基础倍率
	# 增幅伤害：固定数值加伤（随等级成长）
	var 增幅数值 := 执行技能.增幅威力 + 执行技能.技能等级 * 执行技能.增幅成长
	# 总伤害：浮点全部算完再统一取整
	var 总伤害 := int(基础伤害 + 增幅数值)
	目标敌人.血量 -= 总伤害
	print("造成伤害，剩余HP:", 目标敌人.血量)
	if 执行技能.间隔回合>=0:
		执行技能.冷却进度=执行技能.间隔回合
	else :#执行其他技能冷却
		for 技能 in 技能列表:
			if 技能.冷却进度 > 0:
				技能.冷却进度+=执行技能.间隔回合
# 抽离独立近战动画协程，外部await等待执行完毕
func 执行近战动画(目标敌人:梅回合制实体,执行技能:梅技能数据_回合制, 动画倍率:float) -> void:
	var 原始位置: Vector2 = 站位
	var 目标全局位置: Vector2 = 目标敌人.站位
	# 计算动态落点
	var 横向间距: float = (self.角色宽度 + 目标敌人.角色宽度) * 0.5 + 10
	if 原始位置.x < 目标敌人.站位.x:
		目标全局位置.x -= 横向间距
	else:
		目标全局位置.x += 横向间距
	# 创建补间动画序列
	var 补间动画: Tween = create_tween()
	# 向前移动
	补间动画.tween_property(self, "global_position", 目标全局位置, 0.4 * 动画倍率).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# 停顿
	补间动画.tween_interval(0.1 * 动画倍率)
	# 扣伤害回调
	补间动画.tween_callback(触发技能.bind(目标敌人,执行技能))
	# 复位回原位置
	补间动画.tween_property(self, "global_position", 原始位置, 0.4 * 动画倍率).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# 等待整套近战动画结束
	await 补间动画.finished
## 阵容移位动画：移动到已更新的站位坐标，基准时长固定2秒
func 更新位置世界(动画倍率:float = 1.0) -> void:
	# 记录当前实体实际世界坐标
	var 当前坐标: Vector2 = global_position
	var 目标坐标: Vector2 = 站位

	# 坐标无变化，直接退出无需动画
	if 当前坐标.is_equal_approx(目标坐标):
		return

	# 基准时长2秒，乘倍率缩放速度
	var 基准时长: float = 2.0
	var 实际时长: float = 基准时长 * 动画倍率

	var 移位补间: Tween = create_tween()
	# 平滑移动至新站位，缓动可按需调整
	移位补间.tween_property(self, "global_position", 目标坐标, 实际时长).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# 外部await此函数即可等待移位动画结束
	await 移位补间.finished
# 火球术动画协程
func 执行火球术动画(目标敌人:梅回合制实体,执行技能:梅技能数据_回合制, 动画倍率:float) -> void:
	var 原始位置: Vector2 = self.global_position
	var 敌人位置:Vector2=目标敌人.global_position
	# 1. 获取特效父节点
	var 特效父节点: Node2D = 回合管理器.动画特效
	if not 特效父节点:
		print("错误：未找到回合管理器下的动画特效节点")
		return
	# 2. 计算火球实际飞行时长：标准2秒 * 倍率
	var 标准火球时长 = 2.0
	var 实际飞行时长 = 标准火球时长 * 动画倍率
	# 3. 实例化火球并挂载到特效节点
	var 火球实例:梅平移补间控制器 = 火球术.instantiate()
	特效父节点.add_child(火球实例)
	# 4. 调用火球初始化方法，指定二次缓入
	火球实例.初始化(
		敌人位置,
		原始位置,
		实际飞行时长,
		梅平移补间控制器.缓动模式.二次缓入)
	# 5. 创建信号等待器，监听火球播放完成信号
	火球实例.抵达目标.connect(触发技能.bind(目标敌人,执行技能))
	await 火球实例.动画播放完成
	# 动画结束销毁火球，避免残留
	火球实例.queue_free()
	
# 根据分组名返回节点列表
func 返回节点列表(分组名称: String):
	return get_tree().get_nodes_in_group(分组名称)
