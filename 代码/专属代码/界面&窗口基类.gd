extends Control
class_name 基类梅窗口#逐渐改使用基类 当前大部分窗口未使用
@export var 基类窗口名称:String=""#所有继承者必须重写这个
@export_multiline var 提示文本: Array[String] = []#非强制
var 生命周期计时器: Array[Timer]
func _ready() -> void:
	assert(基类窗口名称 != "", "基类窗口名称不能为空，所有继承者必须重写这个属性")
	初始化.节点[基类窗口名称]=self#注册
func _exit_tree() -> void:
	if 初始化.节点.has(基类窗口名称):# 安全检查：确保字典中存在该键再移除
		初始化.节点.erase(基类窗口名称)
	for 计时器 in 生命周期计时器:
		计时器.queue_free()
func 清除子节点(节点容器,保留节点=null):
	print("清除节点执行")
	for 节点 in 节点容器.get_children():
		if 保留节点==null or 节点!=保留节点:
			节点容器.remove_child(节点)
			节点.queue_free()
			print("清除节点成功")
func 定期更新提示文本(目标文本节点):
	if 目标文本节点 == null:
		return
	elif 提示文本.size() == 0:
		目标文本节点.text = "温馨提示"
		return
	elif 提示文本.size() == 1:
		目标文本节点.text = 提示文本[0]
		return
	var 当前显示文本 = 目标文本节点.text# 4. 数组有多条文本时，选择与当前文本不同的提示
	var 可选提示列表 = 提示文本.filter(func(单条提示):# 过滤出与当前文本不同的可选提示
		return 单条提示 != 当前显示文本)
	if 可选提示列表.size() > 0:# 5. 从可选提示中随机选择一条（若所有提示都与当前相同，则随机选数组中任意一条）
		var 随机索引 = randi() % 可选提示列表.size()
		目标文本节点.text = 可选提示列表[随机索引]
	else:# 极端情况：数组所有元素相同（虽不符合常规，但做兼容处理）
		目标文本节点.text = 提示文本[0]
func 节点有效性检查(节点名称:String)->bool:
	return 节点名称 in 初始化.节点 and 初始化.节点[节点名称] != null
