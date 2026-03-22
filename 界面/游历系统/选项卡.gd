extends TabContainer
@onready var 内容节点: Control = %内容节点
@onready var 冒险窗口: SubViewport = %冒险窗口
@onready var 冒险窗口区: SubViewportContainer = %冒险窗口区
@onready var 视差背景: Parallax2D = $"../冒险窗口区/冒险窗口/冒险管理器/视差背景"
func _ready() -> void:
	tab_changed.connect(延迟计算尺寸)
	延迟计算尺寸()
func 延迟计算尺寸(_索引: int = -1):
	await get_tree().process_frame
	var 当前选中节点: Control = get_current_tab_control()
	var 总尺寸:float=内容节点.size.y-60
	var 原高度:float=当前选中节点.custom_minimum_size.y
	var 新高度:=int(总尺寸-原高度)
	var 视察Y缩放:float=视差背景.scroll_scale.y
	视差背景.scroll_offset.y=(新高度-原高度)*视察Y缩放*1.167
	冒险窗口.size.y=新高度
