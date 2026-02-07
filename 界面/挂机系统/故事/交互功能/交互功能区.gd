@tool
extends Sprite2D
class_name 交互功能区
@export var 交互代码:String=""
@export var 检查:bool=true
@export var 检查范围:Rect2=Rect2(0,0,0,0):
	set(值):
		检查范围 = 值
		if Engine.is_editor_hint() and is_inside_tree() and 检查:
			修改判断区(进入判断区,检查范围)
@export var 强制:bool=false
@export var 强制范围:Rect2=Rect2(0,0,0,0):
	set(值):
		强制范围 = 值
		if Engine.is_editor_hint() and is_inside_tree() and  检查 and 强制:
			修改判断区(强制判断区,强制范围)
@onready var 进入判断区: 通用交互区域 = $进入判断区
@onready var 强制判断区: 通用交互区域 = $强制判断区
func _ready() -> void:
	if 检查:
		修改判断区(进入判断区,检查范围)
	if 检查 and 强制:
		修改判断区(强制判断区,强制范围)
##修改判定范围
func 修改判断区(节点: Area2D, 范围: Rect2) -> void:
	if not 节点:# 安全校验：确保传入的节点不为空
		print("错误：传入的Area2D节点为空")
		return
	var 范围节点: CollisionShape2D = 节点.get_node_or_null("范围")
	if not 范围节点:# 尝试获取名为"范围"的CollisionShape2D子节点
		print("错误：未找到名为'范围'的CollisionShape2D子节点")
		return
	var 判定范围区: RectangleShape2D = 范围节点.shape as RectangleShape2D
	if not 判定范围区:# 校验Shape是否为RectangleShape2D类型
		print("错误：CollisionShape2D的Shape不是RectangleShape2D类型")
		return
	判定范围区.size = 范围.size
	范围节点.position = 范围.position
func 执行方法():
	print(交互代码)
func 延迟切换(窗口):
	计划.切换场景(窗口)
