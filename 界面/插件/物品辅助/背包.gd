@tool  # 启用编辑器内预览
extends GridContainer
class_name 梅背包
@export var 背包来源:Array[String]=[]
@export var 筛选标签:Array[String]=[]
@export var 间隔:int=3:
	set(值):
		间隔 = 值
		if Engine.is_editor_hint():
			更新UI()
@export var 排数:int=3:
	set(值):
		排数 = 值
		if Engine.is_editor_hint():
			更新UI()
var 列数:int=5
@export var 格子尺寸:int=60:
	set(值):
		格子尺寸 = 值
		if Engine.is_editor_hint():
			更新UI()
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
			更新UI()
@export var 字体:Font
var 物品数组:Array[ItemData]=[]
## 容器数据库引用
var 背包单例: ContainerRepository = ContainerRepository.instance
func _ready() -> void:
	更新UI()
	if Engine.is_editor_hint():
		return  # 直接返回，不执行后续可能出错的代码
	重新生成()
	GBIS.sig_inv_item_added.connect(监听添加物品)
	GBIS.sig_inv_item_removed.connect(监听移除物品)
func 重新生成():
	计划.清除子节点(self)
	物品数组.clear()
	var 背包字典: Dictionary[String, ContainerData]=背包单例._container_data_map
	var 允许标签:Array=Array(筛选标签)
	var 节点:梅物品栏位=梅物品栏位.new(背景图,格子尺寸,字体)
	for 背包名 in 背包字典:
		if 背包来源.has(背包名):
			var 背包容器:ContainerData=背包字典[背包名]
			var 背包物品数组: Array[ItemData]=背包容器.items
			for 物品 in 背包物品数组:
				var 物品名=物品.item_name
				if 允许标签.size()==0 or 计划.表格.蓝图标签检查(物品名,允许标签,1):
					物品数组.append(物品)
					#breakpoint#断点
					var 克隆节点:梅物品栏位=节点.duplicate()
					克隆节点.物品=物品
					add_child(克隆节点)
	列数=int(max(5,float(物品数组.size())/排数)+1)
	更新UI()
func 更新UI():
	columns=排数
	custom_minimum_size.x=排数*(间隔+格子尺寸)-间隔
	add_theme_constant_override("h_separation",间隔)
	add_theme_constant_override("v_separation",间隔)
	queue_redraw()
func _draw() -> void:
	if Engine.is_editor_hint():
		列数=5
	var 基础矩形大小=Rect2(0,0,格子尺寸,格子尺寸)
	var 物品数量:int=物品数组.size()
	for 列 in range(列数):
		for 排 in range(排数):
			var 当前索引:int = 列 * 排数 + 排
			if 当前索引 >= 物品数量:
				基础矩形大小.position.x=排*(格子尺寸+间隔)
				基础矩形大小.position.y=列*(格子尺寸+间隔)
				draw_style_box(背景图,基础矩形大小)

## 监听添加物品
func 监听添加物品(_背包名:String, 物品: ItemData, _格子: Array[Vector2i]) -> void:
	if not is_visible_in_tree():
		return
	var 物品名=物品.item_name
	var 允许标签:Array=Array(筛选标签)
	if 允许标签.size()==0 or 计划.表格.蓝图标签检查(物品名,允许标签,1):
		重新生成()

## 监听移除物品
func 监听移除物品(_背包名:String, 物品: ItemData) -> void:
	if not is_visible_in_tree():
		return
	if 物品数组.has(物品):
		重新生成()
