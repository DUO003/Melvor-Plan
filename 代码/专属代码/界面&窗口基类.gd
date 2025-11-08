extends Control
class_name 基类梅窗口#逐渐改使用基类 当前大部分窗口未使用
@export var 基类窗口名称:String=""#所有继承者必须重写这个
func _ready() -> void:
	assert(基类窗口名称 != "", "基类窗口名称不能为空，所有继承者必须重写这个属性")
	初始化.节点[基类窗口名称]=self#注册
func _exit_tree() -> void:
	if 初始化.节点.has(基类窗口名称):# 安全检查：确保字典中存在该键再移除
		初始化.节点.erase(基类窗口名称)
func 清除子节点(节点容器,保留节点=null):
	print("清除节点执行")
	for 节点 in 节点容器.get_children():
		if 保留节点==null or 节点!=保留节点:
			节点容器.remove_child(节点)
			节点.queue_free()
			print("清除节点成功")
func 节点有效性检查(节点名称:String)->bool:
	return 节点名称 in 初始化.节点 and 初始化.节点[节点名称] != null
