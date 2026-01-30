extends ItemData
## 可堆叠物品数据基类，你的可堆叠物品数据类应继承此类（如：可堆叠的宝石）。注意：消耗品应继承 ConsumableData
class_name StackableData
##堆叠上限.duplicate()必须手动赋值
@export var 堆叠上限: int = 12480#再次改为存档,但依然由表格更新
##数量
@export var 数量: int = 1
##兼容旧版本数据
@export var current_amount: int = 0
func 更新属性()->bool:
	if super.更新属性():
		堆叠上限=int(表格数据[蓝图表头["堆叠"]])
		if current_amount>=1:##属性改名了,兼容旧版本数据
			数量=current_amount
			current_amount=0
		return true
	return false
func 拷贝方法():#所有继承方法如果希望被正确拷贝都需要重写
	return StackableData.new(1,item_name)
## 是否堆叠满了
func 满堆叠() -> bool:
	return 数量 >= 堆叠上限

## 增加堆叠数量，返回剩余数量
func add_amount(amount: int) -> int:
	if 满堆叠():
		return amount
	var amount_left = 堆叠上限 - 数量
	if amount_left < amount:
		数量 = 堆叠上限
		return amount - amount_left
	数量 += amount
	return 0
