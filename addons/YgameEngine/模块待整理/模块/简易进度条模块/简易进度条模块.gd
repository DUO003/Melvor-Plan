extends ProgressBar

@export var 缓动后销毁:bool=false;#用于缓动一次性后销毁
var _缓动目标=0

@export var 百分比低于20颜色值:Color=Color(0.79215687513351, 0.16470588743687, 0.00392156885937)
@export var 百分比大于20颜色值:Color=Color(0, 0.92549020051956, 0.3137255012989)

@export var 当前进度:float=100:
	set(目标进度):
		#print("之前的进度:",当前进度,"准备到进度:",目标进度)
		_缓动目标=目标进度
		if 当前进度!=目标进度:
			#判断当前进度与目标进度不能一样
			var tween:Tween=create_tween()
			tween.tween_method(缓动函数,当前进度,目标进度,0.5)
		当前进度=目标进度
		print("执行完毕?")
	get:
		return 当前进度
		
@export var 最大进度:float=100;
var 百分比:float=100.00;


func 缓动函数(_目标进度:float) ->void:
	#计算百分比
	var 转换:String="%.4f" % (_目标进度/最大进度)
	百分比=转换 as float *100
	#给颜色
	#print("百分比:",百分比)
	value=百分比
	if 百分比<=20.00:#红色
		get("theme_override_styles/fill").bg_color=Color(0.79215687513351, 0.16470588743687, 0.00392156885937)
	else:#绿色
		get("theme_override_styles/fill").bg_color=Color(0, 0.92549020051956, 0.3137255012989)
	
	if _目标进度==_缓动目标:
		if 缓动后销毁:
			queue_free()#			print("目标进度:",当前进度,"---",_目标进度,"目标进度",_缓动目标)
# Called when the node enters the scene tree for the first time.

#
signal 更变当前进度值;
signal 更变最大进度值;
func _ready() -> void:
	self.更变当前进度值.connect(func (数值):
		当前进度=数值
		)
	self.更变最大进度值.connect(func (数值):
		最大进度=数值
		)
