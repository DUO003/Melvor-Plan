@tool
extends Control
## 装备槽视图
class_name EquipmentSlotView

## 装备槽的绘制状态：正常,可用,不可用
enum State{
	NORMAL, AVILABLE, INVILABLE
}
## 装备槽名称，如果重复则展示相同来源的数据
@export var slot_name: String = "装备":
	set(value):
		slot_name = value
		name=slot_name
		if Engine.is_editor_hint():
			_recalculate_size()
## 装备槽的绘制状态：正常,可用,不可用
enum 方向{内,上,下,左,右,左上,右上,左下,右下}
## 宝石槽方向,仅实现5个方向
@export var 宝石槽方向:方向=方向.内:
	set(值):
		宝石槽方向=值
		if Engine.is_editor_hint():
			queue_redraw()
## 宝石槽方向
@export var 宝石槽数量:int=1:
	set(值):
		if 值>4:宝石槽数量=4
		elif 值<0:宝石槽数量=0
		else :宝石槽数量 = 值
		if Engine.is_editor_hint():
			queue_redraw()
@export var 编辑器宝石图片: Texture2D=preload("res://icon.svg")
var 宝石数组:Array=[]
## 基础大小（格子大小）
@export var base_size: int = 32:
	set(value):
		base_size = value
		_recalculate_size()
## 列数（仅显示，与物品大小无关）
@export var columns: int = 2:
	set(value):
		columns = value
		_recalculate_size()
## 行数（仅显示，与物品大小无关）
@export var rows: int = 2:
	set(value):
		rows = value
		_recalculate_size()
## 背景图片
@export var 背景图: StyleBoxFlat:
	set(值):# 断开旧资源的信号连接
		if Engine.is_editor_hint():
			if 背景图 != null and 背景图.changed.is_connected(queue_redraw):
				背景图.changed.disconnect(queue_redraw)
		背景图 = 值
		if Engine.is_editor_hint():
			if 背景图 != null and not 背景图.changed.is_connected(queue_redraw):
				背景图.changed.connect(queue_redraw)# 连接新资源的信号
			queue_redraw()
## 可用时的颜色（推荐半透明）
@export var 可用背景: StyleBoxFlat:
	get:
		if 可用背景:
			return 可用背景
		var 背景
		if 背景图:
			背景=背景图.duplicate()
		else :
			背景=扩展的扁平样式框.new(扩展的扁平样式框.构建枚举.梅主题)
		背景.bg_color=Color(0.0, 1.0, 0.0, 0.502)
		可用背景=背景
		return 背景图
## 不可用时的颜色（推荐半透明）
@export var 不可用背景: StyleBoxFlat:
	get:
		if 不可用背景:
			return 不可用背景
		var 背景
		if 背景图:
			背景=背景图.duplicate()
		else :
			背景=扩展的扁平样式框.new(扩展的扁平样式框.构建枚举.梅主题)
		背景.bg_color=Color(1.0, 0.0, 0.0, 0.5)
		不可用背景=背景
		return 背景
## 可以装备的物品类型，对应 ItemData.type
@export var avilable_types: Array[String] = ["ANY"]
@export var 宝石槽样式: StyleBoxFlat:
	set(值):# 断开旧资源的信号连接
		if Engine.is_editor_hint():
			if 宝石槽样式 != null and 宝石槽样式.changed.is_connected(queue_redraw):
				宝石槽样式.changed.disconnect(queue_redraw)
		宝石槽样式 = 值
		if Engine.is_editor_hint():
			if 宝石槽样式 != null and not 宝石槽样式.changed.is_connected(queue_redraw):
				宝石槽样式.changed.connect(queue_redraw)# 连接新资源的信号
			queue_redraw()
## 物品容器
var _item_container: Control
## 物品视图
var _item_view: ItemView
## 当前绘制状态
var _state: State = State.NORMAL

## 是否为空
func is_empty() -> bool:
	return _item_view == null

## 刷新装备槽显示
func refresh() -> void:
	_clear_slot()
	读取宝石槽()
	var slot_data = GBIS.equipment_slot_service.get_slot(slot_name)
	if slot_data:
		var item_data = slot_data.equipped_item
		if item_data:
			_on_item_equipped(slot_name, item_data)

## 初始化
func _ready() -> void:
	if not 背景图:背景图=扩展的扁平样式框.new(扩展的扁平样式框.构建枚举.梅主题)
	slot_name=name
	if Engine.is_editor_hint():
		call_deferred("_recalculate_size")
		return
	var ret = GBIS.equipment_slot_service.regist_slot(slot_name, avilable_types)
	if not ret:
		return
	if visible:
		GBIS.opened_equipment_slots.append(slot_name)
	visibility_changed.connect(func():call_deferred("refresh"))
	mouse_filter = Control.MOUSE_FILTER_PASS
	_init_item_container()
	GBIS.sig_slot_item_equipped.connect(_on_item_equipped)
	GBIS.sig_slot_item_unequipped.connect(_on_item_unequipped)
	GBIS.sig_slot_refresh.connect(refresh)
	mouse_entered.connect(_on_slot_hover)
	mouse_exited.connect(_on_slot_lose_hover)
	
	visibility_changed.connect(_on_visible_changed)
	读取宝石槽()
	call_deferred("refresh")

func _on_visible_changed() -> void:
	if is_visible_in_tree():
		GBIS.opened_equipment_slots.append(slot_name)
	else:
		GBIS.opened_equipment_slots.erase(slot_name)



##处理鼠标悬浮到装备槽上时的逻辑
func _on_slot_hover() -> void:
	# 场景1：当前没有正在拖拽的物品（悬浮时聚焦显示槽内物品信息）
	if not GBIS.moving_item_service.moving_item:
		# 获取当前装备槽的实例，并取出槽内已装备的物品数据
		#var item_data = GBIS.equipment_slot_service.get_slot(slot_name).equipped_item
		# 如果槽内有物品数据
		#if item_data:
			# 让物品焦点服务聚焦该物品（显示物品详情、高亮等），并关联槽位名称
			#GBIS.item_focus_service.focus_item(item_data, slot_name)
		#计划.全局悬浮提示.emit(返回装备栏显示文本(),self,30)
		var 数据包:梅提示数据=梅提示数据.new()
		数据包.通用解析(GBIS.equipment_slot_service.get_slot(slot_name))
		数据包.节点=self
		计划.数据包提示.emit(数据包)
		return#不再执行后续代码
	# 场景2：存在正在拖拽的物品，且拖拽的是装备数据类型
	elif GBIS.moving_item_service.moving_item is EquipmentData or  GBIS.moving_item_service.moving_item is 物品宝石:
		# 适配拖拽物品的显示尺寸：将拖拽物品的视图基础尺寸设为当前槽位的基础尺寸
		GBIS.moving_item_service.moving_item_view.base_size = base_size
		# 检查当前装备槽是否可装备该拖拽物品（获取槽位实例并调用可用性检测方法）
		var is_avilable = GBIS.equipment_slot_service.get_slot(slot_name).检查物品类型(GBIS.moving_item_service.moving_item)
		# 更新装备槽状态：仅当物品可用且槽位为空时设为"可用"，否则设为"不可用"
		_state = State.AVILABLE if is_avilable and is_empty() else State.INVILABLE
	else:
		# 场景3：拖拽的物品不是装备数据类型 → 直接设为"不可用"状态
		_state = State.INVILABLE
	
	# 标记控件需要重绘（触发_draw函数，更新装备槽的视觉状态，如可用/不可用的颜色提示）
	queue_redraw()
## 失去高亮
func _on_slot_lose_hover() -> void:
	_state = State.NORMAL
	#GBIS.item_focus_service.item_lose_focus()
	计划.全局悬浮提示.emit("",self)
	queue_redraw()

## 监听穿装备
@warning_ignore("shadowed_variable")
func _on_item_equipped(slot_name: String, item_data: ItemData):
	if slot_name != self.slot_name:
		return
	if item_data is 物品宝石:
		读取宝石槽()
	else :
		_item_view = _draw_item(item_data)
		_item_container.add_child(_item_view)
		_state = State.NORMAL
	queue_redraw()
func 读取宝石槽():
	宝石数组=计划.装备.获得装备槽宝石(slot_name)
## 监听脱装备
@warning_ignore("shadowed_variable")
func _on_item_unequipped(slot_name: String, _item_data: ItemData):
	if slot_name != self.slot_name:
		return
	_clear_slot()


## 绘制装备
func _draw_item(item_data: ItemData) -> ItemView:
	var item = ItemView.new(item_data, base_size)
	var center = size / 2 - item.size / 2
	item.position = center
	return item

## 清空装备槽显示（仅清空显示，与数据无关）
func _clear_slot() -> void:
	if _item_view:
		_item_view.queue_free()
		_item_view = null

## 初始化物品容器
func _init_item_container() -> void:
	_item_container = Control.new()
	add_child(_item_container)

## 绘制装备槽背景
func _draw() -> void:
	var 基础矩形大小=Rect2(0, 0, columns * base_size, rows * base_size)
	draw_style_box(背景图, 基础矩形大小)
	match _state:
		State.AVILABLE:
			draw_style_box(可用背景, 基础矩形大小)
		State.INVILABLE:
			draw_style_box(不可用背景, 基础矩形大小)

	if is_empty():
		var 加载字体=load("res://字体/AlibabaPuHuiTi-3/AlibabaPuHuiTi-3-55-Regular/阿里巴巴普惠55号.otf")
		var 字号=32
		var 文本宽度 = 加载字体.get_string_size(slot_name, 字号).x
		var 水平居中=(columns * base_size - 文本宽度*2) / 2
		draw_string(
			加载字体,  # 默认字体
			Vector2(水平居中, rows * base_size-10),         # 文本位置（左上角内边距）
			slot_name,             # 装备部位名称
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,                    # 不限制宽度
			字号,                    # 默认字号
			Color(0, 0, 0))         # 默认白色
	match 宝石槽方向:
		方向.上:绘制多个宝石槽(基础矩形大小,Vector2(0,-基础矩形大小.size.x*0.95),宝石槽数量)
		方向.下:绘制多个宝石槽(基础矩形大小,Vector2(0,基础矩形大小.size.x*0.95),宝石槽数量)
		方向.左:绘制多个宝石槽(基础矩形大小,Vector2(-基础矩形大小.size.x*0.95,0),宝石槽数量)
		方向.右:绘制多个宝石槽(基础矩形大小,Vector2(基础矩形大小.size.x*0.95,0),宝石槽数量)
		_:绘制多个宝石槽(基础矩形大小,Vector2(0,0),宝石槽数量)
func 绘制多个宝石槽(基础矩形:Rect2,偏移:Vector2,数量:int):
	基础矩形.size*=0.45
	if 数量>=1:
		基础矩形.position=偏移+Vector2(size.x*0.075,size.y*0.075)
		绘制宝石槽(基础矩形,1)
	if 数量>=2:
		基础矩形.position=偏移+Vector2(size.x*0.075,size.y*0.475)
		绘制宝石槽(基础矩形,2)
	if 数量>=3:
		基础矩形.position=偏移+Vector2(size.x*0.475,size.y*0.075)
		绘制宝石槽(基础矩形,3)
	if 数量>=4:
		基础矩形.position=偏移+Vector2(size.x*0.475,size.y*0.475)
		绘制宝石槽(基础矩形,4)
	
func 绘制宝石槽(基础矩形大小:Rect2,编号:int):
	draw_style_box(宝石槽样式, 基础矩形大小)
	基础矩形大小.position+=基础矩形大小.size*0.1
	基础矩形大小.size*=0.8
	if Engine.is_editor_hint():
		if 编辑器宝石图片:
			draw_texture_rect(编辑器宝石图片,基础矩形大小,false)
		else :
			print("错误编辑器图片无效",编辑器宝石图片)
	else :
		if 编号-1<宝石数组.size():
			draw_texture_rect(计划.表格.道具贴图(宝石数组[编号-1]),基础矩形大小,false)
## 重新计算大小
func _recalculate_size() -> void:
	var new_size = Vector2(columns * base_size, rows * base_size)
	custom_minimum_size=new_size
	if size != new_size:
		size = new_size
	queue_redraw()

# 处理GUI输入事件的回调函数
# 参数event: 输入事件对象，包含用户的输入行为（点击、按键等）
# 返回值: void 无返回值
func _gui_input(event: InputEvent) -> void:
	# 点击动作处理（检测用户是否触发了"点击"输入动作）
	if event.is_action_pressed(GBIS.input_click):
		# 调用焦点服务，让当前聚焦的物品失去焦点
		GBIS.item_focus_service.item_lose_focus()
		
		# 场景1：存在正在拖拽的物品，且当前装备槽为空
		if GBIS.moving_item_service.moving_item and is_empty():
			# 将拖拽中的物品装备到当前槽位（传入槽位名称）
			GBIS.equipment_slot_service.equip_moving_item(slot_name)
			
		# 场景2：无正在拖拽的物品，且当前装备槽不为空
		elif not GBIS.moving_item_service.moving_item and not is_empty():
			# 开始拖拽当前槽位的物品
			GBIS.equipment_slot_service.move_item(slot_name, base_size)
			# 触发槽位悬浮效果（视觉反馈）
			_on_slot_hover()
			
	# 使用/卸下动作处理（检测用户是否触发了"使用"输入动作，且当前槽位非空）
	elif event.is_action_pressed(GBIS.input_use) and not is_empty():
		# 开始拖拽当前槽位的物品
		GBIS.equipment_slot_service.move_item(slot_name, base_size)
		_on_slot_hover()
		## 卸下当前槽位的物品（传入槽位名称）
		#GBIS.equipment_slot_service.unequip(slot_name)
