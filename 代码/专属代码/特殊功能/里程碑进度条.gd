@tool
extends ProgressBar
class_name 里程碑进度条
@export var 里程碑名称:String="默认"
@export var 里程碑点数:int=10:
	set(值):
		里程碑点数=值
		var 区间:int=-1
		for i in range(里程碑上限数组.size()):
			if 里程碑点数>=里程碑上限数组[i]:
				区间=i
		var 缓存值:float=区间
		if 区间>=0 and 里程碑上限数组.size()>区间+1:
			var 差值:float=max(1,里程碑上限数组[区间+1]-里程碑上限数组[区间])
			缓存值+=(里程碑点数-里程碑上限数组[区间])/差值
		elif 区间==-1:
			缓存值=0
		value=缓存值
		queue_redraw()
@export var 里程碑数组:Array[int]=[0]:
	set(值):
		里程碑数组=值
		for i in range(里程碑数组.size()):
			if 里程碑数组[i]<1:
				里程碑数组[i]=1
		if 值.size()>=1:
			最大里程碑=值.size()
		else :
			最大里程碑=1
		计算总点数()
		max_value=最大里程碑
		size.x=里程碑长度*最大里程碑
		if Engine.is_editor_hint():
			queue_redraw()
var 里程碑上限数组:Array[int]=[0]
var 总里程碑点数:int=1:
	set(值):
		if 值>=1:
			总里程碑点数=值
		else :
			总里程碑点数=1
var 最大里程碑:int=1:
	set(值):
		if 里程碑数组.size()==值:
			最大里程碑=值
@export var 里程碑精度:float=0.01:
	set(值):
		里程碑精度=值
		step=里程碑精度
@export var 里程碑长度:float=10.0:
	set(值):
		里程碑长度=值
		size.x=里程碑长度*最大里程碑
@export var 装饰样式: StyleBoxFlat:
	set(值):# 断开旧资源的信号连接
		if 装饰样式 != null and 装饰样式.changed.is_connected(queue_redraw):
			装饰样式.changed.disconnect(queue_redraw)
		装饰样式 = 值
		if 装饰样式 != null and not 装饰样式.changed.is_connected(queue_redraw):
			装饰样式.changed.connect(queue_redraw)# 连接新资源的信号
		if Engine.is_editor_hint():
			queue_redraw()
@export var 字体大小:int=30:
	set(值):
		字体大小=值
		if Engine.is_editor_hint():
			queue_redraw()
@export var 字体:Font = ThemeDB.fallback_font:
	set(值):
		字体=值
		if Engine.is_editor_hint():
			queue_redraw()
@export var 文字颜色:Color = Color(0, 0, 0):
	set(值):
		文字颜色=值
		if Engine.is_editor_hint():
			queue_redraw()
@export var 图片大小:Vector2=Vector2(120, 120):
	set(值):
		图片大小=值
		if Engine.is_editor_hint():
			queue_redraw()
var 正确纹理=preload("res://素材/自制/图标/正确.png")
var 奖励名称:String="蓝图纸"
var 奖励数量:Variant=0
var 替换奖励:Dictionary={}
var 里程碑领取:Array=[]
func _ready() -> void:
	min_value=0.0
	max_value=最大里程碑
	size.x=里程碑长度*最大里程碑
	step=里程碑精度
	show_percentage=false
	计算总点数()
func _draw() -> void:
	var 矩形宽度:float=5.0
	var 矩形高度:float=10.0
	for i in range(里程碑数组.size()):
		var 定位点=(i+1)*里程碑长度
		var 显示文本 = str(里程碑上限数组[1+i])  # 数字从1开始
		var 文本宽度=字体.get_string_size(显示文本,HORIZONTAL_ALIGNMENT_LEFT, -1, 字体大小).x
		矩形宽度=文本宽度+20
		矩形高度=size.y+10
		var 矩形尺寸:Rect2=Rect2(Vector2(定位点-矩形宽度*0.5,(矩形高度-size.y)*-0.5),Vector2(矩形宽度,矩形高度))
		var 文本位置 = Vector2(定位点-0.5*文本宽度,矩形尺寸.position.y + 30+(矩形高度-size.y)*0.5)
		draw_style_box(装饰样式, 矩形尺寸)
		draw_string(字体,文本位置,显示文本,
			HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT,-1,字体大小,文字颜色)
		var 奖励的名称
		var 奖励的数量
		if 替换奖励.has(i+1):
			奖励的名称=替换奖励[i+1][0]
			奖励的数量=替换奖励[i+1][1]
		else :
			奖励的名称=奖励名称
			奖励的数量=奖励数量
		if 奖励的数量 is float:
			显示文本="%s*%.1f"%[奖励的名称,奖励的数量]
		elif 奖励的数量 is int:
			显示文本="%s*%d"%[奖励的名称,奖励的数量]
		文本宽度=字体.get_string_size(显示文本,HORIZONTAL_ALIGNMENT_LEFT, -1, 字体大小).x
		文本位置 = Vector2(定位点-0.5*文本宽度,矩形尺寸.position.y + -20+(矩形高度-size.y)*0.5)
		draw_string(字体,文本位置,显示文本,
			HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT,-1,字体大小,文字颜色)
		var 里程碑纹理:Texture2D = null
		if not Engine.is_editor_hint():
			if 替换奖励.has(i+1):
				里程碑纹理=计划.表格.道具贴图(替换奖励[i+1][0])
			else :
				里程碑纹理=计划.表格.道具贴图(奖励名称)
		else :
			里程碑纹理=preload("res://icon.svg")
		var 图片坐标 = Vector2(定位点 - 图片大小.x/2,-图片大小.y - 字体大小-20)
		var 图片矩形 = Rect2(图片坐标, 图片大小)
		if 里程碑点数<里程碑上限数组[i+1]:
			draw_texture_rect(里程碑纹理, 图片矩形, false, Color(0.5,0.5,0.5))
		else :
			draw_texture_rect(里程碑纹理, 图片矩形, false, Color(1,1,1))
		if 里程碑领取 is Array :
			if 里程碑领取.has(i+1):
				draw_texture_rect(正确纹理, 图片矩形, false, Color(1,1,1))
		else :print("错误:里程碑领取,意外的不是数组",里程碑领取)
		矩形宽度=5
		矩形高度=10
		var 矩形定位点:Rect2=Rect2(Vector2(定位点-矩形宽度*0.5,-矩形高度),Vector2(矩形宽度,矩形高度))
		draw_rect(矩形定位点,Color(0,0,0),true)
func 计算总点数():
	var 缓存点数:int=0
	里程碑上限数组=[0]
	for i in 里程碑数组:
		缓存点数+=i
		里程碑上限数组.append(缓存点数)
	总里程碑点数=缓存点数
