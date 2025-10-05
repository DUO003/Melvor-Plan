extends Resource
## 装备槽数据库，管理 EquipmentSlotData 的存取
class_name EquipmentSlotRepository

## 保存时的前缀
const PREFIX: String = "GBIS_装备槽_"

## 系统中所有的装备槽
@export_storage var _slot_data_map: Dictionary[String, EquipmentSlotData]

## 单例
static var instance: EquipmentSlotRepository:
	get:
		if not instance:
			instance = EquipmentSlotRepository.new()
		return instance

## 保存所有装备槽
func save() -> void:
	ResourceSaver.save(self, GBIS.current_save_path + PREFIX + GBIS.current_save_name)

## 读取所有装备槽，会重新穿戴所有装备
func load() -> void:
	for slot_name in _slot_data_map.keys():
		var item_data = _slot_data_map[slot_name].equipped_item
		if item_data:
			item_data.unequipped(slot_name)
	
	var saved_repository: EquipmentSlotRepository = load(GBIS.current_save_path + PREFIX + GBIS.current_save_name)
	if not saved_repository:
		return
	for slot_name in saved_repository._slot_data_map.keys():
		_slot_data_map[slot_name] = saved_repository._slot_data_map[slot_name].duplicate(true)
		var item_data = _slot_data_map[slot_name].equipped_item
		if item_data:
			item_data.equipped(slot_name)

## 获取指定装备槽的数据类
func get_slot(slot_name: String) -> EquipmentSlotData:
	return _slot_data_map.get(slot_name)

## 增加一个装备槽
func add_slot(slot_name: String, avilable_types: Array[String]) -> bool:
	var slot = get_slot(slot_name)
	if not slot:
		_slot_data_map[slot_name] = EquipmentSlotData.new(slot_name, avilable_types)
		return true
	return false

## 尝试装备一件物品，如果装备成功，返回装备上这个物品的装备槽
func try_equip(item_data: ItemData) -> EquipmentSlotData:
	for slot in _slot_data_map.values():
		if GBIS.opened_equipment_slots.has(slot.slot_name) and slot.equip(item_data):
			return slot
	return null
