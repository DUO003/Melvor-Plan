extends Resource
## 装备槽数据类，管理穿脱装备
class_name EquipmentSlotData

## 已装备的物品，未装备时null，可用于检测是否有装备
@export_storage var equipped_item: ItemData
## 允许装备的物品类型，对应ItemData.type
@export_storage var avilable_types: Array[String]
## 装备槽的名字
@export_storage var slot_name: String

## 装备物品
func equip(item_data: ItemData) -> bool:
	if not equipped_item:
		if is_item_avilable(item_data):
			equipped_item = item_data
			equipped_item.equipped(slot_name)
			return true
	return false

## 脱掉装备，返回被脱掉的物品
func unequip() -> ItemData:
	if not equipped_item:
		return null
	var ret = equipped_item
	ret.unequipped(slot_name)
	equipped_item = null
	return ret

## 检查是否可装备这个物品
func is_item_avilable(item_data: ItemData) -> bool:
	if avilable_types.has("ANY") or avilable_types.has(item_data.type):
		return item_data.test_need(slot_name)
	return false

## 构造函数
@warning_ignore("shadowed_variable")
func _init(slot_name: String = GBIS.DEFAULT_SLOT_NAME, avilable_types: Array[String] = []) -> void:
	self.slot_name = slot_name
	self.avilable_types = avilable_types
