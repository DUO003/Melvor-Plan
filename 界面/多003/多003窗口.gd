extends DialogicPortrait
# 返回肖像的覆盖矩形区域（相对于根节点）
func _get_covered_rect() -> Rect2:
	return Rect2(Vector2.ZERO, Vector2(900,900))  # 默认大小
