@tool  # 启用编辑器内预览
extends Control
@export_enum("挂机", "木料", "矿城", "手工", "游历", "职业", "召唤") var 系统 = "手工"
@export var 玩法="合成":
	set(值):
		玩法=值
		_更新_UI()
var 等级=1

func _ready() -> void:
	_更新_UI()
	if Engine.is_editor_hint():
		return  # 直接返回，不执行后续可能出错的代码
	初始化.connect("更新_UI", Callable(self, "_更新_UI"))
	
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
		%精通进度条.max_value=10000
		%精通进度条.value=系统缓存.get("精通",0)
		%熟练进度条.max_value=初始化.结算升级(系统,"null",true)
		%熟练进度条.value=系统缓存.get("熟练",0)
