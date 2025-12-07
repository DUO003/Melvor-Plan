extends FoldableContainer
class_name 炼金配方卡片
var 配方格子
@export var 配方编号=0
@export var 配方: Dictionary=	{"材料名称"=[],
						"材料数量"=[],
						"催化剂"=null}
var 使用事件:Callable
var 删除事件:Callable
var 查看事件:Callable
var 序号:int=1
func _ready() -> void:
	配方格子=%"配方格子"
	配方格子.配方编号=配方编号
	配方格子.配方=配方
	加载配方信息()
	$"炼金配方/使用".pressed.connect(func():使用事件.call(int(%"制作数量".value)))
	$"炼金配方/删除".pressed.connect(func():删除事件.call())
	计划.更新_UI.connect(更新了解)
	更新了解()
func 更新了解():
	var 了解=$"炼金配方/信息/配方/还不够了解"
	var 哈希结果=计划.梅手工单例.哈希配方(配方)
	var 炼金次数=计划.手工.数据炼金配方(哈希结果)
	if 炼金次数==-1:
		了解.text="未了解"
		return
	var 药水数量=计划.手工.数据炼金配方(哈希结果,"药水").size()
	了解.visible=true
	%"查看".visible=false
	%"查看".pressed.connect(func():查看事件.call())
	if 炼金次数<药水数量:
		了解.text="不够了解"+str(炼金次数)+"/"+str(药水数量)
	else :
		了解.visible=false
		%"查看".visible=true

func 加载配方信息():
	title="配方"+str(序号+1)
	配方格子.加载配方信息()
#func _process(_delta: float) -> void:
	#print("文本:",%"制作数量".value)
