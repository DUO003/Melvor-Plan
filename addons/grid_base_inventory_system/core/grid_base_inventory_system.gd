extends Node
## ========= 重要 ==========
## 全局名称必须配置为：GBIS
## ========= 重要 ==========

## 物品已添加
@warning_ignore("unused_signal")
signal sig_inv_item_added(inv_name: String, item_data: ItemData, grids: Array[Vector2i])
## 物品已移除
@warning_ignore("unused_signal")
signal sig_inv_item_removed(inv_name: String, item_data: ItemData)
## 物品已更新
@warning_ignore("unused_signal")
signal sig_inv_item_updated(inv_name: String, grid_id: Vector2i)
## 刷新所有背包
@warning_ignore("unused_signal")
signal sig_inv_refresh
## 刷新所有商店
@warning_ignore("unused_signal")
signal sig_shop_refresh
## 刷新所有装备槽
@warning_ignore("unused_signal")
signal sig_slot_refresh
## 物品已装备
@warning_ignore("unused_signal")
signal sig_slot_item_equipped(slot_name: String, item_data: ItemData)
## 物品已脱下
@warning_ignore("unused_signal")
signal sig_slot_item_unequipped(slot_name: String, item_data: ItemData)
## 焦点物品：监听这个信号以处理信息显示
@warning_ignore("unused_signal")
signal sig_item_focused(item_data: ItemData, container_name: String)
## 物品丢失焦点：监听这个信号以清除物品信息显示
@warning_ignore("unused_signal")
signal sig_item_focus_lost(item_data: ItemData)

## 默认角色
var DEFAULT_PLAYER: String = "player_1"
## 默认背包名称
var DEFAULT_INVENTORY_NAME: String = "Inventory"
## 默认商店名称
var DEFAULT_SHOP_NAME: String = "Shop"
## 默认装备槽名称
var DEFAULT_SLOT_NAME: String = "Equipment Slot"
## 默认保存路径
var DEFAULT_SAVE_FOLDER: String = "res://addons/grid_base_inventory_system/saves/"

## 背包业务类全局引用，如有需要可以使用，不要自己new
var inventory_service: InventoryService = InventoryService.new()
## 商店业务类全局引用，如有需要可以使用，不要自己new
var shop_service: ShopService = ShopService.new()
## 装备槽业务类全局引用，如有需要可以使用，不要自己new
var equipment_slot_service: EquipmentSlotService = EquipmentSlotService.new()
## 移动物品业务类全局引用，如有需要可以使用，不要自己new
var moving_item_service: MovingItemService = MovingItemService.new()
## 物品焦点业务类（处理鼠标在不在物品上），如有需要可以使用，不要自己new
var item_focus_service: ItemFocusService = ItemFocusService.new()

## 物品的 Material，如果不为空，则 ItemView 在创建时会给物品附加这个材质，用于使用 shader 做发光等效果
## 如果不使用，留空即可
var item_material: ShaderMaterial

## 所有背包的name
var inventory_names: Array[String]
## 所有商店的name
var shop_names: Array[String]

## 当前打开的container（包含背包和商店）
var opened_containers: Array[String]
## 当前打开的装备槽
var opened_equipment_slots: Array[String]

## 当前保存路径
var current_save_path: String = DEFAULT_SAVE_FOLDER
## 当前存档名，支持 "tres" 和 "res"，目前版本会保存两个文件：inv_存档名、equipment_slot_存档名
var current_save_name: String = "default.tres"

## 点击物品
var input_click: String = "inv_click"
## 快速移动
var input_quick_move: String = "inv_quick_move"
## 使用物品
var input_use: String = "inv_use"
## 分割物品
var input_split: String = "inv_split"

## 保存背包和装备槽
func save() -> void:
	# 不需要保存商店，商店和背包使用的一个数据源，保存背包的时候会一起保存
	inventory_service.save()
	equipment_slot_service.save()

## 读取背包和装备槽
func load() -> void:
	#await get_tree().process_frame
	inventory_service.load()
	equipment_slot_service.load()
	sig_inv_refresh.emit()
	sig_slot_refresh.emit()
	sig_shop_refresh.emit()

## 获取场景树的根（主要在Service中使用，因为Service没有加入场景树，所以没有 get_tree()）
func get_root() -> Node:
	return get_tree().root

## 向背包添加物品
func add_item(inv_name: String, item_data: ItemData) -> bool:
	return inventory_service.add_item(inv_name, item_data)

## 增加背包间的快速移动关系
func add_quick_move_relation(inv_name: String, target_inv_name: String) -> void:
	inventory_service.add_quick_move_relation(inv_name, target_inv_name)

## 删除背包间的快速移动关系
func remove_quick_move_relation(inv_name: String, target_inv_name: String) -> void:
	inventory_service.remove_quick_move_relation(inv_name, target_inv_name)

## 是否有正在移动的物品
func has_moving_item() -> bool:
	return moving_item_service.moving_item != null
