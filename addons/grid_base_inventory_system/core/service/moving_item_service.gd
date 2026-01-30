extends Node
## 移动物品业务类
class_name MovingItemService

## 正在移动的物品
var moving_item: ItemData
## 正在移动的物品View
var moving_item_view: ItemView
## 正在移动的物品的偏移（例：一个2*2的物品，点击左上角移动时，偏移是[0,0]，点击右下角移动时，偏移是[1,1]）
var moving_item_offset: Vector2i = Vector2i.ZERO
## 丢弃物品检测区域
var drop_area_view: DropAreaView

## 顶层，用于展示移动物品的View
var _moving_item_layer: CanvasLayer

## 获取顶层，没有则新建
func get_moving_item_layer() -> CanvasLayer:
	if not _moving_item_layer:
		_moving_item_layer = CanvasLayer.new()
		_moving_item_layer.layer = 128
		GBIS.get_root().add_child(_moving_item_layer)
	return _moving_item_layer

## 清除正在移动的物品(不会删除版)
func 安全清除移动物品() -> void:
	if moving_item != null:
		var 背包类型 = "背包"
		if moving_item is 物品装备:
			背包类型 = "装备"
		elif moving_item is 物品宝石:
			背包类型 = "宝石"
		elif moving_item is 物品方块:
			背包类型 = "方块背包"
		else :
			背包类型 = "背包"
		if moving_item is StackableData:
			if moving_item.数量<=0:
				clear_moving_item()
				return
		GBIS.add_item(背包类型, moving_item)
		clear_moving_item()
func clear_moving_item() -> void:
	for o in _moving_item_layer.get_children():
		o.queue_free()
	moving_item = null
	moving_item_view = null
	if drop_area_view:
		drop_area_view.hide()
	GBIS.更新移动物品.emit()
# 根据物品数据执行物品移动逻辑（用于鼠标拖拽物品等交互场景）
# 参数说明：
# item_data: 要移动的物品核心数据对象（ItemData类型）
# offset: 物品移动的偏移量（基于鼠标位置的二维整数向量）
# base_size: 物品视图的基础尺寸大小
# 背包本体: 可选参数，对应的背包容器实例，默认为null
func move_item_by_data(item_data: ItemData, offset: Vector2i, base_size: int,背包本体=null) -> void:
	# 记录当前正在移动的物品数据
	self.moving_item = item_data
	# 记录当前移动物品的偏移量（用于同步鼠标位置）
	self.moving_item_offset = offset
	# 创建移动物品的可视化视图实例，传入物品数据和基础尺寸
	self.moving_item_view = ItemView.new(item_data, base_size)
	#print("背包本体",背包本体)
	# 通过GBIS单例发送"鼠标持有物品"的信号，参数true表示开始持有物品,与背包隐藏相关
	GBIS.鼠标物品.emit(true)
	#通用信号
	GBIS.更新移动物品.emit()
	# 判断背包本体不为空，且是基础容器视图（BaseContainerView）的实例
	if 背包本体!=null and 背包本体 is BaseContainerView:
		# 同步背包本体的基础尺寸到移动物品视图
		moving_item_view.base_size = 背包本体.base_size
		# 同步背包本体的物品堆叠数量文字颜色
		moving_item_view.stack_num_color = 背包本体.stack_num_color
		# 同步背包本体的物品堆叠数量文字字体
		moving_item_view.stack_num_font = 背包本体.stack_num_font
		# 同步背包本体的物品堆叠数量文字字号
		moving_item_view.stack_num_font_size = 背包本体.stack_num_font_size
		# 同步背包本体的物品堆叠数量文字边距
		moving_item_view.stack_num_margin = 背包本体.stack_num_margin
	else :
		moving_item_view.stack_num_font_size =20
		moving_item_view.stack_num_color =Color(0,0,0)
	# 获取移动物品的专属显示层级，并将物品视图添加到该层级（确保在最上层显示）
	get_moving_item_layer().add_child(moving_item_view)
	get_moving_item_layer().add_child(右键取消物品.new())
	# 将移动物品视图移动到指定偏移位置（与鼠标位置对齐）
	moving_item_view.move(offset)
	# 如果存在物品放置区域视图
	if drop_area_view:
		# 显示放置区域视图（用于提示用户可放置物品的位置）
		drop_area_view.show()

# 通过背包格子信息执行物品移动（拖拽取出背包物品的核心逻辑）
# 参数说明：
# inv_name: 背包名称（用于唯一标识对应的背包实例）
# grid_id: 物品所在的背包格子坐标（二维整数向量，对应背包内的格子位置）
# offset: 物品移动的偏移量（基于鼠标位置，确保物品视图与鼠标指针对齐）
# base_size: 物品可视化视图的基础尺寸大小
# 背包本体: 可选参数，对应的背包容器实例，默认为null
func move_item_by_grid(inv_name: String, grid_id: Vector2i, offset: Vector2i, base_size: int,背包本体=null) -> void:
	# 检查是否已经存在正在移动的物品，避免重复拖拽操作
	if moving_item:
		# 若已存在移动物品，抛出错误提示信息并终止函数
		push_error("Already had moving item.")
		return
	# 根据背包名称和格子坐标，从背包服务中查询对应物品的核心数据
	var item_data = GBIS.inventory_service.find_item_data_by_grid(inv_name, grid_id)
	# 检查是否成功获取到物品数据（避免对空数据进行后续操作）
	if item_data:
		# 调用物品数据移动函数，创建并显示物品移动视图
		move_item_by_data(item_data, offset, base_size,背包本体)
		# 从对应背包中移除该物品数据（实现物品从背包中取出的逻辑）
		GBIS.inventory_service.remove_item_by_data(inv_name, item_data)
		# 检查是否存在物品放置区域视图
		if drop_area_view:
			# 显示放置区域视图，提示用户当前可放置物品的区域
			drop_area_view.show()
