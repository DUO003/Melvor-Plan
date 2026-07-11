extends MarginContainer
class_name 梅技能按钮_回合制

@onready var 技能图标: TextureRect = %"技能图标"
@onready var 技能冷却: TextureRect = %技能冷却
@onready var 技能按钮: Button = %"技能按钮"
@onready var 蓝耗: Label = %蓝耗
@onready var 冷却: Label = %冷却
@onready var 技能名称: Label = %技能名称
@export var 技能资源:梅技能数据_回合制=null
signal 选择当前技能()
var 技能可用: bool = true
func _更新技能状态():
	if not(技能图标 or 技能按钮 or 技能冷却):
		return
	技能按钮.disabled = not 技能可用
	技能图标.mouse_filter = Control.MOUSE_FILTER_STOP if 技能可用 else Control.MOUSE_FILTER_IGNORE
	if 技能资源:
		var 冷却百分比: float
		# 兼容间隔回合为0、负数的异常情况
		if 技能资源.间隔回合 <= 0:
			冷却百分比 = 0
		else:
			冷却百分比 = float(技能资源.冷却进度) / float(技能资源.间隔回合)
		#print("%s | 计算冷却百分比: %.1f | 进度/总回合: %d/%d" % [技能资源.技能名称, 冷却百分比, 技能资源.冷却进度, 技能资源.间隔回合])
		if not 技能冷却:
			print("错误：找不到技能冷却遮罩节点")
			return
		if not 技能冷却.material:
			print("错误：技能冷却节点没有材质")
			return
		if not 技能冷却.material.get_shader():
			print("错误：材质未挂载着色器")
			return
		
		# 赋值给着色器参数
		技能冷却.material.set_shader_parameter("cool_down_progress", 1-冷却百分比)
		# 立刻读回参数打印，验证是否写入成功
		#var 着色器实际值 = 技能冷却.material.get_shader_parameter("cool_down_progress")
		#print("%s | 着色器当前cool_down_progress实际值: %.4f" % [技能资源.技能名称, 着色器实际值])
	
	
func _ready() -> void:
	#独立着色器
	技能冷却.material=技能冷却.material.duplicate(true)
	_更新技能状态()
	技能按钮.pressed.connect(选择当前技能.emit)
	if 技能资源:
		技能图标.texture=技能资源.技能图标
		技能名称.text=技能资源.技能名称
		蓝耗.text="魔法:%d"%技能资源.魔法消耗
		if 技能资源.间隔回合<=0:
			冷却.text="冷却:无"
		else :
			冷却.text="冷却:%d"%技能资源.间隔回合

func _技能图标_gui(按键: InputEvent) -> void:
	# 检查是否是鼠标左键按下事件
	if 按键 is InputEventMouseButton and 按键.button_index == MOUSE_BUTTON_LEFT and 按键.pressed:
		if 技能可用:
			选择当前技能.emit()
