extends StackableData
## 消耗品数据基类，你的消耗品数据类应该继承此类
class_name ConsumableData

## 当数量为0时，是否摧毁物品
@export var destroy_if_empty: bool = true
func 拷贝方法():#所有继承方法如果希望被正确拷贝都需要重写
	return ConsumableData.new(1,item_name)
## 物品被使用时调用
func use() -> bool:
	if 数量 > 0:
		var 消耗量 = consume()
		if 消耗量 > 0:
			数量 -= 消耗量
			if 数量 <= 0:
				return destroy_if_empty
	return false

## 消耗方法，需重写，返回消耗数量（>=0）
func consume() -> int:
	push_warning("[Override this function] consumable item [%s] has been consumed" % item_name)
	print("消耗测试:",item_name)
	return 1
