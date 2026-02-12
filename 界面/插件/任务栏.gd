extends ScrollContainer
class_name 任务栏插件
@export var 来源:Array[String]=["循环"]
##仅显示拥有该标签的任务
@export var 循环筛选:Array[String]=[]
@export var 以完成任务:bool=false
@export var 显示体力:bool=false
@export var 显示跳转任务:bool=true
@export var 显示任务数量:int=1
@export var 场景:基类梅窗口
@onready var 任务容器: VBoxContainer = %任务容器
@onready var 任务栏: GridContainer = %任务栏
@onready var 标签: Label = %标签
@onready var 隐藏任务: HBoxContainer = %隐藏任务
@onready var 隐藏: CheckButton = %隐藏
@onready var 跳转任务: Button = %跳转任务
##可能移除
@onready var 体力状态: 体力插件 = %体力状态
#var 体力状态场景 = preload("res://界面/插件/体力状态.tscn")
var 任务的卡片:任务卡片=preload("res://界面/挂机系统/任务窗口/任务卡片.tscn").instantiate()
var 筛选失效:int=0

func _ready() -> void:
	if not 循环筛选.is_empty():
		隐藏.button_pressed=计划.窗口状态管理("任务插件","隐藏循环",false)
	任务栏.columns=显示任务数量
	初始化所有任务容器()
	if 场景:
		await 场景.ready
	计划.显示后执行(刷新任务显示,self)
	计划.任务.更新_任务UI.connect(更新_任务UI)
func 更新_任务UI():
	初始化所有任务容器()
	计划.显示后执行(刷新任务显示,self)
func 初始化所有任务容器():
	计划.清除子节点(任务栏)
	var 序号=1
	var 当前任务:Array[任务资源]=计划.任务.当前任务数据
	筛选失效=0
	for 任务数据:任务资源 in 当前任务:
		if 加载检查(任务数据):
			生成任务卡片(任务数据,序号)
			序号+=1
	隐藏任务.visible=not 循环筛选.is_empty()
	if not 显示体力:
		if 体力状态:体力状态.queue_free()
	if 隐藏.button_pressed:
		隐藏.text="已隐藏"
		标签.text="隐藏数量:%d"%筛选失效
		标签.visible=true
	else :
		隐藏.text="隐藏其他任务"
		标签.visible=false
	跳转任务.visible=显示跳转任务
func 加载检查(任务数据:任务资源)->bool:
	if not 来源.has(任务数据.任务类型):
		return false
	if 循环筛选.is_empty() or not 隐藏.button_pressed:
		return true
	for 条件:String in 任务数据.循环来源:
		if 循环筛选.has(条件):
			return true
	筛选失效+=1
	return false
func 生成任务卡片(任务数据:任务资源,序号):		
	var 任务卡=任务的卡片.duplicate()
	任务卡.任务数据=任务数据
	任务卡.任务序号=序号
	任务卡.初始化任务()
	任务栏.add_child(任务卡)
func 刷新任务显示():
	if 显示任务数量<1:显示任务数量=1
	var 间距:float=任务栏.get_theme_constant("h_separation")#水平间距10
	var 任务宽度:float=(size.x-显示任务数量*间距+间距)/显示任务数量
	print("任务宽度:%d"%任务宽度)
	任务栏.columns=显示任务数量
	for 任务卡 in 任务栏.get_children():
		if 任务卡 is 任务卡片:
			if 以完成任务:任务卡.visible=true
			else:
				if 任务卡.任务数据.任务完成:任务卡.visible=false
				elif 任务卡.任务数据.显示检查() :任务卡.visible=false
				else :任务卡.visible=true
			任务卡.custom_minimum_size.x=任务宽度
			任务卡.custom_minimum_size.y=400
func _跳转任务() -> void:
	计划.切换场景("任务窗口")
func _隐藏任务() -> void:
	计划.窗口状态管理("任务插件","隐藏循环",null,隐藏.button_pressed)
	更新_任务UI()
