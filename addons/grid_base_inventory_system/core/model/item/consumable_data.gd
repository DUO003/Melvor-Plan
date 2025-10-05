extends StackableData
## 消耗品数据基类，你的消耗品数据类应该继承此类
class_name ConsumableData

## 当数量为0时，是否摧毁物品
@export var destroy_if_empty: bool = true

## 物品被使用时调用
func use() -> bool:
	if current_amount > 0:
		var 消耗量 = consume()
		if 消耗量 > 0:
			current_amount -= 消耗量
			if current_amount <= 0:
				return destroy_if_empty
	return false

## 消耗方法，需重写，返回消耗数量（>=0）
func consume() -> int:
	push_warning("[Override this function] consumable item [%s] has been consumed" % item_name)
	print("消耗测试:",item_name)
	return 1
