extends ColorPickerButton

# 导出变量 - 可在检查器面板配置，默认值按你的要求设置
# 禁用采样器显示（默认false）
@export var 采样器显示: bool = false
# 禁用颜色模式选择显示（默认false）
@export var 颜色模式显示: bool = false
# 禁用十六进制颜色码显示（默认false）
@export var 十六进制显示: bool = false
# 禁用预设颜色显示（默认false）
@export var 预设显示: bool = false
# 禁用亮度编辑（默认false）
@export var 亮度编辑: bool = false
# 启用延迟模式（默认true）
@export var 延迟模式: bool = true
# 设置拾取器形状（默认HSV色轮）
@export var 拾取器形状: ColorPicker.PickerShapeType = ColorPicker.SHAPE_HSV_WHEEL
# 当节点准备好时初始化ColorPicker的样式
func _ready():
	初始化颜色选择器样式()
# 初始化颜色选择器样式（中文命名风格）
func 初始化颜色选择器样式():
	# 获取ColorPickerButton对应的ColorPicker实例
	var 颜色选择器 = get_picker()
	if 颜色选择器:
		# 应用检查器配置的属性（默认值已按你的要求设置）
		颜色选择器.sampler_visible = 采样器显示
		颜色选择器.color_modes_visible = 颜色模式显示
		颜色选择器.hex_visible = 十六进制显示
		颜色选择器.presets_visible = 预设显示
		颜色选择器.edit_intensity = 亮度编辑
		颜色选择器.deferred_mode = 延迟模式
		颜色选择器.picker_shape = 拾取器形状
