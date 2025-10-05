extends StackableData
class_name 标准物品

## 梅尔沃计划定义属性,决定部分抽取道具的随机池
@export var 标签: Array = ["物品"]
## 梅尔沃计划定义属性,决定鼠标指向物品的提示
@export var 简介: String = "暂无简介"
## 梅尔沃计划定义属性,决定道具商店直接出售价格,回收价格需要参考表格.
@export var 价值: int = 0
## 梅尔沃计划定义属性,决定道具商店内保存数量购买时可能不止一个但只计数-1,为0时删除-1为无限.
@export var 商店剩余数量: int = 0
#假设消耗为0后是否从背包移除
var 是否销毁=true
## 物品被使用时调用,返回销毁与否
func 物品使用() -> bool:
	if current_amount > 0:
		初始化.emit_signal("更新_背包物品信息", self)
		#var 消耗量 = 获取消耗量()
		#if 消耗量 > 0:
			#current_amount -= 消耗量
			#if current_amount <= 0:
				#return 是否销毁
	return false

## 消耗方法，需重写，返回消耗数量（>=0）
func 获取消耗量() -> int:
	push_warning("[Override this function] consumable item [%s] has been consumed" % item_name)
	print("消耗测试:",item_name)
	return 1
