@tool
extends Control
var 映射字典
@onready var 贴图: Sprite2D = $贴图
@export var 缩放:float=1.0:
	set(值):
		缩放=值
		调整缩放()
func _ready() -> void:
	调整缩放()
	if not Engine.is_editor_hint():
		映射字典=计划.贴图字典
func 调整缩放() -> void:
	if not 贴图:
		print("【设置失败】未找到节点")
		return
	贴图.scale=Vector2(1,1)*缩放*0.25
	custom_minimum_size=Vector2(64,64)*缩放
	贴图.position=Vector2(64,64)*缩放*0.5
func 设置BUFF图标(名称: String) -> bool:
	if not 映射字典.has(名称):
		print("【设置失败】未找到BUFF图标：%s" % 名称)
		return false
	var 图标数据 = 映射字典[名称]
	贴图.texture = 图标数据[0]
	贴图.region_enabled = true
	贴图.region_rect = 图标数据[1]
	return true
