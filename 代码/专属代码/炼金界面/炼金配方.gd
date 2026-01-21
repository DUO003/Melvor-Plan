extends FoldableContainer
class_name 炼金配方卡片
@export var 配方编号=0
@export var 炼金数据:梅炼金数据
@export var 配方: Dictionary=	{"材料名称"=[],
						"材料数量"=[],
						"催化剂"=null}
var 使用事件:Callable
var 删除事件:Callable
var 查看事件:Callable
var 移动事件:Callable
var 序号:int=1
@onready var 配方格子: Control = %配方格子
@onready var 上移: Button = %上移
@onready var 下移: Button = %下移
func _ready() -> void:
	if not 炼金数据:
		print("错误,炼金配方卡片没有正确的数据")
		queue_free()
		return
	配方=炼金数据.配方字典
	配方格子.配方编号=配方编号
	配方格子.配方=配方
	加载配方信息()
	$"炼金配方/使用".pressed.connect(使用事件.bind(int(%"制作数量".value)))
	$"炼金配方/删除".pressed.connect(删除事件)
	%"查看".pressed.connect(查看事件)
	下移.pressed.connect(移动配方.bind(true))
	上移.pressed.connect(移动配方.bind(false))
	计划.更新_UI.connect(更新UI)
	更新UI()
@onready var 了解: Label = $炼金配方/了解
func 更新UI():
	var 炼金次数=炼金数据.炼金数量
	var 药水数量=炼金数据.药水序列.size()
	if 炼金次数<药水数量:
		了解.text="制作次数%d/%d"%[炼金次数,药水数量]
	else :
		了解.text="制作次数%d(%d)"%[炼金次数,药水数量]
	下移.disabled= not 炼金数据.检查配方移动(true)
	上移.disabled= not 炼金数据.检查配方移动(false)
func 加载配方信息():
	title="配方"+str(序号+1)
	配方格子.加载配方信息()
#func _process(_delta: float) -> void:
	#print("文本:",%"制作数量".value)
func 移动配方(后移:bool):
	if 炼金数据.移动配方(后移):
		移动事件.call()
