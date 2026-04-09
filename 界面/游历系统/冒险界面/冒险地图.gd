extends Control
class_name 游历地区地图
@onready var 色块显示: TileMapLayer = %色块显示
@onready var 地图显示: TileMapLayer = %地图显示
@onready var 地区下拉框: OptionButton = %地区下拉框
@onready var 缩放下拉框: OptionButton = %缩放下拉框
@onready var 地区精通等级: Label = %地区精通等级
@onready var 探索进度条: ProgressBar = %探索进度条
# 状态变量
# 鼠标点击位置与节点原点的偏移量
var 长按判定时间:float = 0.1
var 拖动偏移量: Vector2 = Vector2.ZERO
var 绘制偏移: Vector2 = Vector2.ZERO
var 是否按下鼠标左键 = false  # 标记鼠标左键是否按下
var 按下开始时间 = 0.0        # 记录鼠标按下的时间戳
var 是否判定为拖动 = false    # 标记是否已进入拖动状态
var 按下时的鼠标位置 = Vector2.ZERO  # 记录按下时的鼠标位置
func _ready() -> void:
	绘制偏移=地图显示.position
	拖动函数()
func _gui_input(事件: InputEvent):
	if 事件 is InputEventMouseButton:
		if not 事件.button_index == MOUSE_BUTTON_LEFT:# 只处理鼠标左键事件
			return
		if 事件.pressed:# 鼠标按下
			是否按下鼠标左键 = true
			按下开始时间 = Time.get_unix_time_from_system()  # 记录按下时间
			按下时的鼠标位置 = 事件.position  # 记录按下位置
			是否判定为拖动 = false  # 初始化为非拖动状态
			拖动偏移量 = 事件.position - 绘制偏移
		else:# 鼠标弹起
			# 弹起时如果未判定为拖动，视为点击
			if not 是否判定为拖动:
				点击函数(事件.global_position)
			# 重置所有状态
			是否按下鼠标左键 = false
			是否判定为拖动 = false
	elif 事件 is InputEventMouseMotion:# 处理鼠标移动事件（用于拖动判定）
		if not 是否按下鼠标左键:
			return
		var 按下时长 = Time.get_unix_time_from_system() - 按下开始时间
		if 按下时长 > 长按判定时间:# 按下时长超过阈值，判定为拖动
			是否判定为拖动 = true
			拖动函数(事件.position)
func 点击函数(鼠标全局: Vector2):
	var 鼠标局部 = 地图显示.to_local(鼠标全局)
	var 地图格子:Vector2i=地图显示.local_to_map(鼠标局部)
	print("按下坐标",地图格子)
func 拖动函数(鼠标位置: Vector2=绘制偏移 + 拖动偏移量):
	绘制偏移 = 鼠标位置 - 拖动偏移量
	地图显示.position=绘制偏移
	色块显示.position=绘制偏移
