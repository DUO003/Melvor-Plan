extends Panel
class_name 梅自动化进度条
@export var 配方名称:String=""
@onready var 进度条: ProgressBar = %进度条
@onready var 配方贴图: TextureRect = %配方贴图
@onready var 配方名: Label = %配方名
@onready var 取消: Button = %取消
#var 自动更新方法:Callable=Callable()
#func _process(_间隔: float) -> void:
	#if 自动更新方法.is_valid():
		#var 结果 = 自动更新方法.call()
		#if 结果 is float:
			#更新进度(结果)

func 更新进度(新进度: float):
	进度条.value = clamp(新进度, 0.0, 1.0)
func 传入配方参数(名称:String=""):#,更新方法:Callable=Callable()
	配方名称=名称
	配方名.text=名称
	if 名称=="":
		配方贴图.texture=null
	else :
		配方贴图.texture=计划.表格.道具贴图(名称)
#	自动更新方法=更新方法
