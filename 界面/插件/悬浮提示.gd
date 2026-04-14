extends PanelContainer
class_name 梅悬浮提示
##最大宽度
var 宽度上限=800
var 屏幕尺寸:Vector2
var 节点:Node 
@export var 禁用:bool=false
@export var 禁用后删除:bool=true
@onready var 富文本: RichTextLabel = %文本
@onready var 样式: VBoxContainer = %样式
func _ready() -> void:
	if 禁用:
		if 禁用后删除:queue_free()
		富文本.visible=false
		return
	visible=false
	屏幕尺寸=计划.游戏分辨率
	富文本.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	富文本.custom_minimum_size=Vector2(宽度上限, 50)
	计划.全局悬浮提示.connect(更新文本)
	计划.数据包提示.connect(数据包更新)
func 更新文本(文本内容:String="",节点实例:Node=self,默认字体:int=40):
	if 文本内容=="":
		if 节点==节点实例:
			visible=false
		return
	节点=节点实例
	默认样式启用()
	富文本.add_theme_font_size_override("normal_font_size",默认字体)
	富文本.add_theme_constant_override("paragraph_separation",int(默认字体*-0.1))
	富文本.add_theme_constant_override("line_separation",int(默认字体*-0.1))
	富文本.text=文本内容
	富文本.autowrap_mode=TextServer.AUTOWRAP_OFF
	富文本.size=Vector2(0, 0)
	富文本.custom_minimum_size=Vector2(0, 0)
	var 范围=富文本.get_combined_minimum_size()
	if 范围.x>宽度上限:
		富文本.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		富文本.custom_minimum_size=Vector2(宽度上限, 50)
	size = Vector2(0, 0)
	if not 禁用:
		global_position = get_global_mouse_position() + Vector2(10, 10)
	visible=true
func 数据包更新(数据:梅提示数据):
	if 数据.节点:节点=数据.节点
	else :节点=self
	计划.清除子节点(样式,富文本)
	富文本.visible=false
	if 数据.提示数组.is_empty():
		visible=false
		return
	var 富文本模板: RichTextLabel=RichTextLabel.new()
	富文本模板.bbcode_enabled=true
	富文本模板.fit_content=true
	富文本模板.scroll_active=false
	富文本模板.autowrap_mode=TextServer.AUTOWRAP_OFF
	富文本模板.size=Vector2(0, 0)
	#富文本模板.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	富文本模板.add_theme_font_size_override("normal_font_size",数据.默认字体)
	富文本模板.add_theme_constant_override("paragraph_separation",int(数据.默认字体*-0.15))
	富文本模板.add_theme_constant_override("line_separation",int(数据.默认字体*-0.4))
	#富文本模板.add_theme_stylebox_override("normal",默认边距)
	for 提示数据:Dictionary in 数据.提示数组:
		var 模式:String=提示数据.get("模式","默认")
		match 模式:
			"默认":
				var 富文本克隆:=富文本模板.duplicate()
				富文本克隆.text=提示数据.文本
				if 提示数据.has("宽度"):
					富文本克隆.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
					富文本克隆.custom_minimum_size=Vector2(提示数据.宽度, 50)
				样式.add_child(富文本克隆)
			"分栏":
				var 分栏:=分栏节点(提示数据.get("间距",0))
				for 分栏数据 in 提示数据.分栏组:
					if 分栏数据 is String:
						var 富文本克隆:=富文本模板.duplicate()
						富文本克隆.text=分栏数据
						分栏.add_child(富文本克隆)
					elif 分栏数据 is float:
						var 进度:=ProgressBar.new()
						进度.max_value=1
						进度.value=分栏数据
						进度.custom_minimum_size=Vector2(75,20)
						进度.show_percentage=true#false
						进度.size_flags_vertical=Control.SIZE_SHRINK_CENTER
						进度.add_theme_font_size_override("font_size",int(数据.默认字体*0.6))
						进度.add_theme_color_override("font_color", Color(0, 0, 0))
						调整进度条填充颜色(进度,分栏数据)
						分栏.add_child(进度)
					elif 分栏数据 is Dictionary:
						var 图片:TextureRect=TextureRect.new()
						图片.texture=分栏数据.图片
						图片.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
						图片.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
						图片.custom_minimum_size=Vector2(数据.默认字体,数据.默认字体)
						分栏.add_child(图片)
				样式.add_child(分栏)
			"分隔线":
				# 获取分隔线宽度（默认值5）
				var 分隔线宽度:float = 提示数据.get("宽度", 5.0)
				# 创建ColorRect作为分隔线
				var 分隔线:ColorRect = ColorRect.new()
				# 设置分隔线样式（可根据需要调整颜色）
				分隔线.color = 提示数据.get("颜色", Color(0.7, 0.7, 0.7)) # 默认灰色
				# 设置分隔线尺寸：宽度自适应容器，高度为指定的宽度参数
				分隔线.custom_minimum_size = Vector2(0, 分隔线宽度)
				分隔线.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				var 边距容器:MarginContainer = MarginContainer.new()
				var 边距:int=提示数据.get("边距",5)
				边距容器.add_theme_constant_override("margin_left", 边距)
				边距容器.add_theme_constant_override("margin_right", 边距)
				边距容器.add_theme_constant_override("margin_top", 边距)
				边距容器.add_theme_constant_override("margin_bottom", 边距)
				边距容器.add_child(分隔线)
				样式.add_child(边距容器)
	if not 禁用:
		size = Vector2(0, 0)
	print(size)
	数据包样式调整(数据.标题高度)
	if not 禁用:
		global_position = get_global_mouse_position() + Vector2(10, 10)
	visible=true
	#print("提示数组:\n",数据.提示数组)
func 调整进度条填充颜色(进度条节点: ProgressBar, 进度数值: float) -> void:
	# ========== 颜色可配置变量（方法内定义，方便调整） ==========
	# 过低色：0-25% 显示的暗红色（替代原亮红）
	var 过低色: Color = Color(0.4, 0.04, 0.046, 1.0)
	# 中间色：50% 显示的暗黄色（替代原亮黄，渐变基准色）
	var 中间色: Color = Color(0.61, 0.5, 0.012, 1.0)
	# 完美色：75%-100% 显示的暗绿色（替代原亮绿）
	var 完美色: Color = Color(0.07, 0.7, 0.164, 1.0)
	# ==========================================================

	# 1. 参数校验：确保节点有效且是ProgressBar类型
	if 进度条节点 == null or not 进度条节点 is ProgressBar:
		print("错误：传入的节点不是有效的ProgressBar！")
		return

	# 2. 裁剪数值到0-1范围，避免异常值导致颜色错误
	var 有效进度值: float = clamp(进度数值, 0.0, 1.0)

	# 3. 获取并复制进度条默认的fill样式盒（必须复制，避免修改全局样式）
	var 填充样式盒: StyleBoxFlat = 进度条节点.get_theme_stylebox("fill", "ProgressBar").duplicate()
	if 填充样式盒 == null:
		print("错误：无法获取ProgressBar的fill样式盒！")
		return

	# 4. 根据进度值计算目标颜色（引用配置变量）
	var 目标颜色: Color
	if 有效进度值 <= 0.25:
		# 0-25%：使用配置的过低色
		目标颜色 = 过低色
	elif 有效进度值 < 0.75:
		var 渐变系数: float
		var 红通道: float
		var 绿通道: float
		var 蓝通道: float
		if 有效进度值 <= 0.5:
			# 25%-50%：过低色 → 中间色 渐变
			# 计算渐变系数（0~1，对应25%到50%的区间）
			渐变系数 = (有效进度值 - 0.25) * 4  # 结果范围：0 → 1
			# 手动计算每个通道的渐变值：起始值 + 系数*(目标值-起始值)
			红通道 = 过低色.r + 渐变系数 * (中间色.r - 过低色.r)
			绿通道 = 过低色.g + 渐变系数 * (中间色.g - 过低色.g)
			蓝通道 = 过低色.b + 渐变系数 * (中间色.b - 过低色.b)
		else:
			# 50%-75%：中间色 → 完美色 渐变
			# 计算渐变系数（0~1，对应50%到75%的区间）
			渐变系数 = (有效进度值 - 0.5) * 4  # 结果范围：0 → 1
			# 手动计算每个通道的渐变值
			红通道 = 中间色.r + 渐变系数 * (完美色.r - 中间色.r)
			绿通道 = 中间色.g + 渐变系数 * (完美色.g - 中间色.g)
			蓝通道 = 中间色.b + 渐变系数 * (完美色.b - 中间色.b)
		# 组装最终的渐变颜色
		目标颜色 = Color(红通道, 绿通道, 蓝通道)
	else:
		# 75%-100%：使用配置的完美色
		目标颜色 = 完美色

	# 5. 修改样式盒背景色并应用到进度条
	填充样式盒.bg_color = 目标颜色
	进度条节点.add_theme_stylebox_override("fill", 填充样式盒)
func 分栏节点(间距:int)->HBoxContainer:
	var 分栏:HBoxContainer=HBoxContainer.new()
	分栏.add_theme_constant_override("separation",间距)
	分栏.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	return 分栏
func _process(_delta: float) -> void:
	if visible and not 禁用:
		if 节点:
			if 节点 is 梅帮助提示文本:
				global_position = 节点.global_position + 节点.提示偏移
			else :
				global_position = get_global_mouse_position() + Vector2(10, 10)
			限制屏幕范围()
		else :
			visible=false
			print("节点被销毁,提示隐藏")
func 限制屏幕范围():
	if global_position.x+size.x>屏幕尺寸.x:
		global_position.x=屏幕尺寸.x-size.x
	elif global_position.x<0:
		global_position.x=0
	if global_position.y+size.y>屏幕尺寸.y:
		global_position.y=屏幕尺寸.y-size.y
	elif global_position.y<0:
		global_position.y=0
###支持的标签清单[br]
### - 无参数：加粗、斜体、下划线、删除线（参数传[]）[br]
### - 单参数：颜色、前景、背景、图片、字号（参数传["参数值"]）[br]
#func 格式BBC(内容数组: Array[Dictionary]) -> String:
	## 核心映射表：中文标签名 → BBCode标签规则（标签名+是否需要参数）
	#var 标签规则映射: Dictionary = {
		#"加粗": {"标签名": "b", "需要参数": false},
		#"斜体": {"标签名": "i", "需要参数": false},
		#"下划线": {"标签名": "u", "需要参数": false},
		#"删除线": {"标签名": "s", "需要参数": false},
		#"颜色": {"标签名": "color", "需要参数": true},
		#"前景": {"标签名": "fgcolor", "需要参数": true},
		#"背景": {"标签名": "bgcolor", "需要参数": true},
		#"图片": {"标签名": "img", "需要参数": true},
		#"字号": {"标签名": "font_size", "需要参数": true}}
#
	## 存储最终拼接的文本
	#var 最终拼接文本: String = ""
	## 获取文本块总数（用于判断是否是最后一个）
	#var 文本块总数 = 内容数组.size()
#
	## 遍历每个文本块配置
	#var 索引:int=1
	#for 文本块配置:Dictionary in 内容数组:
		## 1. 提取基础参数，处理默认值
		## 必选参数：文本
		#if not 文本块配置.has("文本") or not 文本块配置["文本"] is String:
			#push_warning("第%d个文本块缺少有效文本参数，已跳过" % (索引 + 1))
			#continue
		#var 原始文本 = 文本块配置["文本"]
		## 可选参数：换行（默认true）
		#var 是否换行 = 文本块配置.get("换行", true)
#
		## 2. 生成当前文本块的BBCode标签
		#var 开始标签列表: Array[String] = []
		#var 结束标签列表: Array[String] = []
		#for 中文标签名 in 文本块配置:
			## 跳过"文本"和"换行"这两个非标签参数
			#if 中文标签名 in ["文本", "换行"]:
				#continue
			#
			## 校验标签是否支持
			#if not 标签规则映射.has(中文标签名):
				#print("第%d个文本块忽略不支持的标签：%s" % [(索引 + 1), 中文标签名])
				#continue
			## 获取标签规则和传入的参数
			#var 标签规则 = 标签规则映射[中文标签名]
			#var 实际标签名 = 标签规则["标签名"]
			#var 需要参数 = 标签规则["需要参数"]
			#var 传入参数 = 文本块配置[中文标签名]
#
			## 参数合法性校验（适配你修改后的字符串参数格式）
			#if 需要参数:
				## 有参数标签必须传字符串（如颜色传"#4cf"而非数组）
				#if not 传入参数 is String:
					#print("第%d个文本块标签[%s]需要字符串参数，已忽略该标签" % [(索引 + 1), 中文标签名])
					#continue
				#开始标签列表.append("[%s=%s]" % [实际标签名, 传入参数])
			#else:
				## 无参数标签直接生成（忽略传入的参数值，只判断存在性）
				#开始标签列表.append("[%s]" % 实际标签名)
			## 生成结束标签
			#结束标签列表.append("[/%s]" % 实际标签名)
		## 反转结束标签列表，保证嵌套闭合顺序正确
		#结束标签列表.reverse()
		## 3. 拼接当前文本块的最终内容
		#var 当前文本块 = "".join(开始标签列表) + 原始文本 + "".join(结束标签列表)
		## 4. 判断是否需要加换行符
		#if 是否换行 and 索引 < 文本块总数 - 1:
			#当前文本块 += "\n"
		## 5. 追加到最终文本中
		#最终拼接文本 += 当前文本块
		#索引+=1
#
	#return 最终拼接文本
var 数据包样式:嵌套数组样式=preload("res://界面/主题/提示/悬浮提示.tres")
var 默认样式:扩展的扁平样式框=preload("res://界面/主题/提示/默认悬浮提示.tres")
var 默认边距:扩展的扁平样式框=preload("res://界面/主题/提示/默认边距.tres")
func 数据包样式调整(标题高度:float=60):
	#get_theme_stylebox("panel")
	var 全局配置字典:Dictionary = ProjectSettings.get_setting("global/snake_case")
	var 标题色:=Color(计划.配置文件.get("悬浮标题色", 全局配置字典.get("悬浮标题色","#b38c40dc"))as String)
	var 背景色:=Color(计划.配置文件.get("悬浮背景色", 全局配置字典.get("悬浮背景色","#8f6f2fe6"))as String)
	var 当前样式:嵌套数组样式=数据包样式.duplicate(true)
	当前样式.样式数组[0].margin_top=-标题高度
	当前样式.样式数组[0].bg_color=背景色
	当前样式.样式数组[1].margin_bottom=标题高度-size.y+5
	当前样式.样式数组[1].bg_color=标题色
	add_theme_stylebox_override("panel",当前样式)
func 默认样式启用():
	计划.清除子节点(样式,富文本)
	富文本.visible=true
	add_theme_stylebox_override("panel",默认样式)
