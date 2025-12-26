@tool
extends Control
class_name 梅计划_瓶子
@export var 内容长度: int=3
@export var 内容数组: Array[Dictionary]#{Color():1}
@export var 过渡速度: float = 2  # 渐变速度（值越小越慢）
@export var 迷雾数量=0
var 当前颜色: Color = Color(randf(), randf(), randf())  # 初始颜色（红色）
var 目标颜色: Color = Color(randf(), randf(), randf())  # 目标颜色（绿色）
func _ready():
	%"排序".颜色 = 当前颜色
	%"排序".queue_redraw()
func _process(delta: float) -> void:
	# 每帧将当前颜色向目标颜色渐变一小步
	当前颜色 = 当前颜色.lerp(目标颜色, delta * 过渡速度)
	%"排序".颜色 = 当前颜色
	var 颜色差异: float = abs(当前颜色.r - 目标颜色.r) + abs(当前颜色.g - 目标颜色.g) +abs(当前颜色.b - 目标颜色.b)
	if 颜色差异 < 0.02:# 当颜色接近目标时，切换新的目标颜色
		目标颜色 = Color(randf(), randf(), randf())
func 更新瓶子():
	%选中.visible=false
	%"排序".内容长度=内容长度
	%"排序".内容数组=内容数组
	迷雾()
func 选中(显示):
	%"瓶子".visible=显示
	%选中.visible=not 显示
func 迷雾(仅更新=false):
	if 仅更新:
		迷雾数量 = 内容数组.size() - 1
	else :
		if 迷雾数量>=内容数组.size() and 迷雾数量>0:
			迷雾数量 = 内容数组.size() - 1
	%"排序".迷雾数量=迷雾数量
	if 迷雾数量>0:
		%"迷雾".visible=true
	else :
		%"迷雾".visible=false
