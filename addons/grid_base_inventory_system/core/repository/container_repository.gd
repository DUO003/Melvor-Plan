extends Resource
## 背包数据库，管理 ContainerData 的存取
class_name ContainerRepository

## 保存时的前缀
const PREFIX: String = "GBIS_物品_"

## 单例
static var instance: ContainerRepository:
	get:
		if not instance:
			instance = ContainerRepository.new()
		return instance

## 所有背包数据
@export_storage var _container_data_map: Dictionary[String, ContainerData]
## 所有背包的快速移动关系
@export_storage var _quick_move_relations_map: Dictionary[String, Array]

## 保存所有背包数据
func save() -> void:
	ResourceSaver.save(self, GBIS.current_save_path + PREFIX + GBIS.current_save_name)

func 删除存档():
	var 文件路径 = GBIS.current_save_path + PREFIX + GBIS.current_save_name
	# 创建 DirAccess 实例
	var dir = DirAccess.open(GBIS.current_save_path)
	if dir:
		# 检查文件是否存在然后删除
		if dir.file_exists(PREFIX + GBIS.current_save_name):
			var error = dir.remove(PREFIX + GBIS.current_save_name)
			if error == OK:
				print("存档删除成功")
			else:
				print("删除失败，错误代码: ", error)
	else:
		print("无法访问目录")


## 读取所有背包数据
func load() -> void:
	var 缓存存档: ContainerRepository = load(GBIS.current_save_path + PREFIX + GBIS.current_save_name)
	if not 缓存存档:
		return
	for inv_name in 缓存存档._container_data_map.keys():
		_container_data_map[inv_name] = 缓存存档._container_data_map[inv_name].deep_duplicate()
	_quick_move_relations_map = 缓存存档._quick_move_relations_map.duplicate(true)
func 加载物品(背包名称:String):
	if 背包名称 in _container_data_map:
		var 背包内物品=_container_data_map[背包名称].items
		for 物品 in 背包内物品:
			if 物品 is ItemData:
				物品.更新属性()
## 增加并返回背包，如果已存在，返回已经注册的背包
func add_container(inv_name: String, columns: int, rows: int, avilable_types: Array[String]) -> ContainerData:
	var inv = get_container(inv_name)
	if not inv:
		var new_container = ContainerData.new(inv_name, columns, rows, avilable_types)
		_container_data_map[inv_name] = new_container
		return new_container
	else :
		#更新背包参数
		if inv is ContainerData:
			inv.columns=columns
			inv.rows=rows
			inv.avilable_types=avilable_types
			inv.更新背包参数()
	return inv

## 获取背包数据
func get_container(inv_name: String) -> ContainerData:
	return _container_data_map.get(inv_name)

## 增加快速移动关系
func add_quick_move_relation(inv_name: String, target_inv_name: String) -> void:
	if _quick_move_relations_map.has(inv_name):
		var relations = _quick_move_relations_map[inv_name]
		relations.append(target_inv_name)
	else:
		var arr: Array[String] = [target_inv_name]
		_quick_move_relations_map[inv_name] = arr

## 移除快速移动关系
func remove_quick_move_relation(inv_name: String, target_inv_name: String) -> void:
	if _quick_move_relations_map.has(inv_name):
		var relations = _quick_move_relations_map[inv_name]
		relations.erase(target_inv_name)

## 获取指定背包的快速移动关系
func get_quick_move_relations(inv_name: String) -> Array[String]:
	return _quick_move_relations_map.get(inv_name, [] as Array[String])
func 更新所有物品堆叠():
	for 背包 in _container_data_map:
		var 物品数组=_container_data_map[背包].items
		for 物品 in 物品数组:
			if 物品 is 标准物品:
				物品.更新堆叠()
