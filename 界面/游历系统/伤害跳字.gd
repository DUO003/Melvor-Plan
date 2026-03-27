extends Control

# 动画配置常量（集中管理，方便修改）
const 字体大小: int = 35
const 停留时长: float = 0.5
const 移动时长: float = 0.5
const 移动距离: float = 40.0
const 暴击描边宽度: int = 3
const 随机偏移范围: Vector2 = Vector2(20, 5)  # 避免数字重叠的偏移
func _ready() -> void:
	# 2. 连接全局伤害跳字信号
	计划.地图.伤害跳字.connect(伤害跳字)

func 伤害跳字(数值: float, 位置: Vector2, 类型: String) -> void:
	# ========== 1. 异常处理：数值为0则忽略 ==========
	if 数值 == 0:
		print("错误：伤害跳字数值为0，已忽略")
		return
	var 标签节点: Label = Label.new()
	add_child(标签节点)  # 添加到CanvasLayer容器中
	var 随机偏移: Vector2 = Vector2(
		randf_range(-随机偏移范围.x, 随机偏移范围.x),randf_range(0, -随机偏移范围.y)-字体大小)
	标签节点.position = 位置 + 随机偏移
	标签节点.pivot_offset = Vector2(字体大小/2.0, 字体大小/2.0)  # 中心枢轴
	标签节点.add_theme_font_size_override("font_size", 字体大小)
	标签节点.text = ("" if 数值 < 0 else "+") + "%.0f"%数值
	match 类型:#根据类型设置颜色 + 暴击描边
		# 生命值：+绿色 / -红黄色；暴击加黄色描边
		"生命", "生命暴击":
			var 生命颜色 = Color(0.2, 0.8, 0.2) if 数值 > 0 else Color(0.92, 0.263, 0.147, 1.0)
			标签节点.add_theme_color_override("font_color", 生命颜色)
			# 暴击添加黄色描边
			if 类型 == "生命暴击":
				标签节点.add_theme_color_override("font_outline_color", Color(1.0, 1.0, 0.0))
				标签节点.add_theme_constant_override("outline_size",暴击描边宽度)
		"魔法":
			标签节点.add_theme_color_override("font_color", Color(0.2, 0.4, 0.9))
		"护盾":
			标签节点.add_theme_color_override("font_color", Color(0.4, 0.6, 0.8))
	播放跳字动画(标签节点)#播放动画：停留→上移→透明→删除
# 数字格式化：纯数字部分最多3字符 | ＜1亿用K/M，≥1亿用科学记数法
# 修复：Godot无log10，改用自然对数计算
func 格式化数字(数值: float) -> String:
	var 绝对值 = abs(数值)
	var 正负号 = "-" if 数值 < 0 else "+"

	# 小于1000：直接显示整数（1-3位）
	if 绝对值 < 1000:
		return 正负号 + str(round(绝对值))

	# 1千 ~ 99万：K单位
	if 绝对值 < 1000000:
		var 换算值 = 绝对值 / 1000
		if 换算值 < 10:
			return 正负号 + "%.1fK" % 换算值
		else:
			return 正负号 + "%.0fK" % 换算值

	# 100万 ~ 9999万：M单位
	if 绝对值 < 100000000:
		var 换算值 = 绝对值 / 1000000
		if 换算值 < 10:
			return 正负号 + "%.1fM" % 换算值
		else:
			return 正负号 + "%.0fM" % 换算值

	# ≥1亿：科学记数法（修复Godot无log10的问题）
	var 对数 = log(绝对值) / log(10.0)
	var 指数 = floor(对数)
	var 尾数 = round(绝对值 / pow(10, 指数) * 10) / 10
	if 尾数 >= 10:
		尾数 /= 10
		指数 += 1
	return 正负号 + "%.1fE%d" % [尾数, 指数]
# 播放跳字动画的工具函数
func 播放跳字动画(标签: Label) -> void:
	await get_tree().create_timer(停留时长).timeout
	var 动画 = create_tween()
	# 第二步：同时执行「向上移动」和「透明度降为0」（parallel()）
	动画.parallel()
	动画.tween_property(标签, "position", 标签.position + Vector2(0, -移动距离), 移动时长)
	动画.tween_property(标签, "modulate:a", 0.0, 移动时长)
	# 动画结束后删除Label节点（避免内存泄漏）
	动画.finished.connect(func():
		if 标签:
			标签.queue_free())
