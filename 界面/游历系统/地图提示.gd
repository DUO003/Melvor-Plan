@tool  # 启用编辑器内预览
extends Panel

@export var 字体大小:int=30
@export var 文字颜色:Color=Color()
@export var 字体:Font
@export var 半径: int = 64
@export var 填充颜色: Color = Color(0.8, 0.9, 1.0, 0.7)  # 填充色（浅蓝半透明）
# 绘制粗细
@export var 粗细: int = 5:
	set(值):
		粗细=值
		if Engine.is_editor_hint():queue_redraw()
var 打印日志:Array=[]
func 打印(显示文本:String,中心点:Vector2,顶点列表:PackedVector2Array,解锁:bool):
	打印日志.append({"显示文本":显示文本,"中心点":中心点,"顶点列表":顶点列表,"解锁":解锁})
func 完成打印():
	for 打印数据:Dictionary in 打印日志:
		if 打印数据.has_all(["显示文本","中心点","顶点列表","解锁"]):
			var 中心点:Vector2=打印数据.中心点
			var 顶点列表: PackedVector2Array=打印数据.顶点列表
			if 打印数据.解锁:
				var 显示文本:String=打印数据.显示文本
				var 文本宽度:float=字体.get_string_size(显示文本,HORIZONTAL_ALIGNMENT_LEFT, -1, 字体大小).x
				draw_string(字体,中心点+Vector2(文本宽度*-0.5,半径-字体大小),显示文本,HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT,-1,字体大小,文字颜色)
			else :
				var 填充颜色数组: PackedColorArray = PackedColorArray()
				for i in 顶点列表:  # 遍历顶点列表，为每个顶点添加相同的填充颜色
					填充颜色数组.append(填充颜色)
				draw_polygon(顶点列表, 填充颜色数组)
			draw_polyline(顶点列表, Color(0, 0, 0), 粗细, true)# 绘制六边形边框（闭合多边形）
func _draw():
	完成打印()
func 清空打印日志():
	打印日志=[]
