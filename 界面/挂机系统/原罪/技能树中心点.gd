extends Label
# 可在编辑器配置的属性
@export var 线宽: float = 2.0  # 线宽
@export var 线颜色: Color = Color(0, 1, 0)  # 线颜色
@export var 抗锯齿: bool = true  # 抗锯齿
# 保存线段数据
var 线段数据数组: Array = []
# 更新线段数据并触发重绘
func 更新线段数据(线段数组: Array) -> void:
	线段数据数组 = 线段数组
	queue_redraw()
func _draw() -> void:
	for 单条线段 in 线段数据数组:
		# 校验格式
		if 单条线段.size() != 4:
			print("无效线段格式，需为[x1,y1,x2,y2]：", 单条线段)
			continue
		# 提取相对坐标端点（保留原有坐标转换逻辑）
		var 起点 = Vector2(单条线段[0]-position.x, 单条线段[1]-position.y)
		var 终点 = Vector2(单条线段[2]-position.x, 单条线段[3]-position.y)

		# ========== 核心修改：计算直角拐点（先X后Y） ==========
		var 拐点 = Vector2(终点.x, 起点.y)  # 先水平对齐（X取终点，Y取起点）
		# =====================================================

		# 分两次绘制直角线段（先水平，后垂直）
		draw_line(起点, 拐点, 线颜色, 线宽, 抗锯齿)  # 水平线段：起点 → 拐点
		draw_line(拐点, 终点, 线颜色, 线宽, 抗锯齿)  # 垂直线段：拐点 → 终点
