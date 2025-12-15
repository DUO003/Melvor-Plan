extends Control
@export var BUFF数据: 梅BUFF数据
func _ready() -> void:
	var BUFF名称: String = BUFF数据.BUFF名称
	$"BUFF名称".text=BUFF名称
	设置BUFF图标(BUFF数据.贴图名称)
	计划.过去一秒.connect(更新时间)
	更新时间()
func 更新时间():
	%"BUFF时间".text="剩余%s"%计划.格式化时间(int(BUFF数据.剩余持续时间))
	
func 设置BUFF图标(名称: String, 精灵节点: Sprite2D=%"贴图") -> bool:
	var 映射字典=计划.贴图字典
	if not 映射字典.has(名称):
		print("【设置失败】未找到BUFF名称：%s" % 名称)
		return false
	if not 精灵节点:
		print("【设置失败】Sprite2D节点为空")
		return false
	var 图标数据 = 映射字典[名称]
	精灵节点.texture = 图标数据[0]
	精灵节点.region_enabled = true
	精灵节点.region_rect = 图标数据[1]
	return true
