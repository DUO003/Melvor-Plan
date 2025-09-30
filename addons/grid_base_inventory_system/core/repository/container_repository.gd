extends Resource
## 背包数据库，管理 ContainerData 的存取
class_name ContainerRepository

## 保存时的前缀
const PREFIX: String = "GBIS_"

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
@export_storage var 梅存档={}
@export_storage var 时间戳字典:Dictionary[String,int] = {}
@export_storage var 版本号=1



## 保存所有背包数据
func save() -> void:
	梅存档=初始化.梅存档.duplicate(true)
	时间戳字典=初始化.时间戳字典.duplicate(true)
	ResourceSaver.save(self, GBIS.current_save_path + PREFIX + GBIS.current_save_name)

## 读取所有背包数据
func load() -> void:
	var 缓存存档: ContainerRepository = load(GBIS.current_save_path + PREFIX + GBIS.current_save_name)
	if not 缓存存档:
		return
	缓存存档=堆叠上限更新(缓存存档,初始化.堆叠上限修改)
	初始化.梅存档=缓存存档.梅存档.duplicate(true)
	初始化.时间戳字典=缓存存档.时间戳字典.duplicate(true)
	for inv_name in 缓存存档._container_data_map.keys():
		_container_data_map[inv_name] = 缓存存档._container_data_map[inv_name].deep_duplicate()
	_quick_move_relations_map = 缓存存档._quick_move_relations_map.duplicate(true)
	if 缓存存档.版本号 == 版本号:
		print("成功版本：", 缓存存档.版本号)
	else:
		print("错误：当前版本为", 缓存存档.版本号)
## 增加并返回背包，如果已存在，返回已经注册的背包
func add_container(inv_name: String, columns: int, rows: int, avilable_types: Array[String]) -> ContainerData:
	var inv = get_container(inv_name)
	if not inv:
		var new_container = ContainerData.new(inv_name, columns, rows, avilable_types)
		_container_data_map[inv_name] = new_container
		return new_container
	return inv

func 堆叠上限更新(原存档: ContainerRepository, 修改字典: Dictionary) -> ContainerRepository:
	# 创建存档副本避免修改原数据
	var 修改后存档 = 原存档.duplicate()
	
	# 遍历所有容器
	for inv_name in 修改后存档._container_data_map.keys():
		var container_data = 修改后存档._container_data_map[inv_name].deep_duplicate()
		
		# 遍历容器中的所有物品
		for item in container_data.items:
			# 检查物品是否存在且修改字典中包含该物品的设置
			if item != null and item.item_name in 修改字典:
				# 更新堆叠上限
				item.stack_size = 修改字典[item.item_name]
				
		# 更新容器数据
		修改后存档._container_data_map[inv_name] = container_data
	
	return 修改后存档

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
