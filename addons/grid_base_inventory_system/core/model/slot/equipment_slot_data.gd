extends Resource
## 装备槽数据类，管理穿脱装备
class_name EquipmentSlotData

## 已装备的物品，未装备时null，可用于检测是否有装备
@export_storage var equipped_item: ItemData
## 允许装备的物品类型，对应ItemData.type
@export_storage var avilable_types: Array[String]
## 装备槽的名字
@export_storage var slot_name: String
@export var 装备栏宝石:Array[物品宝石]=[]
@export var 打孔种子:int=-1
## 装备物品
func equip(item_data: ItemData) -> bool:
	if item_data is 物品宝石:
		if 装备栏宝石.size()==0:
			装备栏宝石.append(item_data)
		else :
			#尝试打孔
			var 随机=RandomNumberGenerator.new()
			if not 打孔种子 is int or 打孔种子 == -1:
				打孔种子 = 随机.randi() 
			随机.seed = 打孔种子
			打孔种子=随机.randi()#更新下次判断的随机种子
			var 失败率=随机.randf()
			#print("%0.2f"%失败率)
			if 装备栏宝石.size()<4:
				if 失败率<=0.02*(4-装备栏宝石.size()):
					装备栏宝石.append(item_data)
					计划.语法糖通知("打孔成功")
					return true
				失败率-=0.02*(4-装备栏宝石.size())
				var 新宝石等阶=计划.表格.蓝图数据(item_data.item_name,"阶级")
				var 序号=0
				for 宝石 in 装备栏宝石:
					var 宝石等阶=计划.表格.蓝图数据(宝石.item_name,"阶级")
					if 宝石等阶<新宝石等阶 and 0.05>=失败率:
						装备栏宝石[序号]=item_data
						计划.语法糖通知("替换低阶宝石")
						return true
					失败率-=0.05
					序号+=1
			装备栏宝石[打孔种子%装备栏宝石.size()]=item_data
			计划.语法糖通知("替换随机已打孔宝石")
		return true
	if not equipped_item:
		if is_item_avilable(item_data):
			equipped_item = item_data
			equipped_item.equipped(slot_name)
			return true
	return false
func 倍率()->float:
	var 倍率=1.0
	for 宝石 in 装备栏宝石:
		倍率+=max(0.0,宝石.倍率()*0.01)
	#print(slot_name,"当前倍率",倍率)
	return 倍率
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
	# 新逻辑：如果是物品装备类，使用类型属性判断
	if item_data is 物品宝石:
		return true
	if item_data is 物品装备:
		#print(item_data.类型,"/",avilable_types)
		if avilable_types.size()==0:
			return true
		if avilable_types.has(item_data.类型):
			return item_data.test_need(slot_name)
	return false

## 构造函数
@warning_ignore("shadowed_variable")
func _init(slot_name: String = GBIS.DEFAULT_SLOT_NAME, avilable_types: Array[String] = []) -> void:
	self.slot_name = slot_name
	self.avilable_types = avilable_types
	#print(slot_name,avilable_types)
	if 打孔种子==-1:
		打孔种子=randi()
