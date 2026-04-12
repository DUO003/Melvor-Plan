@tool
extends Control
class_name 游历地区地图
@onready var 背景显示: 可保存瓦片地图 = %背景显示
@onready var 地块显示: 可保存瓦片地图 = %地块显示
##UI区
@onready var 地区下拉框: OptionButton = %地区下拉框
@onready var 缩放下拉框: OptionButton = %缩放下拉框
@onready var 地区精通等级: Label = %地区精通等级
@onready var 探索进度条: ProgressBar = %探索进度条
##弹窗区
@onready var 关闭弹窗: Button = %关闭弹窗
@onready var 弹窗容器: Panel = %弹窗容器
@onready var 弹窗标题: Label = %弹窗标题
@onready var 进入: Button = %进入
@onready var 关闭: Button = %关闭
#编辑器变量
@export var 当前地区数据:地区信息包=null
#调试变量
var 调试日志:Dictionary={"点击地图事件":true}
# 状态变量
# 鼠标点击位置与节点原点的偏移量
var 长按判定时间:float = 0.1
var 拖动偏移量: Vector2 = Vector2.ZERO
var 绘制偏移: Vector2 = Vector2.ZERO
var 是否按下鼠标左键 = false  # 标记鼠标左键是否按下
var 按下开始时间 = 0.0        # 记录鼠标按下的时间戳
var 是否判定为拖动 = false    # 标记是否已进入拖动状态
var 按下时的鼠标位置 = Vector2.ZERO  # 记录按下时的鼠标位置
var 地图缩放:float=0.5
var 限制范围:Rect2=Rect2()

func _ready() -> void:
	if Engine.is_editor_hint():
		clip_contents=false
	else :
		clip_contents=true
	offset_left=10
	offset_top=10
	offset_right=-10
	offset_bottom=-10
	加载地区(当前地区数据)
	绘制偏移=地块显示.position
	更新瓦片地图()
	更新弹窗(false)
func 保存地区(保存:bool):
	if Engine.is_editor_hint():#只在编辑器工作
		背景显示.保存地图()#先各自保存自身的图块数据
		地块显示.保存地图()
		#初始化地图信息包
		if not 当前地区数据 or not 保存:
			当前地区数据 = 地区信息包.new()
		当前地区数据.初始化(背景显示.地图资源,背景显示.图案起点坐标,地块显示.地图资源,地块显示.图案起点坐标)
		当前地区数据.自动加载地块配置(地块显示)
func 加载地区(数据:地区信息包):
	if not 数据:
		print("错误,没有正确传入数据")
		return
	当前地区数据=数据
	背景显示.clear()
	背景显示.set_pattern(数据.起点_背景,数据.地图_背景)
	地块显示.clear()
	地块显示.set_pattern(数据.起点_地块,数据.地图_地块)
	限制范围=数据.限制范围
func 更新弹窗(状态:bool,地图格子:Vector2i=Vector2.ZERO):
	关闭弹窗.visible=状态
	弹窗标题.text="地块(%d,%d)"%[地图格子.x,地图格子.y]
func _gui_input(事件: InputEvent):
	if Engine.is_editor_hint():
		return
	# 鼠标按键事件
	if 事件 is InputEventMouseButton:
		if [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_MIDDLE,MOUSE_BUTTON_RIGHT].has(事件.button_index):
			if 事件.pressed:
				# 按下 —— 统一进入拖动准备状态
				是否按下鼠标左键 = true
				按下开始时间 = Time.get_unix_time_from_system()
				按下时的鼠标位置 = 事件.position
				是否判定为拖动 = false
				拖动偏移量 = 事件.position - 绘制偏移
			else:
				if not 是否判定为拖动 && 事件.button_index == MOUSE_BUTTON_LEFT:
					点击函数(事件.global_position)
				# 重置状态
				是否按下鼠标左键 = false
				是否判定为拖动 = false

	# 鼠标移动（拖动判定，不变）
	elif 事件 is InputEventMouseMotion:
		if not 是否按下鼠标左键:
			return
		var 按下时长 = Time.get_unix_time_from_system() - 按下开始时间
		if 按下时长 > 长按判定时间:
			是否判定为拖动 = true
			更新瓦片地图(事件.position)
func 点击函数(鼠标全局: Vector2):
	var 日志:bool=调试日志.get("点击地图事件",false)
	var 鼠标局部 = 地块显示.to_local(鼠标全局)
	var 地图格子:Vector2i=地块显示.local_to_map(鼠标局部)
	if 日志:print("[调试]按下坐标",地图格子)
	if 当前地区数据 and 当前地区数据.地块配置.has(地图格子):
		var 地图信息:地图信息包=当前地区数据.地块配置[地图格子]
		if 地图信息.可用性检查():
			更新弹窗(true,地图格子)
		else :
			更新弹窗(true,地图格子)
	else :
		计划.语法糖通知("暂未发现可探索目标")
func 更新瓦片地图(鼠标位置: Vector2=绘制偏移 + 拖动偏移量):
	绘制偏移 = 鼠标位置 - 拖动偏移量
	#print("偏移",绘制偏移,"限制",限制范围)
	var 视图大小 = size
	var 缩放后地图宽度 = 限制范围.size.x * 地图缩放
	var 缩放后地图高度 = 限制范围.size.y * 地图缩放
	if 缩放后地图宽度 <= 视图大小.x:
		绘制偏移.x = (视图大小.x - 缩放后地图宽度) / 2 - 限制范围.position.x * 地图缩放
	else:
		var 左边界 = -限制范围.position.x * 地图缩放
		var 右边界 = -限制范围.end.x * 地图缩放 + 视图大小.x
		绘制偏移.x = clamp(绘制偏移.x, 右边界, 左边界)
	if 缩放后地图高度 <= 视图大小.y:
		# 地图高度小于视图高度 → 垂直居中
		绘制偏移.y = (视图大小.y - 缩放后地图高度) / 2 - 限制范围.position.y * 地图缩放
	else:
		# 地图高度大于视图高度 → 计算上下边界，限制偏移
		var 上边界 = -限制范围.position.y * 地图缩放
		var 下边界 = -限制范围.end.y * 地图缩放 + 视图大小.y
		绘制偏移.y = clamp(绘制偏移.y, 下边界, 上边界)
	地块显示.position=绘制偏移
	背景显示.position=绘制偏移
	地块显示.scale=Vector2(1,1)*地图缩放
	背景显示.scale=Vector2(4,4)*地图缩放
func _unhandled_input(按键: InputEvent) -> void:
	if 按键.is_action_pressed("缩放_增大"):
		设置缩放(地图缩放*1.1,true)
	if 按键.is_action_pressed("缩放_减小"):
		设置缩放(地图缩放/1.1,true)
# 设置绝对缩放值 —— 以鼠标位置为中心缩放（供滚轮/按钮/选项卡调用）
func 设置缩放(目标缩放值: float,调整位置:bool=false) -> void:
	if 调整位置:
		var 鼠标位置: = get_local_mouse_position()
		var 鼠标在地图上的坐标 = (鼠标位置 - 绘制偏移) / 地图缩放
		拖动偏移量 = 鼠标在地图上的坐标*目标缩放值
		地图缩放 = 目标缩放值
		更新瓦片地图(鼠标位置)
	else :
		地图缩放 = 目标缩放值
		更新瓦片地图()
func 进入地块():
	if Engine.is_editor_hint():
		return
	#横版单例.冒险管理器.加载地图(横版单例.冒险管理器.地图信息)
	横版单例.打开地图=false
