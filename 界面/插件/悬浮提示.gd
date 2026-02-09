extends Panel
class_name 梅悬浮提示
##最大宽度
var 宽度上限=800
var 屏幕尺寸:Vector2
var 节点:Node 
@export var 禁用:bool=false
@onready var 富文本: RichTextLabel = %文本
func _ready() -> void:
	if 禁用:
		queue_free()
		return
	visible=false
	屏幕尺寸=计划.游戏分辨率
	计划.全局悬浮提示.connect(更新文本)
func 更新文本(文本内容:String="",节点实例:Node=self,默认字体:int=40):
	if 文本内容=="":
		if 节点==节点实例:
			visible=false
		return
	节点=节点实例
	富文本.add_theme_font_size_override("normal_font_size",默认字体)
	富文本.add_theme_constant_override("paragraph_separation",int(默认字体*-0.5))
	富文本.add_theme_constant_override("line_separation",int(默认字体*-0.1))
	global_position = get_global_mouse_position() + Vector2(10, 10)
	富文本.text=文本内容
	富文本.autowrap_mode=TextServer.AUTOWRAP_OFF
	富文本.size=Vector2(50, 50)
	富文本.custom_minimum_size=Vector2(50, 50)
	var 范围=富文本.get_combined_minimum_size()
	if 范围.x>宽度上限:
		富文本.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		富文本.custom_minimum_size=Vector2(宽度上限, 50)
	富文本.size=富文本.get_minimum_size()
	await get_tree().process_frame
	富文本.size=富文本.get_minimum_size()
	size = 富文本.size + Vector2(16, 16)
	富文本.position=Vector2(8, 5)
	visible=true
func _process(_delta: float) -> void:
	if visible:
		if 节点:
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
