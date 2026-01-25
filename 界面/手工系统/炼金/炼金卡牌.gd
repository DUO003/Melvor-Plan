extends Control
class_name 梅奖励卡片
@export var 资源名称: String=""
@export var 资源数量: int = 1
@export var 资源解锁: bool=false
@export var 下次结果: bool=false
@export var 显示延迟:float=0
@export var 点击事件:Callable
@onready var 背面图标: TextureRect = $卡牌/背面/背面图标
@onready var 正面图标: TextureRect = $卡牌/正面/正面图标
@onready var 小图标上: TextureRect = $卡牌/正面/小图标上
@onready var 小图标下: TextureRect = $卡牌/正面/小图标下
@onready var 名称文本: Label = $卡牌/正面/正面图标/名称文本
@onready var 文本1: Label = $卡牌/正面/小图标上/文本
@onready var 文本2: Label = $卡牌/正面/小图标下/文本
@onready var 动画: AnimationPlayer = $动画
@onready var 背面: Control = $卡牌/背面
@onready var 正面: Control = $卡牌/正面
@onready var 动画计时器: Timer = $动画计时器
@onready var 卡牌: Panel = $卡牌

var 就绪:bool=false
func 传入参数(名称: String="",数量: int= 1,解锁: bool=false,结果: bool=false,延迟:float=0):
	资源名称=名称
	资源数量=数量
	资源解锁=解锁
	下次结果=结果
	显示延迟=延迟
	if 就绪:
		更新显示内容()
		if 解锁:
			准备播放动画(false)
@onready var 点击响应: Control = $点击响应
func _ready() -> void:
	if 资源名称=="":
		queue_free()
		return
	更新显示内容()
	就绪=true
	计划.显示后执行(准备播放动画.bind(true,true),self)
	准备播放动画(true)
	点击响应.gui_input.connect(点击检查)
func 点击检查(输入事件: InputEvent) -> void:
	## 检测鼠标左键点击（按下时触发）
	if 输入事件 is InputEventMouseButton and 输入事件.pressed:
		if 输入事件.button_index == MOUSE_BUTTON_LEFT:
			点击事件.call("切换")
		elif 输入事件.button_index == MOUSE_BUTTON_RIGHT:
			点击事件.call("显示")
		#get_viewport().set_input_as_handled()
func 更新显示内容():
	背面图标.texture=计划.表格.道具贴图("催化剂代币")
	var 物品图标:Texture2D=计划.表格.道具贴图(资源名称)
	正面图标.texture=物品图标
	小图标上.texture=物品图标
	小图标下.texture=物品图标
	if 下次结果:
		名称文本.text=资源名称
	else :
		名称文本.text=资源名称
	文本1.text=str(资源数量)
	文本2.text=str(资源数量)
	if 下次结果:
		切换边框颜色(Color(0.74, 0.493, 0.067, 1.0))
	else :
		切换边框颜色(Color(0.616, 0.353, 0.098))
func 切换边框颜色(颜色:Color):
	var 获取样式:StyleBox=卡牌.get_theme_stylebox("panel").duplicate()
	获取样式.border_color=颜色
	卡牌.add_theme_stylebox_override("panel",获取样式)
var 仅播放一次:bool=true
func 准备播放动画(切换到正面:bool,动播放画:bool=false):
	背面.visible=切换到正面
	正面.visible=not 切换到正面
	if 资源解锁 and 动播放画 and 仅播放一次:
		if 切换到正面:
			动画.speed_scale=1
		else :
			动画.speed_scale=-1
		动画计时器.wait_time=显示延迟
		动画计时器.timeout.connect(动画.play.bind("卡牌翻面"))
		动画计时器.start()
		仅播放一次=false
