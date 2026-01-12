# @tool 注解表示该类可在编辑器中运行，修改属性时能实时看到效果
@tool
# 继承自 Godot 内置的 StyleBoxFlat（扁平样式框），用于自定义 UI 控件的样式
extends StyleBoxFlat
# 定义类名为 StyleBoxFlatPlus，方便在其他地方引用该自定义样式类
class_name 扩展的扁平样式框

# 定义一个导出属性组，在编辑器检查器中会将相关属性归类显示，组名为"NEGATIVE Expand Margins"，属性前缀为"margin_"
@export_group("NEGATIVE Expand Margins", "margin_")

# 导出左外边距属性，使用自定义属性提示，显示单位"px"
# 当设置该值时，会同步更新 StyleBoxFlat 内置的 expand_margin_left（扩展左外边距）
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var margin_left: int:
	set(value):
		# 更新当前属性值
		margin_left = value
		# 同步到父类的扩展左外边距属性，影响样式框的实际布局范围
		expand_margin_left = value

# 导出上外边距属性，功能与左外边距类似，控制上方向的扩展边距
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var margin_top: int:
	set(value):
		margin_top = value
		expand_margin_top = value

# 导出右外边距属性，控制右方向的扩展边距
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var margin_right: int:
	set(value):
		margin_right = value
		expand_margin_right = value

# 导出下外边距属性，控制下方向的扩展边距
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var margin_bottom: int:
	set(value):
		margin_bottom = value
		expand_margin_bottom = value
enum 构建枚举{自动,梅主题}
func _init(构建参数:构建枚举=构建枚举.自动) -> void:
	if 构建参数==构建枚举.梅主题:
		bg_color=Color(0.529, 0.373, 0.102)
		border_color=Color(0.0, 0.0, 0.0, 1.0)
		border_width_left=5
		border_width_top=5
		border_width_right=5
		border_width_bottom=5
