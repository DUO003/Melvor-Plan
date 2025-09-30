extends ItemList
#接收信号 描述
###描述啊
signal 确定选项;##点击或回车确定的选项 参数:选项
signal 指向选项;#用于鼠标指向? 参数:选项
#导出
@export var 默认焦点:bool;
"""常用脚本
$"背包列表".指向选项.connect(func (选项):
		var 选项文本=$"../首页菜单".get_item_text(选项)
		pass
		)
"""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print()
	var 获取主题字体大小=get_theme_font_size("font_size")+12
	#默认焦点
	if 默认焦点:
		grab_focus()
		select(0)
	#回车确认信号
	item_activated.connect(func(选项):
		print("回车选项:",选项)
		print("回车选项名称:",get_item_text(选项))
		确定选项.emit(选项)
		)
	#鼠标控件进入坐标信号
	#进行项目选择
	gui_input.connect(func(event: InputEvent):
		if !event is InputEventMouseMotion:return
		#
		#var 控件高度=size.y;
		var 控件行数=item_count/max_columns
		if 控件行数==0:return
		#var 控件高度=获取主题字体大小*item_count
		var 控件高度=获取主题字体大小*控件行数
		#var 控件项目数量=item_count/max_columns;
		var 平均y轴=ceil(控件高度/控件行数)
		var 项目选择=floor(event.position.y / 平均y轴)*max_columns
		#计算X轴
		var 偏移数量=0;
		if max_columns>1:
			var 控件宽度=size.x
			var 平均宽度=控件宽度/max_columns
			偏移数量=floor(event.position.x/平均宽度)
			#print(偏移数量)
		#鼠标选择
		select(项目选择+偏移数量)
		指向选项.emit(项目选择+偏移数量)
		)
	#鼠标单选
	item_clicked.connect(func(选项: int, at_position: Vector2, mouse_button_index: int):
		print("鼠标选中",选项)
		print("鼠标选中名称",get_item_text(选项))
		确定选项.emit(选项)
		)
	#一个通过键盘操作的选择
	item_selected.connect(func(选项:int):
		
		指向选项.emit(选项)
		pass)
	pass # Replace with function body.
