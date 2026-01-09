extends Panel
class_name 梅成就卡片
@export var 成就名称:String=""
@onready var 图片: TextureRect = %图片
@onready var 名称: Label = $名称
@onready var 完成:bool=false
func _ready() -> void:
	if 成就名称=="":
		return
	完成=计划.steam.检查成就(成就名称,true)
	图片.texture=计划.steam.读取成就图标(成就名称)
	if 完成:
		图片.self_modulate=Color(1.0, 1.0, 1.0)
	else :
		图片.self_modulate=Color(0.1,0.1,0.1)
	名称.text=成就名称
	更新成就状态()
	计划.更新_UI.connect(更新成就状态)
@onready var 已领取: Label = $已领取
func 更新成就状态():
	var 任务进度=计划.梅存档["挂机"].get("任务进度",{})
	var 完成状态=任务进度.get(成就名称,0)==1
	已领取.visible=完成状态
	
