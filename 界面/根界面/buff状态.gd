extends Control
@export var BUFF数据: 梅BUFF数据
var 名称节点: Label
func _ready() -> void:
	名称节点 = $"BUFF名称"
	计划.过去一秒.connect(更新时间)
	初始化()
func 初始化():
	_更新BUFF名称显示()
	设置BUFF图标(BUFF数据.贴图名称)
	更新时间()
func 更新时间():
	%"BUFF时间".text="剩余%s"%计划.格式化时间(int(BUFF数据.剩余持续时间))
##更新名称
func _更新BUFF名称显示() -> void:
	if not BUFF数据:
		print("BUFF数据未配置！")
		名称节点.text = ""
		return
	var BUFF名称: String = BUFF数据.BUFF名称 + 计划.罗马数字(BUFF数据.层数)
	名称节点.text = BUFF名称
	var 目标显示宽度: float = 名称节点.size.x-64-10#64是左内容边距,10右内容边距,定义固定显示宽度
	var 字符串实际宽度: float = 名称节点.get_theme_font("font").get_string_size(名称节点.text,
	HORIZONTAL_ALIGNMENT_LEFT, -1, 名称节点.get_theme_font_size("font_size")).x#计算字符串实际渲染宽度
	var 原始字体大小: int = 名称节点.get_theme_font_size("font_size")#获取原始默认字号
	var 缩放比例: float = 目标显示宽度 / 字符串实际宽度
	var 新字体大小: int = int(原始字体大小 * 缩放比例)
	新字体大小 = max(新字体大小, 12)
	名称节点.add_theme_font_size_override("font_size", 新字体大小)
func 设置BUFF图标(名称: String, 精灵节点: Control=%"贴图") -> bool:
	return 精灵节点.设置BUFF图标(名称)
