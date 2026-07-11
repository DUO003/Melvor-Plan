@tool
extends Node
class_name 梅工具
# 计算带连续保底机制的事件综合期望概率
# 参数：基础发生概率(0~1小数)，保底最大次数
func 计算保底综合概率(基础概率: float, 保底次数: int) -> float:
	# 合法性校验
	if 基础概率 <= 0.0 or 基础概率 >= 1.0:
		print("错误：基础概率必须在0~1之间")
		return 0.0
	if 保底次数 < 2:
		print("错误：保底次数至少为2次才有保底效果")
		return 0.0
	
	var 单次失败概率: float = 1.0 - 基础概率
	var 期望抽取次数: float = 0.0
	
	# 遍历1~保底次数-1：中途成功的所有情况，改用range标准写法
	for 索引 in range(1, 保底次数):
		var 当前抽取次数 = 索引
		# 前k-1次全失败，第k次成功的概率
		var 该情况概率 = pow(单次失败概率, 当前抽取次数 - 1) * 基础概率
		期望抽取次数 += 当前抽取次数 * 该情况概率
	
	# 最后保底情况：前保底次数-1次全部失败，第n次必出
	var 全程失败概率 = pow(单次失败概率, 保底次数 - 1)
	期望抽取次数 += 保底次数 * 全程失败概率
	
	# 综合平均概率 = 1 / 平均多少次出一次
	var 综合平均概率: float = 1.0 / 期望抽取次数
	
	# 打印详细计算日志
	print("=====保底概率计算结果=====")
	print("单次基础概率：", str(基础概率 * 100), "%")
	print("连续失败上限，第", str(保底次数), "次保底必触发")
	print("平均每", str(期望抽取次数), "次触发一次事件")
	print("等效综合平均概率：", str(综合平均概率 * 100), "%")
	print("==========================\n")
	
	return clamp(综合平均概率, 0.0, 1.0)
func 清除子节点(节点容器:Node,保留节点:Node=null):
	for 节点名 in 节点容器.get_children():
		if 保留节点==null or 节点名!=保留节点:
			节点容器.remove_child(节点名)
			节点名.queue_free()
# 通用工具函数：根据纹理与目标像素尺寸，返回拉伸缩放值
# 参数：tex=待缩放纹理, target_w=目标像素宽, target_h=目标像素高
# 返回：适配目标尺寸的scale Vector2
func 计算纹理缩放倍率(tex: Texture2D, 目标像素宽: int, 目标像素高: int) -> Vector2:
	# 纹理为空/无效兜底
	if not tex:
		print("警告：传入纹理为空，返回默认缩放1,1")
		return Vector2.ONE
	var 纹理宽度: float = tex.get_width()
	var 纹理高度: float = tex.get_height()
	# 纹理尺寸非法兜底
	if 纹理宽度 <= 0.0 or 纹理高度 <= 0.0:
		print("警告：纹理宽高无效 w=", 纹理宽度, " h=", 纹理高度)
		return Vector2.ONE
	# 分别计算X/Y拉伸倍率（和你原代码逻辑完全一致，非等比适配）
	var 缩放X: float = 目标像素宽 / 纹理宽度
	var 缩放Y: float = 目标像素高 / 纹理高度
	return Vector2(缩放X, 缩放Y)
