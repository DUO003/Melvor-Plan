@tool  # 启用编辑器内预览
extends Control
@export_enum("挂机", "木料", "矿城", "手工", "游历", "职业", "召唤") var 系统 = "手工"
@export var 玩法="合成":
	set(值):
		玩法=值
		_更新_UI()
var 等级=1
@export var 精通池显示=false:
	set(值):
		精通池显示=值
		_更新_UI()

func _ready() -> void:
	_更新_UI()
	if Engine.is_editor_hint():
		return  # 直接返回，不执行后续可能出错的代码
	初始化.connect("更新_UI", Callable(self, "_更新_UI"))
	%"上层".mouse_entered.connect(func(): 触发切换())
	%"上层".mouse_exited.connect(func():触发切换())

func 触发切换():
	#print("切换")
	精通池显示=not 精通池显示
func _更新_UI():
	if Engine.is_editor_hint():
		%"文本".text= 玩法+" LV:"+str(等级)
		%精通进度条.max_value=100
		%精通进度条.value=33
		%熟练进度条.max_value=100
		%熟练进度条.value=66
	else :
		var 系统缓存=初始化.梅存档.get(系统,{})
		等级=系统缓存.get("等级",0)
		%"文本".text= 玩法+" LV:"+str(等级)
		var 精通=int(系统缓存.get("精通",0))
		var 精通上限=10000+等级*1000
		var 熟练=int(系统缓存.get("熟练",0))
		var 熟练上限=初始化.结算升级(系统,"null",true)
		%精通进度条.max_value=精通上限
		%精通进度条.value=精通
		%熟练进度条.max_value=熟练上限
		%熟练进度条.value=熟练
		if 精通池显示:
			%"文本2".text="精通:"+str(精通)+"/"+str(精通上限)
		else :
			%"文本2".text="熟练:"+str(熟练)+"/"+str(熟练上限)
			if 熟练上限==-1:
				%"文本2".visible=false
			else :
				%"文本2".visible=true
	var 文本2位置=%"文本".size.x+10
	if 精通池显示:
		%"精通进度条".size=Vector2(1700,70)
		%"熟练进度条".size=Vector2(1700,30)
		%"熟练进度条".position=Vector2(0,70)
		%"文本2".position=Vector2(文本2位置,0)
	else :
		%"精通进度条".size=Vector2(1700,30)
		%"熟练进度条".size=Vector2(1700,70)
		%"熟练进度条".position=Vector2(0,30)
		%"文本2".position=Vector2(文本2位置,30)
