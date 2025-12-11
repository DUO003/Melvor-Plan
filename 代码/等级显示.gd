@tool  # 启用编辑器内预览
extends Control
@export_enum("挂机", "木料", "矿城", "手工", "游历", "职业", "召唤") var 系统 = "手工"
@export var 玩法="合成":
	set(值):
		玩法=值
		if Engine.is_editor_hint():_更新_UI()
var 等级=100
@export var 精通池显示=false:
	set(值):
		精通池显示=值
		if Engine.is_editor_hint():_更新_UI()
@export var 同时显示=false:
	set(值):
		if Engine.is_editor_hint():if 值:精通池显示=值
		同时显示=值
		if Engine.is_editor_hint():_更新_UI()

func _ready() -> void:
	_更新_UI()
	if Engine.is_editor_hint():
		return  # 直接返回，不执行后续可能出错的代码
	计划.connect("更新_UI", Callable(self, "_更新_UI"))
	if not 同时显示:
		%"上层".mouse_entered.connect(func(): 触发切换())
		%"上层".mouse_exited.connect(func():触发切换())

func 触发切换():
	#print("切换")
	精通池显示=not 精通池显示
	_更新_UI()
func _更新_UI():
	if not has_node("文本") or not is_instance_valid(%"文本"):
		return
	if Engine.is_editor_hint():
		%"文本".text= 玩法+" LV:"+str(等级)
		%精通进度条.max_value=100
		%精通进度条.value=33
		%熟练进度条.max_value=100
		%熟练进度条.value=66
		if 同时显示:%"文本2".text="熟练:\r精通:"
		else:
			if 精通池显示:%"文本2".text="精通:"
			else :%"文本2".text="熟练:"
	else :
		等级=计划.数据系统(系统,"等级")
		%"文本".text= 玩法+" LV:"+str(等级)
		var 精通=计划.数据系统(系统,"精通")
		var 精通上限=计划.数据系统(系统,"精通上限")
		var 熟练=计划.数据系统(系统,"熟练")
		var 熟练上限=计划.结算升级(系统,"null","null",true)
		if 同时显示:
			if 熟练上限==-1:
				%"文本2".text="精通:"+str(精通)+"/"+str(精通上限)+"\r"+"熟练:未解锁"
				熟练=0
				熟练上限=1
			else :
				%"文本2".text="精通:"+str(精通)+"/"+str(精通上限)+"\r"+"熟练:"+str(熟练)+"/"+str(熟练上限)
		else :
			if 精通池显示:
				%"文本2".text="精通:"+str(精通)+"/"+str(精通上限)
			else :
				%"文本2".text="熟练:"+str(熟练)+"/"+str(熟练上限)
				if 熟练上限==-1:
					%"文本2".visible=false
				else :
					%"文本2".visible=true
		%精通进度条.max_value=精通上限
		%精通进度条.value=精通
		%熟练进度条.max_value=熟练上限
		%熟练进度条.value=熟练
	if 同时显示:
		%"文本2".size.y=120
		%"精通进度条".custom_minimum_size.y=60
		%"熟练进度条".custom_minimum_size.y=60
		%"熟练进度条".position.y=60
		custom_minimum_size.y=120
	else :
		%"文本2".size.y=70
		custom_minimum_size.y=100
		if 精通池显示:
			%"精通进度条".custom_minimum_size.y=70
			%"熟练进度条".custom_minimum_size.y=30
			%"熟练进度条".position.y=70
		else :
			%"精通进度条".custom_minimum_size.y=30
			%"熟练进度条".custom_minimum_size.y=70
			%"熟练进度条".position.y=30
	position=Vector2(0,0)
	if 精通池显示:
		%"文本2".position.y=0
	else :
		%"文本2".position.y=30
