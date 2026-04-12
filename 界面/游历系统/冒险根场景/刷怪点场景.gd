@tool
extends Area2D
class_name 梅刷怪点场景
@export var 刷怪数据:刷怪点信息包=null
@export var 启用保存:bool=false:
	set(值):
		if 值:
			启用保存 = false
			保存刷怪点()
@onready var 触发范围: CollisionShape2D = %触发范围
@onready var 视角限制: Marker2D = %视角限制
@onready var 刷怪偏移: Node2D = %刷怪偏移
##运行时赋值
var 实体:Node2D
func _ready() -> void:
	if Engine.is_editor_hint():
		安全检查()
func 安全检查()->bool:
	if not 刷怪数据:
		刷怪数据=刷怪点信息包.new()
	if 触发范围:
		if not 触发范围.shape or not 触发范围.shape is RectangleShape2D:
			触发范围.shape=RectangleShape2D.new()
		else :
			触发范围.shape=触发范围.shape.duplicate()
	else :
		print("警告,触发范围节点错误")
		return false
	return true
func 保存刷怪点():
	if not 安全检查():
		return
	刷怪数据.刷怪点位置=position
	刷怪数据.触发偏移=触发范围.position
	var 碰撞:=触发范围.shape as RectangleShape2D
	刷怪数据.触发范围=碰撞.size
	刷怪数据.视角限制=视角限制.position
	var 刷怪点:Array[Vector2]=[]
	刷怪数据.刷怪点偏移=刷怪点
	for 节点 in 刷怪偏移.get_children():
		if 节点 is Marker2D:
			刷怪点.append(节点.position)
##自动执行
func 加载数据():
	if not 安全检查():
		return
	position=刷怪数据.刷怪点位置
	触发范围.position=刷怪数据.触发偏移
	触发范围.碰撞.size=刷怪数据.触发范围
	视角限制.position=刷怪数据.视角限制
	var 刷怪点:Array[Vector2]=刷怪数据.刷怪点偏移
	var 序号:int=0
	计划.清除子节点(刷怪偏移)
	for 坐标:Vector2 in 刷怪点:
		var 节点:=Marker2D.new()
		if Engine.is_editor_hint():
			节点.name="偏移点%d"%序号
			节点.owner=self
		刷怪偏移.add_child(节点)
		序号+=1
