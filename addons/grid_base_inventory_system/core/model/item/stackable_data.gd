extends ItemData
## 可堆叠物品数据基类，你的可堆叠物品数据类应继承此类（如：可堆叠的宝石）。注意：消耗品应继承 ConsumableData
class_name StackableData

@export var stack_size: int = 2
@export var current_amount: int = 1

## 是否堆叠满了
func is_full() -> bool:
	return current_amount >= stack_size

## 增加堆叠数量，返回剩余数量
func add_amount(amount: int) -> int:
	if is_full():
		return amount
	var amount_left = stack_size - current_amount
	if amount_left < amount:
		current_amount = stack_size
		return amount - amount_left
	current_amount += amount
	return 0
